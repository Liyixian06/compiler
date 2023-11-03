%{
/*********************************************
正则表达式转NFA的Thompson构造法
YACC file
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<queue>
#include<map>
#include<iostream>
using namespace std;

typedef struct state state;
typedef struct transition transition;
struct state{
    int id;
    bool accepting;
    //这里将从该状态出发的所有转换连接成一个链表，作为该状态的成员变量
    transition* transitions; 
};
struct transition{
    char symbol;
    state *source;
    state *destination;
    transition* next;
};
struct NFA{
    state* start;
    state* accept;
} myNFA;
int statecount = 0;

state* createState(bool accepting);
void addTransition(state* from, char symbol, state* to);
NFA fromsymbol(char symbol);
NFA concatNFA(NFA a, NFA b);
NFA unionNFA(NFA a, NFA b);
NFA closureNFA(NFA a);
void printState(state* s, FILE* outfile);
void printTransition(transition* t, FILE* outfile);
void printNFA(NFA nfa, FILE* outfile);

int yylex();
extern int yyparse();
FILE* yyin;
FILE* outfile;
void yyerror(const char* s);

%}

%union{
    char charval;
    struct NFA nfaval;
}

%type <nfaval> lines concat basic
%token <charval> CHAR
%token OR
%token STAR
%token LPAREN
%token RPAREN

%%

//正则表达式，注意优先级

lines   :   lines OR concat { $$ = unionNFA($1,$3); myNFA = $$;}
        |   concat { $$ = $1; myNFA = $$;}
        ;

concat  :   concat basic    { $$ = concatNFA($1,$2); }
        |   basic   { $$ = $1; }
        ;

basic   :   basic STAR  { $$ = closureNFA($1); }
        |   CHAR    { $$ = fromsymbol($1); }
        |   LPAREN lines RPAREN { $$ = $2; }
        ;

%%

//programs section

//创建状态，标记是否接受
state* createState(bool accepting){
    state* s = new state;
    s->id = statecount++;
    s->accepting = accepting;
    s->transitions = NULL;
    printState(s, outfile);
    return s;
}

//添加状态转换
void addTransition(state* from, char symbol, state* to){
    transition* t = new transition;
    t->symbol = symbol;
    t->source = from;
    t->destination = to;
    //把该转换挂到所在链表的头部
    t->next = from->transitions;
    from->transitions = t;
    printTransition(t, outfile);
}

//形如 a 的正则表达式的NFA
NFA fromsymbol(char symbol){
    state* start = createState(false);
    state* accept = createState(true);
    addTransition(start, symbol, accept);
    return (NFA){start, accept};
}

//下面是子NFA组合为复杂NFA，注意组合时要修改子NFA终态为非终态

//形如 (a)|(b) 的正则表达式的NFA
NFA concatNFA(NFA a, NFA b){
    state* start = createState(false);
    state* accept = createState(true);
    addTransition(start, 'e', a.start);
    a.accept->accepting = false;
    addTransition(a.accept, 'e', b.start);
    b.accept->accepting = false;
    addTransition(b.accept, 'e', accept);
    return (NFA){start, accept};
}

//形如 (a)(b) 的正则表达式的NFA
NFA unionNFA(NFA a, NFA b){
    state* start = createState(false);
    state* accept = createState(true);
    addTransition(start, 'e', a.start);
    addTransition(start, 'e', b.start);
    a.accept->accepting = false;
    addTransition(a.accept, 'e', accept);
    b.accept->accepting = false;
    addTransition(b.accept, 'e', accept);
    return (NFA){start, accept};
}

//形如 a* 的正则表达式的NFA
NFA closureNFA(NFA a){
    state* start = createState(false);
    state* accept = createState(true);
    addTransition(start, 'e', a.start);
    addTransition(a.accept, 'e', a.start);
    a.accept->accepting = false;
    addTransition(a.accept, 'e', accept);
    addTransition(start, 'e', accept);
    return (NFA){start, accept};
}

void printState(state* s, FILE* outfile){
    fprintf(outfile, "stateID: %d, accepting: %d  \n", s->id, s->accepting);
}
void printTransition(transition* t, FILE* outfile){
    fprintf(outfile, "%d —— %c ——> %d  \n", t->source->id, t->symbol, t->destination->id);
}
// 最后以mermaid图像格式输出NFA
void printNFA(NFA nfa, FILE* outfile){
    fprintf(outfile, "\nfinal NFA:\n");
    fprintf(outfile, "```mermaid\ngraph LR;\n");
    queue<state*> q;
    map<int, bool> visited;
    q.push(nfa.start);
    visited[nfa.start->id] = true;
    while(!q.empty()){
        state* current = q.front();
        //printState(current, outfile);
        transition* currtrans = current->transitions;
        while(currtrans){
            //printTransition(currtrans, outfile);
            fprintf(outfile, "\t%d--%c-->%d;\n", currtrans->source->id, currtrans->symbol, currtrans->destination->id);
            if(visited.find(currtrans->destination->id)==visited.end()){
                q.push(currtrans->destination);
                visited[currtrans->destination->id] = true;
            }
            currtrans = currtrans->next;
        }
        q.pop();
    }
    fprintf(outfile, "```");
}

int yylex(){
    char t;
    while(1){
        t = getchar();
        if(t==' '||t=='\t'||t=='\n'){
            //do nothing
        }else if(t=='|'){
            return OR;
        }else if(t=='*'){
            return STAR;
        }else if(t=='('){
            return LPAREN;
        }else if(t==')'){
            return RPAREN;
        }else if(t>='a'&& t<='z'||t>='A'&& t<='Z'){
            yylval.charval = t;
            return CHAR;
        }
        else{
            return t;
        }
    }
}

int main(void){
    printf("input the regex you want to convert, end by Enter + Ctrl + D: \n");
    yyin = stdin;
    outfile = fopen("output.md","w");
    fprintf(outfile, "constructing NFA:  \n");
    do{
        yyparse();
    }while(!feof(yyin));
    printNFA(myNFA, outfile);
    fclose(outfile);
    printf("conversion finished.\n");
    return 0;
}
void yyerror(const char* s)
{
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}