#ifndef __IRCOMSUBEXPRELIM_H__
#define __IRCOMSUBEXPRELIM_H__

#include "Unit.h"

struct Expr
{
    Instruction *inst;
    Expr(Instruction *inst) : inst(inst){};
    // 用于调用find函数
    bool operator==(const Expr &other) const
    {
        // _TODO: 判断两个表达式是否相同
        // 两个表达式相同 <==> 两个表达式对应的指令的类型和操作数均相同
        if (inst->getType() == other.inst->getType())
        {
            // 如果类型相同，则比较操作数
            auto operands1 = inst->getOperands();
            auto operands2 = other.inst->getOperands();

            if (operands1.size() == operands2.size())
            {
                for (size_t i = 0; i < operands1.size(); ++i)
                {
                    // 操作数是否相等
                    if (operands1[i] != operands2[i])
                    {
                        return false;
                    }
                }
                // 都相等
                return true;
            }
        }

        return false;
    };
};

class IRComSubExprElim
{
private:
    Unit *unit;

    std::vector<Expr> exprVec;
    std::map<Instruction *, int> ins2Expr;
    std::map<BasicBlock *, std::set<int>> genBB;
    std::map<BasicBlock *, std::set<int>> killBB;
    std::map<BasicBlock *, std::set<int>> inBB;
    std::map<BasicBlock *, std::set<int>> outBB;

    // 跳过无需分析的指令
    bool skip(Instruction *);

    // 局部公共子表达式消除
    bool localCSE(Function *);

    // 全局公共子表达式消除
    bool globalCSE(Function *);
    void calGenKill(Function*);
    void calInOut(Function*);
    bool removeGlobalCSE(Function*);

public:
    IRComSubExprElim(Unit *unit);
    ~IRComSubExprElim();
    void pass();
};

#endif