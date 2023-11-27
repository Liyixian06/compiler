#ifndef __AST_H__
#define __AST_H__

#include <fstream>

class SymbolEntry;

class Node
{
private:
    static int counter; // 跟踪节点数量
    int seq; // 节点序列号
public:
    Node();
    int getSeq() const {return seq;}; // 返回节点序列号
    virtual void output(int level) = 0;
};

// 表达式节点，存储的是等号左侧的符号表表项
class ExprNode : public Node 
{
protected:
    SymbolEntry *symbolEntry; // 存储等号左侧的符号表信息
public:
    ExprNode(SymbolEntry *symbolEntry) : symbolEntry(symbolEntry){};
};

// 双目运算，等号右侧的表项
class BinaryExpr : public ExprNode
{
private:
    int op;
    ExprNode *expr1, *expr2;
public:
    enum {ADD, SUB, MUL, DIV, MOD, AND, OR, EQUAL, NOTEQUAL, LESS, GREATER, LESSEQUAL, GREATEREQUAL}; // 补充operator
    BinaryExpr(SymbolEntry *se, int op, ExprNode*expr1, ExprNode*expr2) : ExprNode(se), op(op), expr1(expr1), expr2(expr2){};
    void output(int level);
};

/*单目运算*/
class UnaryExpr : public ExprNode
{
private:
    int op;
    ExprNode *expr;
public:
    enum {ADD, SUB, NOT};
    UnaryExpr(SymbolEntry *se, int op, ExprNode*expr) : ExprNode(se), op(op), expr(expr){}; // 类双目的构造
    void output(int level);
};

class Constant : public ExprNode
{
private:
    int scale; // 进制 0:decimal, 1:hex, 2:oct
public:
    Constant(SymbolEntry *se, int scale=0) : ExprNode(se), scale(scale){};
    void output(int level);
};

class Id : public ExprNode
{
public:
    Id(SymbolEntry *se) : ExprNode(se){};
    void output(int level);
};

/*函数调用*/
class FuncCallExp : public ExprNode
{
private:
    SymbolEntry* st;
    ExprNode* params; // 参数
public:
    FuncCallExp(SymbolEntry *se, SymbolEntry* st, ExprNode *params = nullptr) : ExprNode(se), st(st), params(params){};
    void output(int level);
};

// 语句节点
class StmtNode : public Node{};

// 复合语句
class CompoundStmt : public StmtNode
{
private:
    StmtNode *stmt;
public:
    CompoundStmt(StmtNode *stmt = nullptr) : stmt(stmt) {};
    void output(int level);
};

// ？语句序列
class SeqNode : public StmtNode
{
private:
    StmtNode *stmt1, *stmt2;
public:
    SeqNode(StmtNode *stmt1, StmtNode *stmt2) : stmt1(stmt1), stmt2(stmt2){};
    void output(int level);
};

/*变量声明（语句*2）及定义（标识符+表达式）*/
class VarDecl : public StmtNode
{
private:
    StmtNode *prevdef;
    StmtNode *def;
public:
    VarDecl(StmtNode *prevdef, StmtNode *def) : prevdef(prevdef), def(def){};
    void output(int level);
};

class VarDef : public StmtNode
{
private:
    Id *id;
    ExprNode *expr; // 为空表示只声明，不赋初值
public:
    VarDef(Id *id, ExprNode *expr = nullptr) : id(id), expr(expr){};
    void output(int level);
};

/*常量声明（语句*2）及定义（标识符+表达式）*/
class ConstDecl : public StmtNode
{
private:
    StmtNode *prevdef;
    StmtNode *def;
public:
    ConstDecl(StmtNode *prevdef, StmtNode *def) : prevdef(prevdef), def(def){};
    void output(int level);
};

class ConstDef : public StmtNode
{
private:
    Id *id;
    ExprNode *expr;
public:
    ConstDef(Id *id, ExprNode *expr) : id(id), expr(expr){};
    void output(int level);
};

/*函数形参和实参*/
class FuncParam : public StmtNode
{
private:
    Id *id;
    ExprNode *expr;
public:
    FuncParam(Id *id, ExprNode *expr = nullptr) : id(id), expr(expr){};
    void output(int level);
};

class FuncParams : public StmtNode
{
private:
    StmtNode *prevparam;
    StmtNode *param;
public:
    FuncParams(StmtNode *prevparam, StmtNode *param) : prevparam(prevparam), param(param){};
    void output(int level);
};

class FuncRParam : public ExprNode
{
private:
    ExprNode *param;
public:
    FuncRParam(SymbolEntry *se, ExprNode *param) : ExprNode(se), param(param){};
    void output(int level);
};

class FuncRParams : public ExprNode
{
private:
    ExprNode *prevparam;
    ExprNode *param;
public:
    FuncRParams(SymbolEntry *se, ExprNode *prevparam, ExprNode *param) : ExprNode(se), prevparam(prevparam), param(param){};
    void output(int level);
};

// if语句
class IfStmt : public StmtNode
{
private:
    ExprNode *cond;
    StmtNode *thenStmt;
public:
    IfStmt(ExprNode *cond, StmtNode *thenStmt) : cond(cond), thenStmt(thenStmt){};
    void output(int level);
};

// if-else语句
class IfElseStmt : public StmtNode
{
private:
    ExprNode *cond;
    StmtNode *thenStmt;
    StmtNode *elseStmt;
public:
    IfElseStmt(ExprNode *cond, StmtNode *thenStmt, StmtNode *elseStmt) : cond(cond), thenStmt(thenStmt), elseStmt(elseStmt) {};
    void output(int level);
};

/*while break continue*/
class WhileStmt : public StmtNode
{
private:
    ExprNode *cond;
    StmtNode *stmt;
public:
    WhileStmt(ExprNode *cond, StmtNode *stmt) : cond(cond), stmt(stmt){};
    void output(int level);
};

class BreakStmt : public StmtNode
{
public:
    BreakStmt(){};
    void output(int level);
};

class ContinueStmt : public StmtNode
{
public:
    ContinueStmt(){};
    void output(int level);
};

//return语句
class ReturnStmt : public StmtNode
{
private:
    ExprNode *retValue;
public:
    ReturnStmt(ExprNode*retValue = nullptr) : retValue(retValue) {};
    void output(int level);
};

// 赋值语句
class AssignStmt : public StmtNode
{
private:
    ExprNode *lval;
    ExprNode *expr;
public:
    AssignStmt(ExprNode *lval, ExprNode *expr) : lval(lval), expr(expr) {};
    void output(int level);
};

class FunctionDef : public StmtNode
{
private:
    SymbolEntry *se; // 指向与函数相关联的符号表项
    StmtNode *stmt; // 指向函数体
    StmtNode *params; // 指向参数列表
public:
    FunctionDef(SymbolEntry *se, StmtNode *stmt, StmtNode *params = nullptr) : se(se), stmt(stmt), params(params){};
    void output(int level);
};

/*空语句&表达式语句*/
class EmptyStmt : public StmtNode
{
public:
    EmptyStmt(){};
    void output(int level);
};

class ExprStmt : public StmtNode
{
private:
    ExprNode* expr;
public:
    ExprStmt(ExprNode *expr) : expr(expr){};
    void output(int level);
};

class Ast
{
private:
    Node* root;
public:
    Ast() {root = nullptr;}
    void setRoot(Node*n) {root = n;} //抽象语法树根节点
    void output();
};

#endif
