#include "Ast.h"
#include "SymbolTable.h"
#include <string>
#include "Type.h"

extern FILE *yyout;
int Node::counter = 0;

Node::Node()
{
    seq = counter++;
}

void Ast::output()
{
    fprintf(yyout, "program\n");
    if(root != nullptr)
        root->output(4); // 4: 缩进
}

void BinaryExpr::output(int level)
{
    std::string op_str;
    switch(op)
    {
        case ADD:
            op_str = "add";
            break;
        case SUB:
            op_str = "sub";
            break;
        case MUL:
            op_str = "mul";
            break;
        case DIV:
            op_str = "div";
            break;
        case MOD:
            op_str = "mod";
            break;
        case AND:
            op_str = "and";
            break;
        case OR:
            op_str = "or";
            break;
        case EQUAL:
            op_str = "equal";
            break;
        case NOTEQUAL:
            op_str = "notequal";
            break;
        case LESS:
            op_str = "less";
            break;
        case GREATER:
            op_str = "greater";
            break;
        case LESSEQUAL:
            op_str = "lessequal";
            break;
        case GREATEREQUAL:
            op_str = "greaterequal";
            break;
    }
    fprintf(yyout, "%*cBinaryExpr\top: %s\n", level, ' ', op_str.c_str());
    expr1->output(level + 4);
    expr2->output(level + 4);
}

/*单目运算*/
void UnaryExpr::output(int level)
{
    std::string op_str;
    switch(op)
    {
        case ADD:
            op_str = "add";
            break;
        case SUB:
            op_str = "sub";
            break;
        case NOT:
            op_str = "not";
            break;
    }
    fprintf(yyout, "%*cUnaryExpr\top: %s\n", level, ' ', op_str.c_str());
    expr->output(level + 4);
}

void Constant::output(int level)
{
    std::string type, value;
    type = symbolEntry->getType()->toStr();
    value = symbolEntry->toStr();
    /*进制判断*/
    switch (this->scale)
    {
        case 0:
            fprintf(yyout, "%*cIntegerLiteral\tvalue: %s\ttype: %s\n", level, ' ',
            value.c_str(), type.c_str());
            break;
        case 1:
            fprintf(yyout, "%*cHexLiteral\tvalue: %s\ttype: %s\n", level, ' ',
            value.c_str(), type.c_str());
            break;
        case 2:
            fprintf(yyout, "%*cOctLiteral\tvalue: %s\ttype: %s\n", level, ' ',
            value.c_str(), type.c_str());
            break;
    }
}

void Id::output(int level)
{
    std::string name, type;
    int scope;
    name = symbolEntry->toStr();
    type = symbolEntry->getType()->toStr();
    scope = dynamic_cast<IdentifierSymbolEntry*>(symbolEntry)->getScope();
    fprintf(yyout, "%*cId\tname: %s\tscope: %d\ttype: %s\n", level, ' ',
            name.c_str(), scope, type.c_str());
}

/*函数调用表达式 函数名 作用域 类型*/
void FuncCallExp::output(int level)
{
    std::string name, type;
    int scope;
    name = symbolEntry->toStr();
    type = symbolEntry->getType()->toStr();
    scope = dynamic_cast<IdentifierSymbolEntry*>(symbolEntry)->getScope();
    fprintf(yyout, "%*cFunctionCall function name: %s, scope: %d, type: %s\n", level, ' ', 
            name.c_str(), scope, type.c_str());
    if(params) params->output(level + 4);
}

void CompoundStmt::output(int level)
{
    fprintf(yyout, "%*cCompoundStmt\n", level, ' ');
    if(stmt) stmt->output(level + 4);
}

void SeqNode::output(int level)
{
    fprintf(yyout, "%*cSequence\n", level, ' ');
    stmt1->output(level + 4);
    stmt2->output(level + 4);
}

/*变量声明和定义*/
void VarDecl::output(int level)
{
    fprintf(yyout, "%*cVarDecl\n", level, ' ');
    prevdef->output(level + 4);
    def->output(level + 4);
}

void VarDef::output(int level)
{
    fprintf(yyout, "%*cVarDef\n", level, ' ');
    id->output(level + 4);
    if(expr) expr->output(level + 4);
}

/*常量函数和定义*/
void ConstDecl::output(int level)
{
    fprintf(yyout, "%*cConstDecl\n", level, ' ');
    prevdef->output(level + 4);
    def->output(level + 4);
}

void ConstDef::output(int level)
{
    fprintf(yyout, "%*cConstDef\n", level, ' ');
    id->output(level + 4);
    expr->output(level + 4);
}

void IfStmt::output(int level)
{
    fprintf(yyout, "%*cIfStmt\n", level, ' ');
    cond->output(level + 4);
    thenStmt->output(level + 4);
}

void FuncParam::output(int level)
{
    fprintf(yyout, "%*cFuncParam\n", level, ' ');
    id->output(level + 4);
    if(expr) expr->output(level + 4);
}

void FuncParams::output(int level)
{
    fprintf(yyout, "%*cFuncParams:\n", level, ' ');
    prevparam->output(level + 4);
    param->output(level + 4);
}

void FuncRParam::output(int level)
{
    fprintf(yyout, "%*cFuncRealParam\n", level, ' ');
    param->output(level + 4);
}

void FuncRParams::output(int level)
{
    fprintf(yyout, "%*cFuncRealParams:\n", level, ' ');
    prevparam->output(level + 4);
    param->output(level + 4);
}

void IfElseStmt::output(int level)
{
    fprintf(yyout, "%*cIfElseStmt\n", level, ' ');
    cond->output(level + 4);
    thenStmt->output(level + 4);
    elseStmt->output(level + 4);
}

void WhileStmt::output(int level)
{
    fprintf(yyout, "%*cWhileStmt\n", level, ' ');
    cond->output(level + 4);
    stmt->output(level + 4);
}

void BreakStmt::output(int level)
{
    fprintf(yyout, "%*cBreakStmt\n", level, ' ');
}

void ContinueStmt::output(int level)
{
    fprintf(yyout, "%*cContinueStmt\n", level, ' ');
}

void ReturnStmt::output(int level)
{
    fprintf(yyout, "%*cReturnStmt\n", level, ' ');
    if(retValue) retValue->output(level + 4);
}

void AssignStmt::output(int level)
{
    fprintf(yyout, "%*cAssignStmt\n", level, ' ');
    lval->output(level + 4);
    expr->output(level + 4);
}

void FunctionDef::output(int level)
{
    std::string name, type;
    name = se->toStr();
    type = se->getType()->toStr();
    fprintf(yyout, "%*cFunctionDefine function name: %s, type: %s\n", level, ' ', 
            name.c_str(), type.c_str());
    if(params) params->output(level + 4);
    stmt->output(level + 4);
}

void EmptyStmt::output(int level)
{
    fprintf(yyout, "%*cEmptyStmt\n", level, ' ');
}

void ExprStmt::output(int level){
    fprintf(yyout, "%*cExprStmt\n", level, ' ');
    expr->output(level + 4);
}