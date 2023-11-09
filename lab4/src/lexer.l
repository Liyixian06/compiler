%option noyywrap
%option nounput
%option noinput
%option yylineno
%top{
    #include <stdarg.h>
    #include "common.h"
    #include "parser.h"
    #include <string>
    #include <math.h>
    #include <sstream>
    #include <malloc.h>
    using namespace std;

    extern FILE *yyin;
    extern FILE *yyout;
    extern bool dump_tokens;
}
%{
    extern dump_type_t dump_type;
    int chars = 0, words = 0, lines = 0, columns = 0;

    void print_str(string s){
        string info = "\t" + s + "\t" + to_string(lines) + "\t" + to_string(columns) + "\n";
        fputs(info.c_str(), yyout);
    }
    void print_num(string s, string num_str){
    	string info = "\t" + s + "\t" + to_string(lines) + "\t" + to_string(columns) + "\t" + num_str + "\n";
    	fputs(info.c_str(), yyout);
    }

    /*
    inline void dump_tokens(const char* format, ...){
        va_list args;
        va_start(args, format);
        if (dump_type == TOKENS)
            vfprintf(yyout, format, args);
        va_end(args);
    }
    */

%}

/* definitions section */
FLO [0-9]*\.[0-9]+([Ee][+-]?[0-9]+)?
OCTAL 0[0-7]+
HEXADECIMAL 0[xX][0-9a-fA-F]+
DECIMIAL [1-9][0-9]*|0

INT "int"
FLOAT "float"
VOID "void"
CONST "const"
IF "if"
ELSE "else"
WHILE "while"
BREAK "break"
CONTINUE "continue"
RETURN "return"

ID [a-zA-Z_][a-zA-Z0-9_]*
EOL (\r\n|\n|\r)
WHITE [\t ]

%x COMMENT
COMMENTBEGIN "/*"
COMMENTEOL \r\n|\n|\r
COMMENTELEMENT .
COMMENTEND "*/"
LINECOMMENT \/\/[^\n]*

%%
    /* rules section */
"int" {
    if(dump_tokens)
        print_str("INT\tint"); 
    columns += strlen(yytext);
    return INT;
}

"void" {
    if(dump_tokens)
        print_str("VOID\tvoid");
    columns += strlen(yyetxt);
    return VOID;
}

"float"{
    if(dump_tokens)
        print_str("FLOAT\tfloat");
    columns += strlen(yytext);
    return FLOAT;
}

"if" {
    if(dump_tokens)
        print_str("IF\tif"); 
    columns += strlen(yytext);
    return IF;
}

"else" {
    if(dump_tokens)
        print_str("ELSE\telse"); 
    columns += strlen(yytext);
    return ELSE;
}

"while"{
    if(dump_tokens)
        print_str("WHILE\twhile); 
    columns += strlen(yytext);
    return WHILE;
}

"for"{
    if(dump_tokens)
        print_str("FOR\tfor"); 
    columns += strlen(yytext);
    return FOR;
}

"break"{
    if(dump_tokens)
        print_str("BREAK\tbreak"); 
    columns += strlen(yytext);
    return BREAK;
}

"continue"{
    if(dump_tokens)
        print_str("CONTINUE\tcontinue"); 
    columns += strlen(yytext);
    return CONTINUE;
}
"return" {
    if(dump_tokens)
        print_str("RETURN\treturn"); 
    columns += strlen(yytext);
    return RETURN;
}

"=" {
    if(dump_tokens)
        print_str("ASSIGN\t="); 
    columns += strlen(yytext);
    return ASSIGN;
}

"=="{
    if(dump_tokens)
        print_str("EQUAL\t=="); 
    columns += strlen(yytext);
    return FOR;
}

"!="{
    if(dump_tokens)
        print_str("NOTEQUAL\t!="); 
    columns += strlen(yytext);
    return FOR;
}

"<" {
    if(dump_tokens)
        print_str("LESS\t<"); 
    columns += strlen(yytext);
    return LESS;
}

">"{
    if(dump_tokens)
        print_str("GREATER\t>"); 
    columns += strlen(yytext);
    return GREATER;
}

"<="{
    if(dump_tokens)
        print_str("LESSEQUAL\t<="); 
    columns += strlen(yytext);
    return LESSEQUAL;
}

">="{
    if(dump_tokens)
        print_str("GREATEREQUAL\t>="); 
    columns += strlen(yytext);
    return GREATEREQUAL;
}

"+" {
    if(dump_tokens)
        print_str("ADD\t+"); 
    columns += strlen(yytext);
    return ADD;
}

"-"{
    if(dump_tokens)
        print_str("SUB\t-"); 
    columns += strlen(yytext);
    return SUB;
}

"*"{
    if(dump_tokens)
        print_str("MUL\t*"); 
    columns += strlen(yytext);
    return MUL;
}

"/"{
    if(dump_tokens)
        print_str("DIV\t/"); 
    columns += strlen(yytext);
    return DIV;
}

"%"{
    if(dump_tokens)
        print_str("MOD\t%"); 
    columns += strlen(yytext);
    return MOD;
}

"&&"{
    if(dump_tokens)
        print_str("AND\t&&"); 
    columns += strlen(yytext);
    return AND;
}

"||"{
    if(dump_tokens)
        print_str("OR\t&&"); 
    columns += strlen(yytext);
    return OR;
}

"!"{
    if(dump_tokens)
        print_str("NOT\t!"); 
    columns += strlen(yytext);
    return NOT;
}

";" {
    if(dump_tokens)
        print_str("SEMICOLON\t;"); 
    columns += strlen(yytext);
    return SEMICOLON;
}

":"{
    if(dump_tokens)
        print_str("COLON\t:"); 
    columns += strlen(yytext);
    return COLON;
}

","{
    if(dump_tokens)
        print_str("COMMA\t,"); 
    columns += strlen(yytext);
    return COMMA;
}

"(" {
    if(dump_tokens)
        print_str("LPAREN\t("); 
    columns += strlen(yytext);
    return LPAREN;
}

")" {
    if(dump_tokens)
        print_str("RPAREN\t)"); 
    columns += strlen(yytext);
    return RPAREN;
}

"["{
    if(dump_tokens)
        print_str("LBRACKET\t["); 
    columns += strlen(yytext);
    return LBRACKET;
}

"]"{
    if(dump_tokens)
        print_str("RBRACKET\t]"); 
    columns += strlen(yytext);
    return RBRACKET;
}

"{" {
    if(dump_tokens)
        print_str("LBRACE\t{"); 
    columns += strlen(yytext);
    return LBRACE;
}

"}" {
    if(dump_tokens)
        print_str("RBRACE\t}"); 
    columns += strlen(yytext);
    return RBRACE;
}

{DECIMIAL} {
    if(dump_tokens)
        print_num(string("INT_CONST\t") + string(yytext), string(yytext));
    words++;
    chars += yyleng;
    columns += strlen(yytext);
    return INTEGER;
}

{OCTAL} {
    int num;
    sscanf(yytext, "%o", &num);
    if(dump_tokens)
        print_num(string("OCT_CONST\t") + to_string(num), string(yytext));
    words++;
    chars += yyleng;
    columns += strlen(yytext);
    return OCT;
}

{HEXADECIMAL} {
    int num;
    sscanf(yytext, "%x", &num);
    if(dump_tokens)
        print_num(string("HEX_CONST\t") + to_string(num), string(yytext));
    words++;
    chars += yyleng;
    columns += strlen(yytext);
    return HEX;
}

/*从此开始*/
{FLO} {
    float num;
    sscanf(yytext, "%f", &num);
    if(dump_tokens)
        print_num(string("FLOAT_CONST\t") + to_string(num), string(yytext));
    words++;
    chars += yyleng;
    columns += strlen(yytext);
    return FLO;
}

{ID} {
    if(dump_tokens)
        print_str(string("ID\t") + to_string(yytext));
    words++;
    chars += yyleng;
    columns += strlen(yytext);
    char *lexeme = new char[strlen(yytext) + 1];
    strcpy(lexeme, yytext);
    yylval.strtype = lexeme;
    return ID;
}

{EOL} {columns = 0; lines++;}

{WHITE} {columns += strlen(yytext);}

. {chars++;}

{LINECOMMENT} {}
{COMMENTBEGIN} {BEGIN COMMENT;}
<COMMENT>{COMMENTEOL} {lines++;}
<COMMENT>{COMMENTELEMENT} {}
<COMMENT>{COMMENTEND} {BEGIN INITIAL;}

    /*  Your code here (lab3). */
%%
/* user code section */
