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
/*token增补 进制 运算符...*/
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

/*非终结符增补*/
%nterm <stmttype> Stmts Stmt AssignStmt BlockStmt ExprStmt
%nterm <stmttype> IfStmt WhileStmt BreakStmt ContinueStmt ReturnStmt EmptyStmt
%nterm <stmttype> DeclStmt VarDecl ConstDecl VarDefList VarDef ConstDefList ConstDef
%nterm <stmttype> FuncDef FuncParam FuncParams
%nterm <exprtype> Exp LVal PrimaryExp UnaryExp MulExp AddExp RelExp EqExp LAndExp LOrExp
%nterm <exprtype> ConstExp Cond FuncCall FuncRParams
%nterm <type> Type

/*优先级*/
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
        if(se == nullptr) // 使用/赋值时，变量是否未定义
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
    :   LBRACE // 作用域开始，定义当前作用域符号表
        {identifiers = new SymbolTable(identifiers);} 
        Stmts RBRACE 
        {   // 作用域结束，当前符号表删除，指针前移
            $$ = new CompoundStmt($3);
            SymbolTable *top = identifiers;
            identifiers = identifiers->getPrev();
            delete top;
        }
    | LBRACE RBRACE {$$ = new CompoundStmt();}
    ;
/*表达式语句*/
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
            fprintf(stderr, "\"break\" not in WhileStmt\n"); // 检查是否仅出现在while中
            assert(whileDepth);
        }
        $$ = new BreakStmt(whilestk.top());
    }
    ;
ContinueStmt
    :   CONTINUE SEMICOLON {
        if(whileDepth==0){
            fprintf(stderr, "\"continue\" not in WhileStmt\n"); // 检查是否仅出现在while中
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
/*空语句 只含一个分号*/
EmptyStmt
    :   SEMICOLON {$$ = new EmptyStmt();}
    ;
/*变量和常量的规则归一*/
DeclStmt
    :
    VarDecl {$$ = $1;}
    | ConstDecl {$$ = $1;}
    ;
FuncDef
    :
    /*FunctionType函数的类型(返回类型。参数列表)*/
    /*IdentifierSymbolEntry函数名在符号表中的条目，install到符号表中*/
    /*在符号表中创建一个新的作用域，处理函数内部的变量和参数*/
    /*lookup获取函数名在符号表中的条目，确保成功*/
    /*创建 FunctionDef 对象，整个函数定义，包含函数名、返回类型、参数列表和函数体*/
    /*清理符号表，回退到上一个作用域，删除内存*/
    
    /*无参定义*/
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

        if(needRet){ // 检查是否缺return语句
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
    /*有参列表的函数定义 多了FuncParams*/
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

        if(needRet){ // 检查是否缺return语句
            if($1->isVoid()!=1){
                fprintf(stderr, "func %s missing return stmt\n",(char*)$2);
                assert(!needRet);
            }
        }
        Type *funcType = new FunctionType($1, defpara.get()); // 添加参数
        SymbolEntry *se = new IdentifierSymbolEntry(funcType, $2, identifiers->getLevel());
        identifiers->install($2, se);
        se = identifiers->lookup($2);
        assert(se != nullptr);
        /*有参导致占位符不同*/
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
/*列表的定义*/
/*在存在多个变量定义时，创建一个新的变量声明节点，将其结果设置为新创建的节点 */
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
        // 是否有同一作用域下的重定义
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
        // 是否有同一作用域下的重定义
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
    : // 函数调用时是否未定义
    ID LPAREN RPAREN { // main()
        SymbolEntry *st = identifiers->lookup($1); // 查找函数在符号表中的条目
        if(st == nullptr){
            fprintf(stderr, "function \"%s\" is undefined\n", (char*)$1);
            delete []$1;
            assert(st!=nullptr);  // 如果函数未定义，报错并中止程序
        }
        Type* tmp = st->getType();
        FunctionType* type = static_cast<FunctionType*>(tmp);
        int para_num = type->getnum(); // 定义时的参数个数
        if(para_num!=0){
            fprintf(stderr, "funccall %s params num error\n", (char*)$1);
            assert(para_num == 0);
        }  // 如果参数个数不为零，报错并中止程序
        SymbolEntry *se = new TemporarySymbolEntry(type->getRetType(), SymbolTable::getLabel());
        $$ = new FuncCallExp(se, st);  // // 创建一个函数调用表达式的实例
    }
    | ID LPAREN {
        // 处理函数调用时的情况（有参数）
        funccallpara.reset();
        callpara.reset();
    }
    FuncRParams RPAREN { //add(a,b)
    if($1!=(char*)"putf"){  // 排除特殊
        SymbolEntry *st = identifiers->lookup($1);  // 查找函数在符号表中的条目
        if(st == nullptr){
            fprintf(stderr, "function \"%s\" is undefined\n", (char*)$1);
            delete []$1;
            assert(st!=nullptr);
        }
        std::string name = dynamic_cast<IdentifierSymbolEntry*>(st)->get_name();
        Type* tmp = st->getType();
        FunctionType* type = static_cast<FunctionType*>(tmp);
        int para_num = type->getnum(); // 定义时的参数个数
        std::vector<Type*> para_type = type->get_params(); // 形参类型列表
        int call_num = funccallpara.ret_num(); // 调用时的参数个数
        std::vector<Type*> call_type = callpara.get(); // 实参类型列表
        if(para_num != call_num){
            fprintf(stderr, "funccall %s params num error\n", (char*)$1);
            assert(para_num == call_num);  // 如果参数个数不匹配，报错并中止程序
        }
        else if(name!="putint" && name!="putch" && name!="getint" && name!="getch"){
            for(int i=0; i<para_num; i++){
                if(para_type[i]->isVoid() || call_type[i]->isVoid()){
                    fprintf(stderr, "funccall %s params type error\n", (char*)$1);
                    assert(para_type[i] == call_type[i]);  // 如果参数类型不匹配
                }
            }
        }
        SymbolEntry *se = new TemporarySymbolEntry(type->getRetType(), SymbolTable::getLabel());
        $$ = new FuncCallExp(se, st, $4);  // 创建一个函数调用表达式的实例
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
