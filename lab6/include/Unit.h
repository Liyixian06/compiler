#ifndef __UNIT_H__
#define __UNIT_H__

#include <vector>
#include "Function.h"
#include "AsmBuilder.h"

// 函数片段的集合
class Unit
{
    typedef std::vector<Function *>::iterator iterator;
    typedef std::vector<Function *>::reverse_iterator reverse_iterator;

private:
    std::vector<Function *> func_list;
    std::vector<Instruction *> global_list;
    std::vector<IdentifierSymbolEntry*> sys_func_list;
public:
    Unit() = default;
    ~Unit() ;
    void insertFunc(Function *);
    void removeFunc(Function *);
    void output() const;
    iterator begin() { return func_list.begin(); };
    iterator end() { return func_list.end(); };
    reverse_iterator rbegin() { return func_list.rbegin(); };
    reverse_iterator rend() { return func_list.rend(); };
    void push_global(Instruction *src) { global_list.push_back(src); };
    void push_sys_func(IdentifierSymbolEntry* func) { sys_func_list.push_back(func); }
    /*新增*/
    void genMachineCode(MachineUnit* munit);
};

#endif