#include "Function.h"
#include "Unit.h"
#include "Type.h"
#include <list>

extern FILE* yyout;

Function::Function(Unit *u, SymbolEntry *s)
{
    u->insertFunc(this);
    entry = new BasicBlock(this);
    sym_ptr = s;
    parent = u;
}

Function::~Function()
{
    //auto delete_list = block_list;
    //for (auto &i : delete_list)
    //    delete i;
    //parent->removeFunc(this);
}

// remove the basicblock bb from its block_list.
void Function::remove(BasicBlock *bb)
{
    block_list.erase(std::find(block_list.begin(), block_list.end(), bb));
}

void Function::output() const
{
    FunctionType* funcType = dynamic_cast<FunctionType*>(sym_ptr->getType());
    Type *retType = funcType->getRetType();
    int para_num = funcType->getnum();
    std::vector<Type*> params_type = funcType->get_params();
    if(para_num == 0){
        fprintf(yyout, "define %s %s() {\n", retType->toStr().c_str(), sym_ptr->toStr().c_str());
    }
    else { // 有参数时连参数一起输出
        std::string paramstr = "";
        std::vector<Type*>::iterator it;
        int i=0;
        for(it = params_type.begin(); it!=params_type.end(); it++){
            if(paramstr.size()!=0)
                paramstr += ",";
            paramstr = paramstr + " " + (*it)->toStr() + " " + this->params[i]->toStr();
            i++;
        }
        fprintf(yyout, "define %s %s(%s) {\n", retType->toStr().c_str(), sym_ptr->toStr().c_str(), paramstr.c_str());
    }
    std::set<BasicBlock *> v;
    std::list<BasicBlock *> q;
    q.push_back(entry);
    v.insert(entry);
    // 从函数的第一个块开始，输出后驱的所有块
    while (!q.empty())
    {
        auto bb = q.front();
        q.pop_front();
        bb->output();
        for (auto succ = bb->succ_begin(); succ != bb->succ_end(); succ++)
        {
            if (v.find(*succ) == v.end())
            {
                v.insert(*succ);
                q.push_back(*succ);
            }
        }
    }
    fprintf(yyout, "}\n");
}
