#include "Unit.h"
#include "Type.h"
extern FILE *yyout;

void Unit::insertFunc(Function *f)
{
    func_list.push_back(f);
}

void Unit::removeFunc(Function *func)
{
    func_list.erase(std::find(func_list.begin(), func_list.end(), func));
}

void Unit::output() const
{
    for (auto &func : func_list)
        func->output();
    for (auto &func : sys_func_list)
        func->outputsysfunc();
}

void Unit::genMachineCode(MachineUnit* munit) 
{
    AsmBuilder* builder = new AsmBuilder();
    builder->setUnit(munit);
    for(auto &global : global_list)
        global->genMachineCode(builder);
    for (auto &func : func_list)
        func->genMachineCode(builder);
}

Unit::~Unit()
{
    auto delete_list = func_list;
    for(auto &func:delete_list)
        delete func;
}


