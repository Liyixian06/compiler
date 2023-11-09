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
    dump_tokens("VOID\t%s\n", yytext);
    return VOID;
}

"if" {
    dump_tokens("IF\t%s\n", yytext);
    return IF;
}

"else" {
    dump_tokens("ELSE\t%s\n", yytext);
    return ELSE;
}

"return" {
    dump_tokens("RETURN\t%s\n", yytext);
    return RETURN;
}

"=" {
    dump_tokens("ASSIGN\t%s\n", yytext);
    return ASSIGN;
}

"<" {
    dump_tokens("LESS\t%s\n", yytext);
    return LESS;
}

"+" {
    dump_tokens("ADD\t%s\n", yytext);
    return ADD;
}

";" {
    dump_tokens("SEMICOLON\t%s\n", yytext);
    return SEMICOLON;
}

"(" {
    dump_tokens("LPAREN\t%s\n", yytext);
    return LPAREN;
}

")" {
    dump_tokens("RPAREN\t%s\n", yytext);
    return RPAREN;
}

"{" {
    dump_tokens("LBRACE\t%s\n", yytext);
    return LBRACE;
}

"}" {
    dump_tokens("RBRACE\t%s\n", yytext);
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
