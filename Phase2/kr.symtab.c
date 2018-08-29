#define ENDSTR 0
#define MAXSTR 100
#include <stdio.h>
#include <string.h>
int nextquad = 1;


struct nlist { /* basic table entry */
	char *name;
		int val;
	struct nlist *next;	/*next entry in chain */
	struct nlist *tnext;	/*next entry for settype */
		int typ;
};

#define	HASHSIZE	1117
static struct nlist *hashtab[HASHSIZE];	/* pointer table */
/*
FUNCTION: HASH
PURPOSE: Hash determines hash value based on the sum of the 
	 character values in the string. 
USAGE:  n = hash(s);
DESCRIPTION OF PARAMETERS: s(array of char) string to be hashed
AUTHOR:  Kernighan and Ritchie
LAST REVISION: 12/11/83
*/
int
hash(char *s)		/* form hash value for string s */
{
	int hashval;

	for (hashval = 0;  *s != '\0'; )
		hashval += *s++;
	return (hashval % HASHSIZE);
}
/*
FUNCTION: LOOKUP
PURPOSE: Lookup searches for entry in symbol table and returns a pointer
USAGE:  np= lookup(s);
DESCRIPTION OF PARAMETERS: s(array of char) string  searched for
AUTHOR:  Kernighan and Ritchie
LAST REVISION: 12/11/83
*/

struct nlist *lookup(char *s)  /* look for s in hashtab */
{
	struct nlist *np;

	for (np = hashtab[hash(s)]; np != NULL; np = np->next)
		if (strcmp(s, np->name) == 0)
			return(np);		/* found it */
	return(NULL);		/* not found */
}
/*
FUNCTION: INSTALL
PURPOSE: Install checks hash table using lookup and if entry not found,
	 it "installs" the entry.
USAGE:  np = install(name); 
DESCRIPTION OF PARAMETERS: name(array of char) name to install in 
symbol table
AUTHOR:  Kernighan and Ritchie, modified by Ron Sobczak
LAST REVISION: 12/11/83, 2018 MMM
*/

struct nlist *install(char *name)		/* put (name) in hashtab */
{
	struct nlist *np, *lookup();
	char *strdup(); 
        void *malloc();
	int hashval;

	if ((np = lookup(name))  == NULL) {	/* not found */
		np = (struct nlist *) malloc(sizeof(*np));
		if (np == NULL)
			return(NULL);
		if ((np->name = strdup(name)) == NULL)
			return(NULL);
		hashval = hash(np->name);
		np->next = hashtab[hashval];
		hashtab[hashval] = np;
		np->tnext = NULL;
		np->typ = 0; // Type not yet defined!
	}
	return(np);
}


/*
FUNCTION: STRSAVE
PURPOSE: Strsave makes sure there is space allocated for the
	 string being saved.
USAGE:  ptr = strsave(s);
DESCRIPTION OF PARAMETERS: s(array of char) name to save
AUTHOR:  Kernighan and Ritchie, modified by Ron Sobczak
LAST REVISION: 12/11/83
*/

char *strsave(char *s)		/* save string s somewhere */
{
	char *p;
	void  *malloc();

	if ((p = (char *) malloc((unsigned) strlen(s) + 1)) != NULL)
		strcpy(p,s);
	return(p);
}

void
dumptable(){
   
    struct nlist *bucket;
    int bucketIndex;

    printf("SYMBOL_TABLE\n");
    for(bucketIndex=0; bucketIndex < HASHSIZE; bucketIndex++){
	bucket = hashtab[bucketIndex];
	while(bucket != NULL){
	    printf("%s\n", bucket->name);
	    bucket = bucket->next;
	}
    }
}


