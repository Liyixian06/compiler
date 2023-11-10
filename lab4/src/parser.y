%code top{
    #include <iostream>
    #include <assert.h>
    #include "parser.h"
    extern Ast ast;
    int yylex();
    int yyerror( char const * );
}

%code requires {
    #include "Ast.h"
    #include "SymbolTable.h"
    #include "Type.h"
}
%define parse.error verbose
%union {
    int itype;
    char* strtype;
    StmtNode* stmttype;
    ExprNode* exprtype;
    Type* type;
}

%start Program
%token <strtype> ID 
%token <itype> INTEGER OCT HEX
%token CONST
%token IF ELSE
%token WHILE FOR BREAK CONTINUE
%token INT VOID
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET SEMICOLON COLON COMMA
%token ASSIGN ADD SUB MUL DIV MOD
%token OR AND NOT
%token EQUAL NOTEQUAL LESS GREATER LESSEQUAL GREATEREQUAL
%token RETURN

%nterm <stmttype> Stmts Stmt AssignStmt BlockStmt ExprStmt
%nterm <stmttype> IfStmt WhileStmt BreakStmt ContinueStmt ReturnStmt EmptyStmt
%nterm <stmttype> DeclStmt VarDecl ConstDecl VarDefList VarDef ConstDefList ConstDef
%nterm <stmttype> FuncDef FuncParam FuncParams
%nterm <exprtype> Exp LVal PrimaryExp UnaryExp MulExp AddExp RelExp EqExp LAndExp LOrExp
%nterm <exprtype> ConstExp Cond FuncCall FuncRParams
%nterm <type> Type

%precedence THEN
%precedence ELSE
%%
Program
    : Stmts {
        ast.setRoot($1);
    }
    ;
Stmts
    : Stmt {$$=$1;}
    | Stmts Stmt{
        $$ = new SeqNode($1, $2);
    }
    ;
Stmt
    : AssignStmt {$$=$1;}
    | BlockStmt {$$=$1;}
    | ExprStmt {$$=$1;}
    | IfStmt {$$=$1;}
    | WhileStmt {$$=$1;}
    | BreakStmt {$$=$1;}
    | ContinueStmt {$$=$1;}
    | ReturnStmt {$$=$1;}
    | EmptyStmt {$$=$1;}
    | DeclStmt {$$=$1;}
    | FuncDef {$$=$1;}
    ;
LVal // 左值
    : ID {
        SymbolEntry *se;
        se = identifiers->lookup($1);
        if(se == nullptr)
        {
            fprintf(stderr, "identifier \"%s\" is undefined\n", (char*)$1);
            delete [](char*)$1;
            assert(se != nullptr);
        }
        $$ = new Id(se);
        delete []$1;
    }
    ;
AssignStmt
    :
    LVal ASSIGN Exp SEMICOLON {
        $$ = new AssignStmt($1, $3);
    }
    ;
BlockStmt
    :   LBRACE 
        {identifiers = new SymbolTable(identifiers);} 
        Stmts RBRACE 
        {
            $$ = new CompoundStmt($3);
            SymbolTable *top = identifiers;
            identifiers = identifiers->getPrev();
            delete top;
        }
    | LBRACE RBRACE {$$ = new CompoundStmt();}
    ;
ExprStmt
    : Exp SEMICOLON {
        $$ = new ExprStmt($1);
    }
IfStmt
    : IF LPAREN Cond RPAREN Stmt %prec THEN {
        $$ = new IfStmt($3, $5);
    }
    | IF LPAREN Cond RPAREN Stmt ELSE Stmt {
        $$ = new IfElseStmt($3, $5, $7);
    }
    ;
WhileStmt
    : WHILE LPAREN Cond RPAREN Stmt {
        $$ = new WhileStmt($3, $5);
    }
    ;
BreakStmt
    :   BREAK SEMICOLON {$$ = new BreakStmt();}
    ;
ContinueStmt
    :   CONTINUE SEMICOLON {$$ = new ContinueStmt();}
    ;
ReturnStmt
    :
    RETURN Exp SEMICOLON{
        $$ = new ReturnStmt($2);
    }
    | RETURN SEMICOLON {$$ = new ReturnStmt();}
    ;
EmptyStmt
    :   SEMICOLON {$$ = new EmptyStmt();}
    ;
DeclStmt
    :
    VarDecl {$$ = $1;}
    | ConstDecl {$$ = $1;}
    ;
FuncDef
    :
    Type ID LPAREN RPAREN BlockStmt
    {
        Type *funcType = new FunctionType($1,{});
        SymbolEntry *se = new IdentifierSymbolEntry(funcType, $2, identifiers->getLevel());
        identifiers->install($2, se);
        identifiers = new SymbolTable(identifiers);
        se = identifiers->lookup($2);
        assert(se != nullptr);
        $$ = new FunctionDef(se, $5);
        SymbolTable *top = identifiers;
        identifiers = identifiers->getPrev();
        delete top;
        delete []$2;
    }
    | Type ID LPAREN FuncParams RPAREN BlockStmt
    {
        Type *funcType = new FunctionType($1,{});
        SymbolEntry *se = new IdentifierSymbolEntry(funcType, $2, identifiers->getLevel());
        identifiers->install($2, se);
        identifiers = new SymbolTable(identifiers);
        se = identifiers->lookup($2);
        assert(se != nullptr);
        $$ = new FunctionDef(se, $6, $4);
        SymbolTable *top = identifiers;
        identifiers = identifiers->getPrev();
        delete top;
        delete []$2;
    }
    ;
VarDecl
    :
    Type VarDefList SEMICOLON {$$ = $2;}
    ;
ConstDecl
    :
    CONST Type ConstDefList SEMICOLON {$$ = $3;}
    ;
VarDefList
    :
    VarDef {$$ = $1;}
    | VarDefList COMMA VarDef {$$ = new VarDecl($1, $3);}
    ;
ConstDefList
    :
    ConstDef {$$ = $1;}
    | ConstDefList COMMA ConstDef {$$ = new ConstDecl($1, $3);}
    ;
VarDef
    : ID {
        SymbolEntry *se = new IdentifierSymbolEntry(TypeSystem::intType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new VarDef(new Id(se));
        delete []$1;
    }
    | ID ASSIGN Exp {
        SymbolEntry *se = new IdentifierSymbolEntry(TypeSystem::intType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new VarDef(new Id(se), $3);
        delete []$1;
    }
    ;
ConstDef
    : ID ASSIGN ConstExp {
        SymbolEntry *se = new IdentifierSymbolEntry(TypeSystem::constType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new ConstDef(new Id(se), $3);
        delete []$1;
    }
    ;

Exp
    :
    LOrExp {$$ = $1;}
    ;
PrimaryExp
    :
    LVal {
        $$ = $1;
    }
    | INTEGER {
        SymbolEntry *se = new ConstantSymbolEntry(TypeSystem::intType, $1);
        $$ = new Constant(se,0);
    }
    | OCT {
        SymbolEntry *se = new ConstantSymbolEntry(TypeSystem::intType, $1);
        $$ = new Constant(se,2);
    }
    | HEX {
        SymbolEntry *se = new ConstantSymbolEntry(TypeSystem::intType, $1);
        $$ = new Constant(se,1);
    }
    | LPAREN Exp RPAREN {$$ = $2;}
    ;
UnaryExp
    :
    PrimaryExp {$$ = $1;}
    | FuncCall {$$ = $1;}
    | ADD UnaryExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new UnaryExpr(se, UnaryExpr::ADD, $2);
    }
    | SUB UnaryExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new UnaryExpr(se, UnaryExpr::SUB, $2);
    }
    | NOT UnaryExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new UnaryExpr(se, UnaryExpr::NOT, $2);
    }
    ;
MulExp
    :
    UnaryExp {$$ = $1;}
    | MulExp MUL UnaryExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::MUL, $1, $3);
    }
    | MulExp DIV UnaryExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::DIV, $1, $3);
    }
    | MulExp MOD UnaryExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::MOD, $1, $3);
    }
    ;
AddExp
    :
    MulExp {$$ = $1;}
    |
    AddExp ADD MulExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::ADD, $1, $3);
    }
    |
    AddExp SUB MulExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::SUB, $1, $3);
    }
    ;
RelExp
    :
    AddExp {$$ = $1;}
    |
    RelExp LESS AddExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::LESS, $1, $3);
    }
    | RelExp GREATER AddExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::GREATER, $1, $3);
    }
    | RelExp LESSEQUAL AddExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::LESSEQUAL, $1, $3);
    }
    | RelExp GREATEREQUAL AddExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::GREATEREQUAL, $1, $3);
    }
    ;
EqExp
    :
    RelExp {$$ = $1;}
    | EqExp EQUAL RelExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::EQUAL, $1, $3);
    }
    | EqExp NOTEQUAL RelExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::NOTEQUAL, $1, $3);
    }
    ;
LAndExp
    :
    EqExp {$$ = $1;}
    |
    LAndExp AND EqExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::AND, $1, $3);
    }
    ;
LOrExp
    :
    LAndExp {$$ = $1;}
    |
    LOrExp OR LAndExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::OR, $1, $3);
    }
    ;
ConstExp
    :
    AddExp {$$ = $1;}
    ;
Cond
    :
    LOrExp {$$ = $1;}
    ;
FuncCall
    :
    ID LPAREN RPAREN { // main()
        SymbolEntry *se = identifiers->lookup($1);
        if(se == nullptr){
            fprintf(stderr, "function \"%s\" is undefined\n", (char*)$1);
            delete []$1;
            assert(se!=nullptr);
        }
        $$ = new FuncCallExp(se);
    }
    | ID LPAREN FuncRParams RPAREN { //add(a,b)
        SymbolEntry *se = identifiers->lookup($1);
        if(se == nullptr){
            fprintf(stderr, "function \"%s\" is undefined\n", (char*)$1);
            delete []$1;
            assert(se!=nullptr);
        }
        $$ = new FuncCallExp(se, $3);
    }
    ;
FuncParam
    :
    Type ID {
        SymbolEntry *se = new IdentifierSymbolEntry($1, $2, identifiers->getLevel());
        identifiers->install($2, se);
        $$ = new FuncParam(new Id(se));
    }
    | Type ID ASSIGN Exp {
        SymbolEntry *se = new IdentifierSymbolEntry($1, $2, identifiers->getLevel());
        identifiers->install($2, se);
        $$ = new FuncParam(new Id(se), $4);
    }
    ;
FuncParams
    :
    FuncParam {$$ = $1;}
    | FuncParams COMMA FuncParam {
        $$ = new FuncParams($1, $3);
    }
    ;
FuncRParams
    :
    Exp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, identifiers->getLabel());
        $$ = new FuncRParam(se, $1);
    }
    | FuncRParams COMMA Exp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, identifiers->getLabel());
        $$ = new FuncRParams(se, $1, $3);
    }
    ;

Type
    : INT {
        $$ = TypeSystem::intType;
    }
    | VOID {
        $$ = TypeSystem::voidType;
    }
    ;
%%

int yyerror(char const* message)
{
    std::cerr<<message<<std::endl;
    return -1;
}
