%option noyywrap
%option yylineno
%top{
    #include <string>
    #include <map>
    #include <stack>
    #include <math.h>
    #include <sstream>
    #include <malloc.h>
    using namespace std;
    extern FILE *yyin;
    extern FILE *yyout;
}
%{
    int chars = 0, words = 0, lines = 1, columns = 1;

    string id_list[1000];
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
        symbol_table(symbol_table* last) { prev = last; }
        symbol_table* get_prev(){ return prev; }
        symbol_table_entry* insert(string id){
            symbol_table_entry entry;
            table[id] = entry;
            return &entry;
            //id_list[id_count] = id;
            //id_count++;
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
        symbol_table_entry* add_id(string id){
            return top->insert(id);
        }
        symbol_table_entry* lookup(string id){
            symbol_table_entry* entry = nullptr;
            symbol_table* curr_table = top;
            do{
                entry = curr_table->search(id);
                if(entry) return entry;
                curr_table = curr_table->get_prev();
            } while(curr_table);
            return add_id(id);
        }
    } symbol_stack;


    void print_str(string s){
        string info = "\t" + s + "\t" + to_string(yylineno) + "\t" + to_string(columns) + "\n";
        fputs(info.c_str(), yyout);
    }
    void print_id(string id){
        symbol_table_entry* addr = symbol_stack.lookup(id);
        stringstream ss;
        ss<<addr;
        string addr_str = ss.str();
        string info = "\tIDENTIFIER\t" + id + "\t" + to_string(yylineno) + "\t" + to_string(columns) + "\t" + addr_str + "\n";
        fputs(info.c_str(), yyout);
    }
%}

/* definitions section */
FLO [0-9]*\.[0-9]+([Ee][+-]?[0-9]+)?
OCTAL 0[0-7]+
HEXADECIMAL 0[xX][0-9a-fA-F]+
DECIMIAL [1-9][0-9]*|0

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
"int" {print_str("INT\tint"); columns += strlen(yytext);}

"float" {print_str("FLOAT\tfloat"); columns += strlen(yytext);}

"void" {print_str("VOID\tvoid"); columns += strlen(yytext);}

"const" {print_str("CONST\tconst"); columns += strlen(yytext);}

"if" {print_str("IF\tif"); columns += strlen(yytext);}

"else" {print_str("ELSE\telse"); columns += strlen(yytext);}

"while" {print_str("WHILE\twhile"); columns += strlen(yytext);}

"for" {print_str("FOR\tfor"); columns += strlen(yytext);}

"break" {print_str("BREAK\tbreak"); columns += strlen(yytext);}

"continue" {print_str("CONTINUE\tcontinue"); columns += strlen(yytext);}

"return" {print_str("RETURN\treturn"); columns += strlen(yytext);}

"=" {print_str("ASSIGN\t="); columns += strlen(yytext);}

"==" {print_str("EQUAL\t=="); columns += strlen(yytext);}

"!=" {print_str("NOTEQUAL\t!="); columns += strlen(yytext);}

"<" {print_str("LESS\t<"); columns += strlen(yytext);}

">" {print_str("GREATER\t>"); columns += strlen(yytext);}

"<=" {print_str("LESSEQUAL\t<="); columns += strlen(yytext);}

">=" {print_str("GREATEREQUAL\t>="); columns += strlen(yytext);}

"+" {print_str("ADD\t+"); columns += strlen(yytext);}

"-" {print_str("SUB\t-"); columns += strlen(yytext);}

"*" {print_str("MUL\t*"); columns += strlen(yytext);}

"/" {print_str("DIV\t/"); columns += strlen(yytext);}

"%" {print_str("MOD\t%"); columns += strlen(yytext);}

"&&" {print_str("AND\t&&"); columns += strlen(yytext);}

"||" {print_str("OR\t||"); columns += strlen(yytext);}

"!" {print_str("NOT\t!"); columns += strlen(yytext);}

";" {print_str("SEMICOLON\t;");} columns += strlen(yytext);

":" {print_str("COLON\t:"); columns += strlen(yytext);}

"," {print_str("COMMA\t,"); columns += strlen(yytext);}

"(" {print_str("LPAREN\t("); columns += strlen(yytext);}

")" {print_str("RPAREN\t)"); columns += strlen(yytext);}

"[" {print_str("LBRACKET\t["); columns += strlen(yytext);}

"]" {print_str("RBRACKET\t]"); columns += strlen(yytext);}

"{" {print_str("LBRACE\t{"); columns += strlen(yytext);}

"}" {print_str("RBRACE\t}"); columns += strlen(yytext);}

{DECIMIAL} {
    print_str(string("INT_CONST\t") + string(yytext));
    words++;
    chars += yyleng;
    columns += strlen(yytext);
}

{OCTAL} {
    int num;
    sscanf(yytext, "%o", &num);
    print_str(string("OCT_CONST\t") + to_string(num));
    words++;
    chars += yyleng;
    columns += strlen(yytext);
}

{HEXADECIMAL} {
    int num;
    sscanf(yytext, "%x", &num);
    print_str(string("HEX_CONST\t") + to_string(num));
    words++;
    chars += yyleng;
    columns += strlen(yytext);
}

{FLO} {
    float num;
    sscanf(yytext, "%f", &num);
    print_str(string("FLOAT_CONST\t") + to_string(num));
    words++;
    chars += yyleng;
    columns += strlen(yytext);
}

{ID} {
    //print_str("IDENTIFIER\t"+ to_string(yytext));
    int flag = 0;
    for(int i=0; i<id_count; i++){
    	if(id_list[i]==yytext){
    		flag = 1;
    		break;
    	}
    }
    if(flag == 0){
    	id_list[id_count] = yytext;
    	id_count++;
    }
    print_id(yytext);
    words++;
    chars += yyleng;
    columns += strlen(yytext);
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
    fprintf(yyout, "\n%8d%8d%8d\n", lines, words, chars);
    return 0;
}
