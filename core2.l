
%{
#include "core2.tab.h"
#include <stdio.h>
struct nlist *tmp; 
%}


digit [0-9]+

%%

"int" 		return(INT);
"program" 	return(PROGRAM);
"begin" 	return(BEGINT);
"end" 		return(ENDT);
"input"		return(INPUT);
"output"	return(OUTPUT);
[a-z]+		return(TEXT);
[a-zA-Z_][a-zA-Z_]*  {if((tmp=lookup(yytext)) == NULL)
						  {tmp=install(yytext); }    		
                         		yylval = tmp;
                         		return(TEXT);
                       		}
";"  		return(QUOT); 
"=" 		return(EQUALS);
"," 		return(COMMA);
":" 		return(COLON);
\+			return(PLUS);
\*			return(TIMES);
\(			return(LPAREN);
\)			return(RPAREN);
{digit} 	return(DIGIT);
%%

int yywrap(){

}
