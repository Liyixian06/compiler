#ifndef __OPERAND_H__
#define __OPERAND_H__

#include "SymbolTable.h"
#include <vector>

class Instruction;
class Function;

// class Operand - The operand of an instruction. 操作数
class Operand
{
typedef std::vector<Instruction *>::iterator use_iterator;

private:
    Instruction *def;                // The instruction where this operand is defined. 只有一个
    std::vector<Instruction *> uses; // Intructions that use this operand. 可能有多个
    SymbolEntry *se;                 // The symbol entry of this operand. 用于获取Type
public:
    Operand(SymbolEntry*se) :se(se){def = nullptr;};
    void setDef(Instruction *inst) {def = inst;};
    void addUse(Instruction *inst) { uses.push_back(inst);};
    void removeUse(Instruction *inst);
    int usersNum() const {return uses.size();};

    use_iterator use_begin() {return uses.begin();};
    use_iterator use_end() {return uses.end();};
    SymbolEntry* getSymbolEntry(){return se;}
    Type* getType() {return se->getType();};
    std::string toStr() const;
};

#endif