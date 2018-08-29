%{
#include "core2.tab.h"
#include <stdio.h>
#include <ctype.h>

struct hashlist{
	char *name;
	int  val;
	struct hashlist *next;
	struct hashlist *tnext;
	} *tmp;
extern struct hashlist *lookup();
extern struct hashlist *install();
extern char *strsave();
/* int yylineno = 1; */
%}
digit [0-9]+
real		[0-9]+\.(E(\-|"+")?(0-9)+)?
string		(\"[^\"^\n]*\")|(\'[^\'^\n]\')

%%

"int" 		return(INT);
"float" 	return(FLOAT);
"double" 	return(DOUBLE);
"program" 	return(PROGRAM);
"begin" 	return(BEGINT);
"end" 		return(ENDT);
"input"		return(INPUT);
"output"	return(OUTPUT);
"while"     return(WHILE);
"if"		return(IF);
"then"		return(THEN);
"else"		return(ELSE);

[a-zA-Z_][a-zA-Z_]*   {if((tmp=lookup(yytext)) == NULL)
            				{tmp=install(strdup(yytext));}
                         		yylval.place = strdup(yytext); 
			 return(TEXT);
                       		}
"\n" { yylineno++;}
";"  		return(QUOT); 
":="		return(ASSIG);
"," 		return(COMMA);
":" 		return(COLON);
"+"			return(PLUS);
"*"			return(TIMES);
"-"			return(MINUS);
"/"			return(DIVIDE);
"("			return(LPAREN);
")"			return(RPAREN);
"{"			return(OCURLY);
"}"			return(CCURLY);
{digit} 	 {yylval.ival = strdup(yytext); 
			 return(DIGIT);
		       }
"<"      { int yylval=1; return(RELOP); }
"="      { int yylval=2; return(RELOP); }
">"      { int yylval=3; return(RELOP); }
"<="     { int yylval=4; return(RELOP); }
"!="     { int yylval=5; return(RELOP); }
">="     { int yylval=6; return(RELOP); }

%%

int yywrap(){

}
