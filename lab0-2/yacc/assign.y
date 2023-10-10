%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等空白符，能识别多位十进制整数。
YACC file
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>

struct symbol_table_entry
{
    char *id;
    double value;
} symbol_table[64];
char idStr[50];
int symbolNum=0;

int search_symbol(char* string);
void add_symbol(char* string);

int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

%union{
    double num;
    struct symbol_table_entry *ident;
}

%type <num> expr
%type <num> assign

%token ADD MINUS TIMES DIVIDE
%token <num> NUMBER
%token <ident> ID

%right ASSIGN
%left ADD MINUS
%left TIMES DIVIDE
%right UMINUS         

%%


lines   :       lines expr ';' { printf("%f\n", $2); }
	|	lines assign ';' { printf("%f\n", $2); }
        |       lines ';'
        |
        ;

expr    :       expr ADD expr   { $$=$1+$3; }
        |       expr MINUS expr   { $$=$1-$3; }
        |       expr TIMES expr   { $$=$1*$3; }
        |       expr DIVIDE expr   { $$=$1/$3; }
	|       '(' expr ')'    { $$=$2;}
        |       MINUS expr %prec UMINUS   {$$=-$2;}
        |       NUMBER  {$$=$1;}
        |       ID  {$$=$1->value;}
        ;

assign	:       ID ASSIGN assign {$$=$1->value=$3;}
	|       ID ASSIGN expr {$$=$1->value=$3;}
        ;

%%

// programs section

int search_symbol(char* string){
    for(int i=0;i<symbolNum;i++){
        if(strcmp(symbol_table[i].id, string)==0)
            return i+1;
    }
    return 0;
}

void add_symbol(char* string){
    if(symbolNum>=64){
        fprintf(stderr, "The symbol table is full.\n");
        exit(1);
    }

    symbol_table[symbolNum].id = (char*)malloc(50*sizeof(char));
    strcpy(symbol_table[symbolNum].id, string);
    symbol_table[symbolNum].value = 0;
    symbolNum++;
}

int yylex()
{
    int t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){
            //do nothing
        }else if(isdigit(t)){
      		yylval.num=0;
      		while(isdigit(t)){
          	    yylval.num = yylval.num*10+t-'0';
          	    t=getchar();
      		}
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
            int pos = search_symbol(idStr);
            if(pos==0){
                add_symbol(idStr);
                yylval.ident = &symbol_table[symbolNum-1];
            }
            else{
            	yylval.ident = &symbol_table[pos-1];
            }
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
        }else if(t=='='){
            return ASSIGN;
        }else{
            return t;
        }
    }
}

int main(void)
{
    yyin=stdin;
    struct symbol_table_entry *symbol_table = (struct symbol_table_entry*)malloc(64*sizeof(struct symbol_table_entry));
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char* s)
{
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}
