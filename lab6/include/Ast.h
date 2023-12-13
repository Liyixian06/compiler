#ifndef __AST_H__
#define __AST_H__

#include <fstream>
#include "Operand.h"

class SymbolEntry;
class Unit;
class Function;
class BasicBlock;
class Instruction;
class IRBuilder;

class Node
{
private:
    static int counter;
    int seq;
protected:
    // 跳转目标*不确定*的BasicBlock的列表
    std::vector<Instruction*> true_list;
    std::vector<Instruction*> false_list;
    static IRBuilder *builder;
    void backPatch(std::vector<Instruction*> &list, BasicBlock*bb);
    void unbackPatch(std::vector<Instruction*> &list, BasicBlock*bb);
    std::vector<Instruction*> merge(std::vector<Instruction*> &list1, std::vector<Instruction*> &list2);

public:
    Node();
    int getSeq() const {return seq;};
    static void setIRBuilder(IRBuilder*ib) {builder = ib;};
    virtual void output(int level) = 0;
    virtual void typeCheck() = 0;
    virtual void genCode() = 0;
    std::vector<Instruction*>& trueList() {return true_list;}
    std::vector<Instruction*>& falseList() {return false_list;}
};

static bool is_cond = false;

// 表达式节点，存储的是等号左侧的符号表表项
class ExprNode : public Node
{
protected:
    SymbolEntry *symbolEntry; // 存储等号左侧的符号表信息
    Operand *dst;   // The result of the subtree is stored into dst.
public:
    ExprNode(SymbolEntry *symbolEntry) : symbolEntry(symbolEntry){};
    Operand* getOperand() {return dst;};
    SymbolEntry* getSymPtr() {return symbolEntry;};
};

// 双目运算，等号右侧的表项
class BinaryExpr : public ExprNode
{
private:
    int op;
    ExprNode *expr1, *expr2;
public:
    enum {ADD, SUB, MUL, DIV, MOD, AND, OR, EQUAL, NOTEQUAL, LESS, GREATER, LESSEQUAL, GREATEREQUAL}; // 补充operator
    BinaryExpr(SymbolEntry *se, int op, ExprNode*expr1, ExprNode*expr2) : ExprNode(se), op(op), expr1(expr1), expr2(expr2){dst = new Operand(se);};
    void output(int level);
    void typeCheck();
    void genCode();
};

class UnaryExpr : public ExprNode
{
private:
    int op;
    ExprNode *expr;
public:
    enum {ADD, SUB, NOT};
    UnaryExpr(SymbolEntry *se, int op, ExprNode*expr) : ExprNode(se), op(op), expr(expr){dst = new Operand(se);}; // 类双目的构造
    void output(int level);
    void typeCheck();
    void genCode();
};

class Constant : public ExprNode
{
private:
    int scale; // 进制 0:decimal, 1:hex, 2:oct
public:
    Constant(SymbolEntry *se, int scale=0) : ExprNode(se){dst = new Operand(se);};
    void output(int level);
    void typeCheck();
    void genCode();
};

class Id : public ExprNode
{
public:
    Id(SymbolEntry *se) : ExprNode(se){
        SymbolEntry *temp = new TemporarySymbolEntry(se->getType(), SymbolTable::getLabel()); 
        dst = new Operand(temp);
    };
    void output(int level);
    void typeCheck();
    void genCode();
};

/*函数调用*/
class FuncCallExp : public ExprNode
{
private:
    SymbolEntry* st;
    ExprNode* params;
public:
    FuncCallExp(SymbolEntry *se, SymbolEntry* st, ExprNode *params = nullptr) : ExprNode(se), st(st), params(params){
        dst = new Operand(se);
    };
    void output(int level);
    void typeCheck();
    void genCode();
};

class StmtNode : public Node{};

class CompoundStmt : public StmtNode
{
private:
    StmtNode *stmt;
public:
    CompoundStmt(StmtNode *stmt = nullptr) : stmt(stmt) {};
    void output(int level);
    void typeCheck();
    void genCode();
};

class SeqNode : public StmtNode
{
private:
    StmtNode *stmt1, *stmt2;
public:
    SeqNode(StmtNode *stmt1, StmtNode *stmt2 = nullptr) : stmt1(stmt1), stmt2(stmt2){};
    void output(int level);
    void typeCheck();
    void genCode();
};

class VarDecl : public StmtNode
{
private:
    StmtNode *prevdef;
    StmtNode *def;
public:
    VarDecl(StmtNode *prevdef, StmtNode *def) : prevdef(prevdef), def(def){};
    void output(int level);
    void typeCheck();
    void genCode();
};

class VarDef : public StmtNode
{
private:
    Id *id;
    ExprNode *expr; // 为空表示只声明，不赋初值
public:
    VarDef(Id *id, ExprNode *expr = nullptr) : id(id), expr(expr){};
    void output(int level);
    void typeCheck();
    void genCode();
};

class ConstDecl : public StmtNode
{
private:
    StmtNode *prevdef;
    StmtNode *def;
public:
    ConstDecl(StmtNode *prevdef, StmtNode *def) : prevdef(prevdef), def(def){};
    void output(int level);
    void typeCheck();
    void genCode();
};

class ConstDef : public StmtNode
{
private:
    Id *id;
    ExprNode *expr;
public:
    ConstDef(Id *id, ExprNode *expr) : id(id), expr(expr){};
    void output(int level);
    void typeCheck();
    void genCode();
};

class FuncParam : public StmtNode
{
private:
    Id *id;
    ExprNode *expr;
public:
    FuncParam(Id *id, ExprNode *expr = nullptr) : id(id), expr(expr){};
    void output(int level);
    void typeCheck();
    void genCode();
    Id* get_id(){return id;}
};

class FuncParams : public StmtNode
{
private:
    StmtNode *prevparam;
    StmtNode *param;
public:
    FuncParams(StmtNode *prevparam, StmtNode *param = nullptr) : prevparam(prevparam), param(param){};
    void output(int level);
    void typeCheck();
    void genCode();
};

class FuncRParams : public ExprNode
{
private:
    ExprNode *prevparam;
    ExprNode *param;
public:
    FuncRParams(SymbolEntry *se, ExprNode *prevparam, ExprNode *param = nullptr) : ExprNode(se), prevparam(prevparam), param(param){dst = new Operand(se);};
    void output(int level);
    void typeCheck();
    void genCode();
};

class IfStmt : public StmtNode
{
private:
    ExprNode *cond;
    StmtNode *thenStmt;
public:
    IfStmt(ExprNode *cond, StmtNode *thenStmt) : cond(cond), thenStmt(thenStmt){};
    void output(int level);
    void typeCheck();
    void genCode();
};

class IfElseStmt : public StmtNode
{
private:
    ExprNode *cond;
    StmtNode *thenStmt;
    StmtNode *elseStmt;
public:
    IfElseStmt(ExprNode *cond, StmtNode *thenStmt, StmtNode *elseStmt) : cond(cond), thenStmt(thenStmt), elseStmt(elseStmt) {};
    void output(int level);
    void typeCheck();
    void genCode();
};

class WhileStmt : public StmtNode
{
private:
    ExprNode *cond;
    StmtNode *stmt;
    BasicBlock *cond_bb;
    BasicBlock *end_bb;
public:
    WhileStmt(ExprNode *cond, StmtNode *stmt=nullptr) : cond(cond), stmt(stmt){cond_bb = end_bb = nullptr;};
    void setStmt(StmtNode *stmt){this->stmt = stmt;};
    void output(int level);
    void typeCheck();
    void genCode();
    BasicBlock* get_cond_bb() { return cond_bb; }
    BasicBlock* get_end_bb() { return end_bb; }
};

class BreakStmt : public StmtNode
{
private:
    StmtNode* whileStmt;
public:
    BreakStmt(StmtNode* whileStmt) : whileStmt(whileStmt){};
    void output(int level);
    void typeCheck();
    void genCode();
};

class ContinueStmt : public StmtNode
{
private:
    StmtNode* whileStmt;
public:
    ContinueStmt(StmtNode* whileStmt) : whileStmt(whileStmt){};
    void output(int level);
    void typeCheck();
    void genCode();
};

class ReturnStmt : public StmtNode
{
private:
    ExprNode *retValue;
public:
    ReturnStmt(ExprNode*retValue = nullptr) : retValue(retValue) {};
    void output(int level);
    void typeCheck();
    void genCode();
};

class AssignStmt : public StmtNode
{
private:
    ExprNode *lval;
    ExprNode *expr;
public:
    AssignStmt(ExprNode *lval, ExprNode *expr) : lval(lval), expr(expr) {};
    void output(int level);
    void typeCheck();
    void genCode();
};

class FunctionDef : public StmtNode
{
private:
    SymbolEntry *se;
    StmtNode *stmt;
    StmtNode *params;
public:
    FunctionDef(SymbolEntry *se, StmtNode *stmt, StmtNode* params = nullptr) : se(se), stmt(stmt), params(params){};
    void output(int level);
    void typeCheck();
    void genCode();
};

class EmptyStmt : public StmtNode
{
public:
    EmptyStmt(){};
    void output(int level);
    void typeCheck();
    void genCode();
};

class ExprStmt : public StmtNode
{
private:
    ExprNode* expr;
public:
    ExprStmt(ExprNode *expr) : expr(expr){};
    void output(int level);
    void typeCheck();
    void genCode();
};

class Ast
{
private:
    Node* root;
public:
    Ast() {root = nullptr;}
    void setRoot(Node*n) {root = n;}
    void output();
    void typeCheck();
    void genCode(Unit *unit);
};

#endif
