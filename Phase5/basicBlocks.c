
#include <stdio.h>

/* opcode Defines
 * ASSIGN	10
 * ADD	11
 * MULT	12
 * SUB	13
 * GOTO	14
 * if=	15
 * if>	16
 * print	17
 * live	18
 * end  19
 */

char *opcodeName[]={
"","","","","","","","","","",    // NULL for 0-9      
"ASSIGN",
"ADD",
"MULT",
"SUB",
"GOTO",
"if=",
"if>",
"print",
"live",
"end"
};


int
main(){

   int quad;
   int opcode;
   char operand1[32];
   char operand2[32];
   char result[32];
   int	branchTarget;

   int retValue; // should always be 6, the number of things read in each scanf


   do{
	retValue = scanf("%d %d %s %s %s %d\n", &quad, &opcode, operand1, operand2, result, &branchTarget);
        printf("quad=%d\t%s\t%s\t%s\t%s\t%d\n", quad, opcodeName[opcode], operand1, operand2, result, branchTarget);
   }while (opcode != 19);
}
