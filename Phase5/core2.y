%{
#include <ctype.h>
#include "core2.tab.h"
#include <stdio.h>
#define YYDEBUG 1
#define ADDOP  301
#define MULTOP 302
#define MINUSOP 303
#define DIVIDEOP 304
#define GOTO	407
#define LT 1
#define EQ 2
#define GT 3
#define LTE 4
#define NE 5
#define GTE 6
#define LIVE 7

 #define ASSIGN	10
 #define ADD	11
 #define MULT	12
 #define SUB	13
 #define GOTO	14
 #define if=	15
 #define if>	16
 #define print	17
 #define live	18
 #define end  19

#define YYDEBUG 1
#include "kr.symtab.h"
#define INT_TYPE 1000
#define CODESIZE 1000

extern char *yytext;
char *newtemp();
void gen(int, char *, char *, char *);
void yyerror(char *s);
int yylex(void);
typedef struct node{
		int quadnum;
		struct node *link;
		} *LIST, LISTNODE;
int opcode[CODESIZE];
char *op1[CODESIZE], *op2[CODESIZE], *target[CODESIZE];
char *VOID = "#VOID";

LIST tmplist;
int nextquad = 0;

LIST makelist(int);
LIST  merge(LIST, LIST);

int backpatch_verbose = 1;
%}


%union{
     char *place;
     int  ival;
     struct {
	 struct LIST  *true;
	 struct LIST  *false;
	  } list;
     int quad;
     int type;
     struct LIST *next;
}

%type <place> expression
%type <list> B
%type <quad> M
%type <next> N
%type <next> S
%type <next> L
%token <place> INT
%token <type> RELOP
%type <place> identifier
%token <ival> DIGIT
%token <place> TEXT
%token DEBUG
%left PLUS MINUS
%left TIMES DIVIDE


%token TIMES PLUS LPAREN RPAREN QUOT EQUALS COMMA COLON PROGRAM BEGINT ENDT INPUT OUTPUT WHILE IF ELSE MINUS DIVIDE THEN FLOAT DOUBLE OCURLY CCURLY  AND OR NOT ASSIGN LT GT EQ LTE NE GTE LOOP UNTIL ENDTIF ENDTLOOP START

%%

program
	: START 
	| program S {
				 dumpcode();
				 
				 exit(0);
				 }
	;

L:	S			{$<next>$=$<next>1;}
    |	L M S			{
 
				 
				 backpatch($<next>1,$2);
				 $<next>$=$<next>3;
				}
/*begin part */
	;
begin 
	: BEGINT
	;
/*Declaration part */
declaration
	: varlist QUOT 
	;
varlist 
	: INT COLON identifier {lookup($3)->val= INT;}
	| varlist COMMA identifier {lookup($3)->val= INT;}
	;

expression 
	: identifier {if(lookup($1)->val == INT)
	{
				$<place>$ = yylval.place;
	}
				else
					{
					yyerror("Variable not declard");
					exit(0);
					}
				}
				
	| digit {
				$<ival>$ = yylval.ival;
				}
	| expression PLUS expression { 
				$<place>$ = newtemp();
				gen(ADDOP,$<place>1, $<place>3, $<place>$);
				}
	| expression TIMES expression 
				{ 
				$<place>$ = newtemp();
				gen(MULTOP,$<place>1, $<place>3, $<place>$);
				}
	| expression MINUS expression { 
				$<place>$ = newtemp();
				gen(MINUSOP,$<place>1, $<place>3, $<place>$);
				}

	| expression DIVIDE expression { 
				$<place>$ = newtemp();
				gen(DIVIDEOP,$<place>1, $<place>3, $<place>$);
				}
	| LPAREN expression RPAREN {
				$<place>$ = yylval.place;
				}

	;

B	
 :TEXT RELOP TEXT 		{
				gen($<ival>2, $1, $3, VOID);
				gen(GOTO, VOID, VOID, VOID);
				$$.true = makelist(nextquad -2);
				$$.false = makelist(nextquad - 1);
				}
	| TEXT RELOP DIGIT 		{
				gen($<ival>2, $1, $3, VOID);
				gen(GOTO, VOID, VOID, VOID);
				$$.true = makelist(nextquad -2);
				$$.false = makelist(nextquad - 1);
				}
     |  B AND M B		{
				 
				backpatch($1.true,$3);
				$$.true = $4.true;
				$$.false = merge($1.false, $4.false);
				 
				}
	|  B OR M B		{
				; 
				backpatch($1.true,$3);
				$$.true = $4.true;
				$$.false = merge($1.false, $4.false);
				
				}
	|  NOT B		{
				$$.true = $2.false;
				$$.false = $2.true;
				}
     |  LPAREN B RPAREN		{
				$$.true = $2.true;
				$$.false = $2.false;
				}

     ;
S: TEXT ASSIGN expression 		{
				gen(ASSIGN, $<place>3, VOID, $1);
				$$ = NULL;
				}
     |   IF B THEN M S ELSE N M S M ENDTIF {
				
				backpatch($2.true, $4);
				backpatch($2.false, $8);
				tmplist = merge($5, $7);
				$$ = merge(tmplist, $9);
				
				}
	 |   IF B THEN M S M ENDTIF  {
				backpatch($2.true, $4);
				backpatch($2.false, $6);
			
			
				}

	|   WHILE B LOOP M S M ENDTLOOP QUOT {
			
			
				backpatch($2.true, $4);
				backpatch($2.false, $6);
			
				
				}
	| LOOP M L UNTIL B N M L ENDTLOOP QUOT {
				 

				backpatch($5.true, $2);
				backpatch($5.false, $7);
				tmplist = merge($3, $6);
				$$ = merge(tmplist, $8);
				
				}
	| input_statement
	| output_statement
	| TEXT: IF TEXT LESS TEXT		{
				gen(ASSIGN, $<place>3, VOID, $1);
				$$ = NULL;
				}
   
	| S S
     ;


M:				{$$ = nextquad;}
     ;
N:				{gen(GOTO, VOID, VOID, VOID);
			 	$$ = makelist(nextquad - 1);
				}
     ;


input_statement
	: INPUT identifier_list QUOT
	;

output_statement
	: OUTPUT identifier_list QUOT
	;
identifier 
	: TEXT    
	;
digit
	: DIGIT
	;
identifier_list
	: identifier  
	| identifier COMMA identifier
	;
comparsion
	: LPAREN operand comparsion_operator operand RPAREN
	;

operand 
	: DIGIT
	| identifier
	| LPAREN expression RPAREN
	;
comparsion_operator
	: RELOP
	;
end 
	: ENDT
	;
%%



void yyerror(char *s)
{
   extern int yylineno;  // defined and maintained in lex
   extern char *yytext;  // defined and maintained in lex
   fprintf(stderr, "ERROR: %s at symbol '%s' on line %d\n", s,
           yytext, yylineno);
}


void 
dumplist(LIST  p)
{
   printf("{");
   while (p != NULL){
        printf("%d, ", p->quadnum);
	p = p -> link;
   }
   printf("}");
}

void
dl(char *label, LIST p){
    printf("%s", label);
    dumplist(p);
}

LIST makelist(int  q)
{
   LIST    tmp;
   void    *malloc();
   tmp = (LISTNODE *) malloc(sizeof (LISTNODE));
   tmp -> quadnum = q;
   return(tmp);
}

void 
backpatch(LIST  p, int q)
{
   

   while (p != NULL){
        if(backpatch_verbose) 
	target[p->quadnum] = (LISTNODE *) q;
	p = p -> link;
   }
   
}

LIST  merge(LIST  p1, LIST p2)
{
   LIST  tmp;
   tmp = p1;
   if (tmp == NULL) return(p2);
   while((tmp->link) != NULL){
	tmp = tmp -> link;
   }
   tmp -> link = p2;
   return(p1);
}

char *
newtemp(){
   static int number = 0;
   char s[32];
   char *retval;

   sprintf(s,"#tmp%d",number);
/*   printf("\nNEWTEMP  %s",s);	*/
   number = number + 1;
   retval = strdup(s);
   return(retval);
}



gen(int op, char *p1, char *p2, char *r)
{

    opcode[nextquad] = op;
    op1[nextquad] = p1;
    op2[nextquad] = p2;
    target[nextquad] = r;
    nextquad = nextquad + 1;
}

dumpcode(){
    int i;
    printf("\nDumping code generated to this point:");
    for(i = 0; i < nextquad; ++i){
       printf("\n");
       printf("%d\t", i);
       switch (opcode[i]){
       case ADDOP:
       		 printf("ADD\t");
	      	 printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
	      break;
       case MULTOP:
	         printf("MULT\t");
	      	 printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
	      break;
	   case MINUSOP:
	         printf("MINUS\t");
	      	 printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
	      break;
       case AND:
	         printf("AND\t");
	      	 printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
	      break;
       case ASSIGN:
	         printf("ASSIGN\t");
	      	 printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
	      break;
	   case LIVE:
	         printf("LIVE\t");
	      	 printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
	      break;
       case GOTO:
	         printf("GOTO\t");
	      	 if(target[i] != VOID)
		    printf("%s\t%s\t%d", op1[i], op2[i], target[i]);
	      	 else printf("%s\t%s\tVOID", op1[i], op2[i]);
	      break;
       case LT:
	         printf("if <\t");
	      	 if(target[i] != VOID)
		    printf("%s\t%s\t%d", op1[i], op2[i], target[i]);
	      	 else printf("%s\t%s\tVOID", op1[i], op2[i]);
	      break;
	   case GT:
	        printf("if >\t");
	   		 if(target[i] != VOID)
		    printf("%s\t%s\t%d", op1[i], op2[i], target[i]);
	      	 else printf("%s\t%s\tVOID", op1[i], op2[i]);
	      break;
       default:
	      printf("Error in OPcode Field");
	      printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
       }

    }
}
