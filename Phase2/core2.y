%{
#include <ctype.h>
#include "core2.tab.h"
#include <stdio.h>
#define YYDEBUG 1
#define ADDOP  301
#define MULTOP 302
#define MINUSOP 303
#define DIVIDEOP 304
#include "kr.symtab.h"
#define INT_TYPE 1000

extern char *yytext;
char *newtemp();
void gen(int, char *, char *, char *);

void yyerror(char *s);
int yylex(void);
%}

%union{
     char *place;
     int  ival;
}

%type <place> expression
%type <place> identifier
%token <ival> DIGIT
%token <place> TEXT
%token DEBUG
%left PLUS MINUS
%left TIMES DIVIDE


%token TIMES PLUS LPAREN RPAREN INT QUOT EQUALS COMMA COLON PROGRAM BEGINT ENDT INPUT OUTPUT WHILE IF ELSE MINUS DIVIDE RELOP THEN FLOAT DOUBLE OCURLY CCURLY ASSIG

%%
task:
	task program ';' 		{
				 printf("\nEND \n");
				}
    |   task ';'
    |   task DEBUG ';'		{ if(yydebug == 0) yydebug=1; else yydebug = 0;}
    |    /* epsilon */
    ;

program
	: PROGRAM 
	| program declaration begin statements end QUOT {printf("core2 program is recognised");
					 exit(0);
					}
	;
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
	| varlist COMMA identifier 
	;
/*statements part */
statements
	: assign_statement
	| if_statement
	| loop_statement
	| input_statement
	| output_statement
	| statements assign_statement
	| statements if_statement
	| statements loop_statement
	| statements input_statement
	| statements output_statement
	;
assign_statement 
	: identifier ASSIG expression QUOT 
	;
expression 
	: identifier {if(lookup($1)->val == INT)
	{
		$<ival>$ = yylval.ival;
	}
				else
					{
					yyerror("Variable not declard");

					}
				}
				
	| digit {
				
				}
	| expression PLUS expression { 
				$$ = newtemp();
				gen(ADDOP,$1, $3, $$);
				}
	| expression TIMES expression { 
				$$ = newtemp();
				gen(MULTOP,$1, $3, $$);
				}
	| expression MINUS expression { 
				$$ = newtemp();
				gen(MINUSOP,$1, $3, $$);
				}	
	| expression DIVIDE expression {  
				$$ = newtemp();
				gen(DIVIDEOP,$1, $3, $$);
				}	
	| LPAREN expression RPAREN {
				$<place>$ = yylval.place;
				}
	; 	
if_statement 
	: IF comparsion THEN OCURLY statements CCURLY ENDT IF QUOT
	| IF comparsion THEN OCURLY statements CCURLY ELSE OCURLY statements CCURLY ENDT IF QUOT
	;
loop_statement
	: WHILE comparsion statements ENDT QUOT
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

char *
newtemp(){
   static int number = 0;
   char s[32];
   char *retval, *strdup();

   sprintf(s,"#T%d",number);
/*   printf("\nNEWTEMP  %s",s);	*/
   number = number + 1;
   retval = strdup(s);
   return(retval);
}

void 
gen(int op, char *p1, char *p2, char *r)
{
    static int quadnumber = 0;

    quadnumber = quadnumber + 1;
    putchar('\n');
    printf("%d\t", quadnumber);
    switch (op){
    case ADDOP:
	      printf("ADD\t");
	   break;
    case MULTOP:
	      printf("MULT\t");
	   break;
	case MINUSOP:
	      printf("MINUS\t");
	   break;
	case DIVIDEOP:
	      printf("DIVIDE\t");
	   break;
    default:
	   printf("Error in OPcode Field");
    }

    printf("%s\t", p1);
    printf("%s\t", p2);
    printf("%s\t", r);
}

void yyerror(char *s)
{
   extern int yylineno;  // defined and maintained in lex
   extern char *yytext;  // defined and maintained in lex
   fprintf(stderr, "ERROR: %s at symbol '%s' on line %d\n", s,
           yytext, yylineno);
}


struct Table
{
	char id[20];
	char type[10];
}table[10000];
int tableCount=0;
int i=0;

check()
{
	char temp[20];
	strcpy(temp,yytext);
	int flag=0;
	for(i=0;i<tableCount;i++)
	{
		if(!strcmp(table[i].id,temp))
		{
			flag=1;
			break;
		}
	}
	if(!flag)
	{
		yyerror("Variable not declard");
		exit(0);
	}
}


