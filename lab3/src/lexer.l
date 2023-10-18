%option noyywrap
%top{
    #include <ostream>
    #include <fstream>
    #include <math.h>
    using namespace std;
    extern FILE *yyin;
    extern FILE *yyout;
}
%{
    int chars = 0, words = 0, lines = 0;
    struct node {
        char name[64];
        node* prev, * next;
    };
    struct id_table{
        node* head, * tail;
        int count;
    };
    id_table idtable;
    void init_idtable{
        idtable.head = (node*)malloc(sizeof(node));
        idtable.head -> next = idtable.head -> prev = nullptr;
        idtable.tail = idtable.head;
        idtable.count = 0;
    }
    node* add_id(char* s){
        node* id = (node*)malloc(sizeof(node));
        strcpy(id->name, s);
        idtable.tail->next = id;
        id->prev = idtable.tail;
        idtable.next = nullptr;
        idtable.tail = id;
        idtable.count++;
        return id;
    }

    node* search_id(char* s){
        node* id = nullptr;
        id = add_id(s);
        return id;
    }

    void print_str(string s){
        string info = "\t" + s + "\t" + to_string(yylineno) + "\n";
        fputs(info.c_str(), yyout);
    }
    void print_id(node* id){
        char* info = new char[512];
        sprintf(info, "\t%s\t%s\t%d\t%p\n", "IDENTIFIER", yytext, yylineno, id);
        fputs(info, yyout);
        delete info;
    }
%}

/* definitions section */
DECIMIAL ([1-9][0-9]*|0)
OCTAL (0[0-7]+)
HEXADECIMAL (0[xX][0-9a-fA-F]+)

ID [a-zA-Z_][a-zA-Z0-9_]*
EOL (\r\n|\n|\r)
WHITE [\t ]

%x COMMENT
COMMENTBEGIN \/\*
COMMENTELEMENT .|\n
COMMENTEND \*\/
LINECOMMENT \/\/[^\n]*

%%
    /* rules section */
"int" {print_str("INT\tint");}

"void" {print_str("VOID\tvoid");}

"const" {print_str("CONST\tconst");}

"if" {print_str("IF\tif");}

"else" {print_str("ELSE\telse");}

"while" {print_str("WHILE\twhile");}

"for" {print_str("FOR\tfor");}

"break" {print_str("BREAK\tbreak");}

"continue" {print_str("CONTINUE\tcontinue");}

"return" {print_str("RETURN\treturn");}

"=" {print_str("ASSIGN\t=");}

"==" {print_str("EQUAL\t==");}

"!=" {print_str("NOTEQUAL\t!=");}

"<" {print_str("LESS\t<");}

">" {print_str("GREATER\t>");}

"<=" {print_str("LESSEQUAL\t<=");}

">=" {print_str("GREATEREQUAL\t>=");}

"+" {print_str("ADD\t+");}

"-" {print_str("SUB\t-");}

"*" {print_str("MUL\t*");}

"/" {print_str("DIV\t/");}

"%" {print_str("MOD\t%");}

"&&" {print_str("AND\t&&");}

"||" {print_str("OR\t||");}

"!" {print_str("NOT\t!");}

";" {print_str("SEMICOLON\t;");}

":" {print_str("COLON\t:");}

"," {print_str("COMMA\t,");}

"(" {print_str("LPAREN\t(");}

")" {print_str("RPAREN\t)");}

"[" {print_str("LBRACKET\t[");}

"]" {print_str("RBRACKET\t]");}

"{" {print_str("LBRACE\t{");}

"}" {print_str("RBRACE\t}");}

{DECIMIAL} {
    print_str(string("NUMBER\t") + string(yytext));
    words++;
    chars += strlen(yytext);
}

{OCTAL} {
    int num;
    sscanf(yytext, "%o", &num);
    print_str(string"NUMBER\t" + to_string(num));
    words++;
    chars += strlen(yytext);
}

{HEXADECIMAL} {
    int num;
    sscanf(yytext, "%x", &num);
    print_str(string"NUMBER\t" + to_string(num));
    words++;
    chars += strlen(yytext);
}

{ID} {
    string str = yytext;
    node* id = search_id(str);
    print_id(id);
    words++;
    chars += strlen(yytext);
}

{EOL} {lines++;}

{WHITE} {}

. {chars++;}

{LINECOMMENT} {}
{COMMENTBEGIN} {BEGIN COMMENT;}
<COMMENT>{COMMENTELEMENT} {}
<COMMENT>{COMMENTEND} {BEGIN INITIAL;}

%%
/* user code section */

int main(int argc, char **argv){
    if(argc>1){
        yyin = fopen(argv[1], "r");
        if(argc>2){
            yyout = fopen(argv[2], "w");
        }
    }
    init_idtable();
    yylex();
    fprintf(yyout, "%8d%8d%8d%8d\n", lines, words, chars);
    return 0;
}