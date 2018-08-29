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
#define CALL 7
#define PROMOTECHAR 8
#define ADDCHAR 9
#define CALL 10
#define RET 11
#define PROLOGUE 12
#define EPILOGUE 13


#define YYDEBUG 1
#include "kr.symtab.h"
#define INT_TYPE 1000
#define CHAR_TYPE 2000
#define CODESIZE 3000

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


%token TIMES PLUS LPAREN RPAREN QUOT EQUALS COMMA COLON PROGRAM BEGINT ENDT INPUT OUTPUT WHILE IF ELSE MINUS DIVIDE THEN  OCURLY CCURLY  AND OR NOT ASSIGNOP LT GT EQ LTE NE GTE LOOP UNTIL ENDTIF ENDTLOOP CHAR LSQUARE RSQUARE  POINT
%%

program
	: PROGRAM 
	| program declaration begin L end QUOT {
				 dumpcode();
				 printf("\nEND \n");
				 exit(0);
				 }
	| program fundec declaration begin L end QUOT {
				 dumpcode();
				 printf("\nEND \n");
				 exit(0);
				 }
	;

fundec : type TEXT LPAREN parameter_list RPAREN OCURLY declaration L CCURLY {
				gen(PROLOGUE,VOID,VOID,VOID);
				gen(EPILOGUE,VOID,VOID,VOID);
				 }
		; 
parameter_list
	: type identifier
	| parameter_list COMMA parameter_list
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
	: direct_declaration
	| declaration declaration
	;
direct_declaration 
	: type COLON identifier 
	| type COLON TIMES identifier 
	| direct_declaration COMMA identifier
	| direct_declaration QUOT
	| direct_declaration direct_declaration
	;
type
	: INT
	| CHAR 
	;
identifier 
	: TEXT    
	| TIMES identifier
	| identifier LSQUARE digit RSQUARE
	;
digit
	: DIGIT
	;
identifier_list
	: identifier  
	| identifier_list COMMA identifier_list
	| 
	;


expression 
	: identifier
	{
				$<place>$ = yylval.place;
	}
						
	| digit {
				$<ival>$ = yylval.ival;
				}
	| expression PLUS expression if($1->type ==INT_TYPE && $3->type==INT_TYPE)
				{ 
				$<place>$ = newtemp();
				gen(ADDOP,$<place>1, $<place>3, $<place>$);
				$<place>$->typ=INT_TYPE;
				}
				else if($1->type ==CHAR_TYPE && $3->type==CHAR_TYPE)
				{ 
				$<place>$ = newtemp();
				gen(ADDCHAR,$<place>1, $<place>3, $<place>$);
				$<place>$->typ=CHAR_TYPE;
				gen(ADDOP,$<place>1, $<place>3, $<place>$);
				}
				else if($1->type ==INT_TYPE && $3->type==CHAR_TYPE)
				{	 
				$<place>$ = newtemp();
				gen(PROMOTECHAR,$<place>3,void, $<place>$);
				$<place>3->typ=INT_TYPE;
				tmp_result = newtemp();
				gen(ADDOP,$<place>1, $<place>3.place, tmp_result.place);
				}
				else ($1->type ==CHAR_TYPE && $3->type==INT_TYPE)
				{	 
				$<place>$ = newtemp();
				gen(PROMOTECHAR,$<place>1, void, $<place>$);
				$<place>1->typ=INT_TYPE;
				tmp_result = newtemp();
				gen(ADDOP,$<place>3, $<place>3.place, tmp_result.place);
				}
	| expression TIMES expression 
				if($1->type ==INT_TYPE && $3->type==INT_TYPE)
				{ 
				$<place>$ = newtemp();
				gen(MULTOP,$<place>1, $<place>3, $<place>$);
				$<place>$->typ=INT_TYPE;

				}
				else if($1->type ==CHAR_TYPE && $3->type==CHAR_TYPE)
				{ 
				$<place>$ = newtemp();
				gen(ADDCHAR,$<place>1, $<place>3, $<place>$);
				$<place>$->typ=CHAR_TYPE;
				gen(MULTOP,$<place>1, $<place>3, $<place>$);
				}
				else if($1->type ==INT_TYPE && $3->type==CHAR_TYPE)
				{	 
				$<place>$ = newtemp();
				gen(PROMOTECHAR,$<place>3,void, $<place>$);
				$<place>3->typ=INT_TYPE;
				tmp_result = newtemp();
				gen(MULTOP,$<place>1, $<place>3.place, tmp_result.place);
				}
				else ($1->type ==CHAR_TYPE && $3->type==INT_TYPE)
				{	 
				$<place>$ = newtemp();
				gen(PROMOTECHAR,$<place>1, void, $<place>$);
				$<place>1->typ=INT_TYPE;
				tmp_result = newtemp();
				gen(MULTOP,$<place>3, $<place>3.place, tmp_result.place);
				}
	| expression MINUS expression if($1->type ==INT_TYPE && $3->type==INT_TYPE)
				{ 
				$<place>$ = newtemp();
				gen(MINUSOP,$<place>1, $<place>3, $<place>$);
				$<place>$->typ=INT_TYPE;

				}
				else if($1->type ==CHAR_TYPE && $3->type==CHAR_TYPE)
				{ 
				$<place>$ = newtemp();
				gen(ADDCHAR,$<place>1, $<place>3, $<place>$);
				$<place>$->typ=CHAR_TYPE;
				gen(MINUSOP,$<place>1, $<place>3, $<place>$);
				}
				else if($1->type ==INT_TYPE && $3->type==CHAR_TYPE)
				{	 
				$<place>$ = newtemp();
				gen(PROMOTECHAR,$<place>3,void, $<place>$);
				$<place>3->typ=INT_TYPE;
				tmp_result = newtemp();
				gen(MINUSOP,$<place>1, $<place>3.place, tmp_result.place);
				}
				else ($1->type ==CHAR_TYPE && $3->type==INT_TYPE)
				{	 
				$<place>$ = newtemp();
				gen(PROMOTECHAR,$<place>1, void, $<place>$);
				$<place>1->typ=INT_TYPE;
				tmp_result = newtemp();
				gen(MINUSOP,$<place>3, $<place>3.place, tmp_result.place);
				}

	| expression DIVIDE expression if($1->type ==INT_TYPE && $3->type==INT_TYPE)
				{ 
				$<place>$ = newtemp();
				gen(DIVIDEOP,$<place>1, $<place>3, $<place>$);
				$<place>$->typ=INT_TYPE;

				}
				else if($1->type ==CHAR_TYPE && $3->type==CHAR_TYPE)
				{ 
				$<place>$ = newtemp();
				gen(ADDCHAR,$<place>1, $<place>3, $<place>$);
				$<place>$->typ=CHAR_TYPE;
				gen(DIVIDEOP,$<place>1, $<place>3, $<place>$);
				}
				else if($1->type ==INT_TYPE && $3->type==CHAR_TYPE)
				{	 
				$<place>$ = newtemp();
				gen(PROMOTECHAR,$<place>3,void, $<place>$);
				$<place>3->typ=INT_TYPE;
				tmp_result = newtemp();
				gen(DIVIDEOP,$<place>1, $<place>3.place, tmp_result.place);
				}
				else ($1->type ==CHAR_TYPE && $3->type==INT_TYPE)
				{	 
				$<place>$ = newtemp();
				gen(PROMOTECHAR,$<place>1, void, $<place>$);
				$<place>1->typ=INT_TYPE;
				tmp_result = newtemp();
				gen(DIVIDEOP,$<place>3, $<place>3.place, tmp_result.place);
				}
	| LPAREN expression RPAREN {
				$<place>$ = yylval.place;
				}

	| TEXT LPAREN identifier_list LPAREN {
				p=$3.list;
				while(p!=NULL)
				{
					gen(push, -, -,p->place);
						p = p->link;
					     } 
					  gen (call, -, -, ID.place);

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
S: TEXT ASSIGNOP expression QUOT		{
				gen(ASSIGNOP, $<place>3, VOID, $1);
				$$ = NULL;
				}
     |   IF B THEN M S ELSE N M S M ENDTIF QUOT{
				
				backpatch($2.true, $4);
				backpatch($2.false, $8);
				tmplist = merge($5, $7);
				$$ = merge(tmplist, $9);
				
				}
	 |   IF B THEN M S M ENDTIF QUOT {
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
       case ASSIGNOP:
	         printf("ASSIGN\t");
	      	 printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
	      break;
	    case PROMOTECHAR:
	         printf("PROMOTE CHAR\t");
	      	 printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
	      break;
	    case ADDCHAR:
	         printf("ADDING CHAR\t");
	      	 printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
	      break;
	    case CALL:
	         printf("CALL\t");
	      	 printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
	      break;
	    case RET:
	         printf("RETURN\t");
	      	 printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
	      break;
	    case PROLOGUE:
	         printf("PROLOGUE\t");
	      	 printf("%s\t%s\t%s", op1[i], op2[i], target[i]);
	      break;
	    case EPILOGUE:
	         printf("EPILOGUE\t");
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
