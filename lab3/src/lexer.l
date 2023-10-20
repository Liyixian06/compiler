%option noyywrap
%option yylineno
%top{
    #include <iostream>
    #include <fstream>
    #include <string>
    #include <map>
    #include <stack>
    #include <math.h>
    using namespace std;
    extern FILE *yyin;
    extern FILE *yyout;
}
%{
    yylineo = 0;
    int chars = 0, words = 0, lines = 0, culumns = 0;

    /*
    struct node {
        char name[64];
        node* prev, * next;
    };
    struct symbol_table_entry{
        node* head, * tail;
        int count;
    };
    void init_symbol_table_entry(symbol_table_entry entry){
        entry.head = (node*)malloc(sizeof(node));
        entry.head -> next = idtable.head -> prev = nullptr;
        entry.tail = idtable.head;
        entry.count = 0;
    }
    node* add_id(symbol_table_entry entry, char* s){
        node* id = (node*)malloc(sizeof(node));
        strcpy(id->name, s);
        entry.tail->next = id;
        id->prev = entry.tail;
        entry.tail->next = nullptr;
        entry.tail = id;
        entry.count++;
        return id;
    }

    node* search_id(char* s){
        node* id = idtable.head;
        while(id->name!=s && id!=nullptr){
            id = id->next;
        }
        if(id==nullptr)
            id = add_id(s);
        return id;
    }
    */
    N = 1000;
    string id_list[N];
    int id_count = 0;
    struct symbol_table_entry{
        string lexeme;
        string word;
        //string* ptr;
    };
    class symbol_table{
    private:
        map<string, symbol_table_entry> table;
        symbol_table* prev;
    public:
        symbol_table(){ prev = nullptr;}
        symbol_table(symbol_table* last) { prev = back; }
        symbol_table* get_prev(){ return prev; }
        void insert(string id){
            symbol_table_entry entry;
            table[id] = entry;
            id_list[id_count] = id;
            id_count++;
        }
        symbol_table_entry* search(string id){
            if(table.find(id)!=table.end()){
                return &table[id];
            }
            return nullptr;
        }
        ~symbol_table(){
            prev = nullptr;
            map<string, symbol_table_entry>().swap(table);
            malloc_trim(0);
        }
    };

    class symbol_table_stack{
    private:
        symbol_table* top;
    public:
        symbol_table_stack(){
            symbol_table* t = new symbol_table();
            top = t;
        }
        void push(){
            symbol_table* s = new symbol_table(top);
            top = s;
        }
        void pop(){
            symbol_table* s = top;
            top = top->get_prev();
            s->~symbol_table();
        }
        void add_id(string id){
            top->insert(id);
        }
        symbol_table_entry* lookup(string id){
            symbol_table_entry* entry = nullptr;
            symbol_table* curr_table = top;
            do{
                entry = curr_table->search(id);
                if(entry) return entry;
                curr_table = curr_table->get_prev();
            } while(curr_table);
            add_id(id);
        }
    } symbol_stack;


    void print_str(string s){
        string info = "\t" + s + "\t" + to_string(yylineno) + "\t" + columns + "\n";
        fputs(info.c_str(), yyout);
    }
    void print_id(string id){
        string addr = to_string(symbol_stack->lookup(id));
        string info = "\tIDENTIFIER\t" + id + "\t" + to_string(yylineno) + "\t" + columns + "\t" + addr + "\n";
        fputs(info.c_str(), yyout);
    }
%}

/* definitions section */
DECIMIAL [1-9][0-9]*|0
OCTAL 0[0-7]+
HEXADECIMAL 0[xX][0-9a-fA-F]+
FLO [0-9]*\.[0-9]+([Ee][+-]?[0-9]+)?

ID [a-zA-Z_][a-zA-Z0-9_]*
EOL (\r\n|\n|\r)
WHITE [\t ]

%x COMMENT
COMMENTBEGIN "/*"
COMMENTELEMENT .|\n
COMMENTEND "*/"
LINECOMMENT \/\/[^\n]*

%%
    /* rules section */
"int" {columns += strlen(yytext); print_str("INT\tint");}

"float" {columns += strlen(yytext); print_str("FLOAT\tfloat");}

"void" {columns += strlen(yytext); print_str("VOID\tvoid");}

"const" {columns += strlen(yytext); print_str("CONST\tconst");}

"if" {columns += strlen(yytext); print_str("IF\tif");}

"else" {columns += strlen(yytext); print_str("ELSE\telse");}

"while" {columns += strlen(yytext); print_str("WHILE\twhile");}

"for" {columns += strlen(yytext); print_str("FOR\tfor");}

"break" {columns += strlen(yytext); print_str("BREAK\tbreak");}

"continue" {columns += strlen(yytext); print_str("CONTINUE\tcontinue");}

"return" {columns += strlen(yytext); print_str("RETURN\treturn");}

"=" {columns += strlen(yytext); print_str("ASSIGN\t=");}

"==" {columns += strlen(yytext); print_str("EQUAL\t==");}

"!=" {columns += strlen(yytext); print_str("NOTEQUAL\t!=");}

"<" {columns += strlen(yytext); print_str("LESS\t<");}

">" {columns += strlen(yytext); print_str("GREATER\t>");}

"<=" {columns += strlen(yytext); print_str("LESSEQUAL\t<=");}

">=" {columns += strlen(yytext); print_str("GREATEREQUAL\t>=");}

"+" {columns += strlen(yytext); print_str("ADD\t+");}

"-" {columns += strlen(yytext); print_str("SUB\t-");}

"*" {columns += strlen(yytext); print_str("MUL\t*");}

"/" {columns += strlen(yytext); print_str("DIV\t/");}

"%" {columns += strlen(yytext); print_str("MOD\t%");}

"&&" {columns += strlen(yytext); print_str("AND\t&&");}

"||" {columns += strlen(yytext); print_str("OR\t||");}

"!" {columns += strlen(yytext); print_str("NOT\t!");}

";" {columns += strlen(yytext); print_str("SEMICOLON\t;");}

":" {columns += strlen(yytext); print_str("COLON\t:");}

"," {columns += strlen(yytext); print_str("COMMA\t,");}

"(" {columns += strlen(yytext); print_str("LPAREN\t(");}

")" {columns += strlen(yytext); print_str("RPAREN\t)");}

"[" {columns += strlen(yytext); print_str("LBRACKET\t[");}

"]" {columns += strlen(yytext); print_str("RBRACKET\t]");}

"{" {columns += strlen(yytext); print_str("LBRACE\t{");}

"}" {columns += strlen(yytext); print_str("RBRACE\t}");}

{DECIMIAL} {
    columns += strlen(yytext); 
    print_str(string("INT_CONST\t") + string(yytext));
    words++;
    chars += yyleng;
}

{OCTAL} {
    columns += strlen(yytext); 
    int num;
    sscanf(yytext, "%o", &num);
    print_str(string("OCT_CONST\t") + to_string(num));
    words++;
    chars += yyleng;
}

{HEXADECIMAL} {
    columns += strlen(yytext); 
    int num;
    sscanf(yytext, "%x", &num);
    print_str(string("HEX_CONST\t") + to_string(num));
    words++;
    chars += yyleng;
}

{FLO} {
    columns += strlen(yytext); 
    float num;
    sscanf(yytext, "%f", &num);
    print_str(string("FLOAT_CONST\t") + to_string(num));
    words++;
    chars += yyleng;
}

{ID} {
    columns += strlen(yytext); 
    print_id(yytext);
    words++;
    chars += yyleng;
}

{EOL} {columns = 0; lines++;}

{WHITE} {columns += strlen(yytext);}

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
    yylex();
    fprintf(yyout, "%8d%8d%8d%8d\n", lines, words, chars);
    return 0;
}
