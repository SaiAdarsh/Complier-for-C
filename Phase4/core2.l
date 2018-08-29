%option yylineno
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
%}
%option yylineno
digit [0-9]+
real		[0-9]+\.(E(\-|"+")?(0-9)+)?
string		(\"[^\"^\n]*\")|(\'[^\'^\n]\')

%%
\n 			{ }
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
"<"      { yylval.ival = 1; return(RELOP); }
"="      { yylval.ival =2; return(RELOP); }
">"      { yylval.ival =3; return(RELOP); }
"<="     { yylval.ival =4; return(RELOP); }
"!="     { yylval.ival =5; return(RELOP); }
">="     { yylval.ival =6; return(RELOP); }



";"  		return(QUOT); 
":="		return(ASSIGNOP);
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
"&&"		return(AND);
"||"		return(OR);
"!"			return(NOT);
"loop"		return(LOOP);
"until"		return(UNTIL);
"endif"		return(ENDTIF);
"endloop"		return(ENDTLOOP);
[a-zA-Z_][a-zA-Z_]*   {if((tmp=lookup(yytext)) == NULL)
            				{tmp=install(strdup(yytext));}
                         		yylval.place = strdup(yytext); 
			 return(TEXT);
                       		}
{digit} 	 {
					if((tmp=lookup(yytext)) == NULL)
            				{tmp=install(strdup(yytext));}
                         		yylval.ival = strdup(yytext); return(DIGIT);
		       }


%%

int yywrap(){

}
