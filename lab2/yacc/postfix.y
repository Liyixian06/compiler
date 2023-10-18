%{
/*********************************************
中缀转后缀表达式
YACC file
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
#ifndef YYSTYPE
#define YYSTYPE char*
#endif
  
char idStr[50];
char numStr[50];
  
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

%token ADD MINUS TIMES DIVIDE
%token NUMBER ID

%left ADD MINUS
%left TIMES DIVIDE
%right UMINUS         

%%


lines   :       lines expr ';' { printf("%s\n", $2); }
        |       lines ';'
        |
        ;

expr    :       expr ADD expr   {  $$ = (char *)malloc(50 * sizeof(char)); strcpy($$, $1); strcat($$, $3); strcat($$, "+ "); }
        |       expr MINUS expr   {  $$ = (char *)malloc(50 * sizeof(char)); strcpy($$, $1); strcat($$, $3); strcat($$, "- "); }
        |       expr TIMES expr   {  $$ = (char *)malloc(50 * sizeof(char)); strcpy($$, $1); strcat($$, $3); strcat($$, "* "); }
        |       expr DIVIDE expr   {  $$ = (char *)malloc(50 * sizeof(char)); strcpy($$, $1); strcat($$, $3); strcat($$, "/ "); }
		|       '(' expr ')'    { $$ = (char *)malloc(50 * sizeof(char)); strcpy($$, $2); }
        |       MINUS expr %prec UMINUS   { $$ = (char *)malloc(50 * sizeof(char)); strcpy($$, "-"); strcpy($$, $2); }
        |       NUMBER  { $$ = (char *)malloc(50 * sizeof(char)); strcpy($$, $1); strcat($$," ");}
        |       ID  {  $$ = (char *)malloc(50 * sizeof(char)); strcpy($$, $1); strcat($$," ");}
        ;

%%

// programs section

int yylex()
{
    int t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){
            //do nothing
        }else if(t>='0' && t<='9'){
      		int idx=0;
      		while(t>='0' && t<='9'){
          		numStr[idx]=t;
          		t=getchar();
                idx++;
      		}
            numStr[idx]='\0';
            yylval = numStr;
        	ungetc(t,stdin);
        	return NUMBER;
        }else if(t>='a'&& t<='z'||t>='A'&& t<='Z'||t=='_'){
            int idx=0;
            while(t>='a'&& t<='z'||t>='A'&& t<='Z'||t=='_'){
                idStr[idx]=t;
                t=getchar();
                idx++;
            }
            idStr[idx]='\0';
            yylval = idStr;
            ungetc(t,stdin);
            return ID;
        }else if(t=='+'){
            return ADD;
        }else if(t=='-'){
            return MINUS;
        }else if(t=='*'){
            return TIMES;
        }else if(t=='/'){
            return DIVIDE;
        }else{
            return t;
        }
    }
}

int main(void)
{
    yyin=stdin;
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}
