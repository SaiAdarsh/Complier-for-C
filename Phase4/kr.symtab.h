#define ENDSTR 0
#define MAXSTR 100
#include <stdio.h>

struct nlist { 			/* basic table entry */
	char *name;
	int val;
	struct nlist *next;	/*next entry in chain */
	struct nlist *tnext;	/*next entry for settype */
		
};


extern struct nlist *hashtab[];	/* pointer table */

int hash(char *); 		/* form hash value for string s */
struct nlist *lookup(char *);  	/* look for s in hashtab */
struct nlist *install(char *);	/* put (name) in hashtab */

char *strsave(char *);		/* save string s somewhere */
void dumptable();		/* save string s somewhere */
