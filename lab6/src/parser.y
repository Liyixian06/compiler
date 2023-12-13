%code top{
    #include <iostream>
    #include <stack>
    #include <assert.h>
    #include "parser.h"
    extern Ast ast;
    int yylex();
    int yyerror( char const * );
    int whileDepth = 0;
    bool needRet = false;
    std::stack<StmtNode*> whilestk;
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
/*token���� ���� �����...*/
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

/*���ս������*/
%nterm <stmttype> Stmts Stmt AssignStmt BlockStmt ExprStmt
%nterm <stmttype> IfStmt WhileStmt BreakStmt ContinueStmt ReturnStmt EmptyStmt
%nterm <stmttype> DeclStmt VarDecl ConstDecl VarDefList VarDef ConstDefList ConstDef
%nterm <stmttype> FuncDef FuncParam FuncParams
%nterm <exprtype> Exp LVal PrimaryExp UnaryExp MulExp AddExp RelExp EqExp LAndExp LOrExp
%nterm <exprtype> ConstExp Cond FuncCall FuncRParams
%nterm <type> Type

/*���ȼ�*/
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
LVal // ��ֵ
    : ID {
        SymbolEntry *se;
        se = identifiers->lookup($1);
        if(se == nullptr) // ʹ��/��ֵʱ�������Ƿ�δ����
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
    :   LBRACE // ������ʼ�����嵱ǰ��������ű�
        {identifiers = new SymbolTable(identifiers);} 
        Stmts RBRACE 
        {   // �������������ǰ���ű�ɾ����ָ��ǰ��
            $$ = new CompoundStmt($3);
            SymbolTable *top = identifiers;
            identifiers = identifiers->getPrev();
            delete top;
        }
    | LBRACE RBRACE {$$ = new CompoundStmt();}
    ;
/*���ʽ���*/
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
    : WHILE LPAREN Cond RPAREN {
        whileDepth++;
        StmtNode* whileNode = new WhileStmt($3);
        $<stmttype>$ = whileNode;
        whilestk.push(whileNode);
    }
    Stmt {
        StmtNode* whileNode = $<stmttype>5;
        ((WhileStmt*)whileNode)->setStmt($6);
        $$ = whileNode;
        whilestk.pop();
        //$$ = new WhileStmt($3, $6);
        whileDepth--;
    }
    ;
BreakStmt
    :   BREAK SEMICOLON {
        if(whileDepth==0){
            fprintf(stderr, "\"break\" not in WhileStmt\n"); // ����Ƿ��������while��
            assert(whileDepth);
        }
        $$ = new BreakStmt(whilestk.top());
    }
    ;
ContinueStmt
    :   CONTINUE SEMICOLON {
        if(whileDepth==0){
            fprintf(stderr, "\"continue\" not in WhileStmt\n"); // ����Ƿ��������while��
            assert(whileDepth);
        }
        $$ = new ContinueStmt(whilestk.top());
    }
    ;
ReturnStmt
    :
    RETURN Exp SEMICOLON{
        $$ = new ReturnStmt($2);
        needRet = false;
    }
    | RETURN SEMICOLON {$$ = new ReturnStmt(); needRet = false;}
    ;
/*����� ֻ��һ���ֺ�*/
EmptyStmt
    :   SEMICOLON {$$ = new EmptyStmt();}
    ;
/*�����ͳ����Ĺ����һ*/
DeclStmt
    :
    VarDecl {$$ = $1;}
    | ConstDecl {$$ = $1;}
    ;
FuncDef
    :
    /*FunctionType����������(�������͡������б�)*/
    /*IdentifierSymbolEntry�������ڷ��ű��е���Ŀ��install�����ű���*/
    /*�ڷ��ű��д���һ���µ������򣬴������ڲ��ı����Ͳ���*/
    /*lookup��ȡ�������ڷ��ű��е���Ŀ��ȷ���ɹ�*/
    /*���� FunctionDef ���������������壬�������������������͡������б�ͺ�����*/
    /*������ű����˵���һ��������ɾ���ڴ�*/
    
    /*�޲ζ���*/
    Type ID LPAREN 
    {
        needRet = true;
        identifiers = new SymbolTable(identifiers);
    }
    RPAREN BlockStmt
    {
        SymbolTable *top = identifiers;
        identifiers = identifiers->getPrev();
        delete top;

        if(needRet){ // ����Ƿ�ȱreturn���
            if($1->isVoid()!=1){
                fprintf(stderr, "func %s missing return stmt\n",(char*)$2);
                assert(!needRet);
            }
        }
        Type *funcType = new FunctionType($1,{});
        SymbolEntry *se = new IdentifierSymbolEntry(funcType, $2, identifiers->getLevel());
        identifiers->install($2, se);
        se = identifiers->lookup($2);
        assert(se != nullptr);
        $$ = new FunctionDef(se, $6);
        delete []$2;
    }
    /*�в��б�ĺ������� ����FuncParams*/
    |
    Type ID LPAREN
    {
        needRet = true;
        identifiers = new SymbolTable(identifiers);
        funcdefpara.reset();
        defpara.reset();
    }
    FuncParams RPAREN BlockStmt
    {
        SymbolTable *top = identifiers;
        identifiers = identifiers->getPrev();
        delete top;

        if(needRet){ // ����Ƿ�ȱreturn���
            if($1->isVoid()!=1){
                fprintf(stderr, "func %s missing return stmt\n",(char*)$2);
                assert(!needRet);
            }
        }
        Type *funcType = new FunctionType($1, defpara.get()); // ��Ӳ���
        SymbolEntry *se = new IdentifierSymbolEntry(funcType, $2, identifiers->getLevel());
        identifiers->install($2, se);
        se = identifiers->lookup($2);
        assert(se != nullptr);
        /*�вε���ռλ����ͬ*/
        $$ = new FunctionDef(se, $7, $5);
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
/*�б�Ķ���*/
/*�ڴ��ڶ����������ʱ������һ���µı��������ڵ㣬����������Ϊ�´����Ľڵ� */
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
        // �Ƿ���ͬһ�������µ��ض���
        SymbolEntry *se = identifiers->lookup_inthis($1);
        if(se){
            fprintf(stderr, "var \"%s\" is redefined\n", (char*)$1);
            delete [](char*)$1;
            assert(se!=nullptr);
        }
        se = new IdentifierSymbolEntry(TypeSystem::intType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new VarDef(new Id(se));
        delete []$1;
    }
    | ID ASSIGN Exp {
        SymbolEntry *se = identifiers->lookup_inthis($1);
        if(se){
            fprintf(stderr, "var \"%s\" is redefined\n", (char*)$1);
            delete [](char*)$1;
            assert(se!=nullptr);
        }
        se = new IdentifierSymbolEntry(TypeSystem::intType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new VarDef(new Id(se), $3);
        delete []$1;
    }
    ;
ConstDef
    : ID ASSIGN ConstExp {
        // �Ƿ���ͬһ�������µ��ض���
        SymbolEntry *se = identifiers->lookup_inthis($1);
        if(se){
            fprintf(stderr, "const \"%s\" is redefined\n", (char*)$1);
            delete [](char*)$1;
            assert(se!=nullptr);
        }
        se = new IdentifierSymbolEntry(TypeSystem::constType, $1, identifiers->getLevel());
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
        SymbolEntry *se = new ConstantSymbolEntry(TypeSystem::constType, $1);
        $$ = new Constant(se,0);
    }
    | OCT {
        SymbolEntry *se = new ConstantSymbolEntry(TypeSystem::constType, $1);
        $$ = new Constant(se,2);
    }
    | HEX {
        SymbolEntry *se = new ConstantSymbolEntry(TypeSystem::constType, $1);
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
    : // ��������ʱ�Ƿ�δ����
    ID LPAREN RPAREN { // main()
        SymbolEntry *st = identifiers->lookup($1); // ���Һ����ڷ��ű��е���Ŀ
        if(st == nullptr){
            fprintf(stderr, "function \"%s\" is undefined\n", (char*)$1);
            delete []$1;
            assert(st!=nullptr);  // �������δ���壬������ֹ����
        }
        Type* tmp = st->getType();
        FunctionType* type = static_cast<FunctionType*>(tmp);
        int para_num = type->getnum(); // ����ʱ�Ĳ�������
        if(para_num!=0){
            fprintf(stderr, "funccall %s params num error\n", (char*)$1);
            assert(para_num == 0);
        }  // �������������Ϊ�㣬������ֹ����
        SymbolEntry *se = new TemporarySymbolEntry(type->getRetType(), SymbolTable::getLabel());
        $$ = new FuncCallExp(se, st);  // // ����һ���������ñ��ʽ��ʵ��
    }
    | ID LPAREN {
        // ����������ʱ��������в�����
        funccallpara.reset();
        callpara.reset();
    }
    FuncRParams RPAREN { //add(a,b)
    if($1!=(char*)"putf"){  // �ų�����
        SymbolEntry *st = identifiers->lookup($1);  // ���Һ����ڷ��ű��е���Ŀ
        if(st == nullptr){
            fprintf(stderr, "function \"%s\" is undefined\n", (char*)$1);
            delete []$1;
            assert(st!=nullptr);
        }
        std::string name = dynamic_cast<IdentifierSymbolEntry*>(st)->get_name();
        Type* tmp = st->getType();
        FunctionType* type = static_cast<FunctionType*>(tmp);
        int para_num = type->getnum(); // ����ʱ�Ĳ�������
        std::vector<Type*> para_type = type->get_params(); // �β������б�
        int call_num = funccallpara.ret_num(); // ����ʱ�Ĳ�������
        std::vector<Type*> call_type = callpara.get(); // ʵ�������б�
        if(para_num != call_num){
            fprintf(stderr, "funccall %s params num error\n", (char*)$1);
            assert(para_num == call_num);  // �������������ƥ�䣬������ֹ����
        }
        else if(name!="putint" && name!="putch" && name!="getint" && name!="getch"){
            for(int i=0; i<para_num; i++){
                if(para_type[i]->isVoid() || call_type[i]->isVoid()){
                    fprintf(stderr, "funccall %s params type error\n", (char*)$1);
                    assert(para_type[i] == call_type[i]);  // ����������Ͳ�ƥ��
                }
            }
        }
        SymbolEntry *se = new TemporarySymbolEntry(type->getRetType(), SymbolTable::getLabel());
        $$ = new FuncCallExp(se, st, $4);  // ����һ���������ñ��ʽ��ʵ��
    }
    }
    ;
FuncParam
    :
    Type ID {
        SymbolEntry* se = identifiers->lookup_inthis($2);
        if(se!=nullptr){
            fprintf(stderr, "param \"%s\" is redefined\n", (char*)$2);
            delete [](char*)$2;
            assert(se==nullptr);
        }
        se = new IdentifierSymbolEntry($1, $2, identifiers->getLevel());
        identifiers->install($2, se);
        $$ = new FuncParam(new Id(se));
    }
    | Type ID ASSIGN Exp {
        SymbolEntry* se = identifiers->lookup_inthis($2);
        if(se!=nullptr){
            fprintf(stderr, "param \"%s\" is redefined\n", (char*)$2);
            delete [](char*)$2;
            assert(se==nullptr);
        }
        se = new IdentifierSymbolEntry($1, $2, identifiers->getLevel());
        identifiers->install($2, se);
        $$ = new FuncParam(new Id(se), $4);
    }
    ;
FuncParams
    :
    FuncParam {
        funcdefpara.plus();
        FuncParam* tmp = static_cast<FuncParam*>($1);
        Type* type = tmp->get_id()->getSymPtr()->getType();
        defpara.push(type);
        $$ = new FuncParams($1);
    }
    | FuncParams COMMA FuncParam {
        funcdefpara.plus();
        FuncParam* tmp = static_cast<FuncParam*>($3);
        Type* type = tmp->get_id()->getSymPtr()->getType();
        defpara.push(type);
        $$ = new FuncParams($1, $3);
    }
    ;
FuncRParams
    :
    Exp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, identifiers->getLabel());
        funccallpara.plus();
        callpara.push(TypeSystem::intType);
        $$ = new FuncRParams(se, $1);
    }
    | FuncRParams COMMA Exp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, identifiers->getLabel());
        funccallpara.plus();
        callpara.push(TypeSystem::intType);
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
