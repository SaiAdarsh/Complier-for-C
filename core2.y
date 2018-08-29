%{
yydebug=1;
%}
%token DIGIT TIMES PLUS LPAREN RPAREN INT QUOT TEXT EQUALS COMMA COLON PROGRAM BEGINT ENDT INPUT OUTPUT

%%

program
	: PROGRAM 
	| program declaration begin statements end QUOT {printf("core2 program is recognised");
					 exit(0);
					}
	;


declaration	
	: type_specifier COLON init_declarator_list QUOT      
	;


init_declarator_list 
	: init_declarator  
	| init_declarator_list COMMA init_declarator 
	;

init_declarator
	: variable 
	| variable EQUALS DIGIT  
	;
	
type_specifier	
	:	INT
	;

begin 
	: BEGINT
	;
 
	;
statements
	: assign_statement
	| input_statement
	| output_statement
	| statements assign_statement
	| statements input_statement
	| statements output_statement
	;

assign_statement 
	: variable COLON EQUALS terms QUOT 
	;
	
terms : variable
	| terms PLUS terms
	| terms TIMES terms
	; 

end 
	: ENDT
	;
variable 
	: TEXT    
	;

input_statement
	: input identifier QUOT
output_statement
	: output identifier QUOT

input 
	: INPUT
	;
identifier
	: init_declarator  
	| identifier COMMA init_declarator

output 
	: OUTPUT
	;
%%