#ifndef __OPERAND_H__
#define __OPERAND_H__

#include "SymbolTable.h"
#include <vector>

class Instruction;
class Function;

// class Operand - The operand of an instruction. ������
class Operand
{
typedef std::vector<Instruction *>::iterator use_iterator;

private:
    Instruction *def;                // The instruction where this operand is defined. ֻ��һ��
    std::vector<Instruction *> uses; // Intructions that use this operand. �����ж��
    SymbolEntry *se;                 // The symbol entry of this operand. ���ڻ�ȡType
public:
    Operand(SymbolEntry*se) :se(se){def = nullptr;};
    void setDef(Instruction *inst) {def = inst;};
    void addUse(Instruction *inst) { uses.push_back(inst);};
    void removeUse(Instruction *inst);
    int usersNum() const {return uses.size();};
    /*�������� ��2*/
    Instruction *getDef() { return def; };  
    std::vector<Instruction *> &getUse() { return uses; }; 

    use_iterator use_begin() {return uses.begin();};
    use_iterator use_end() {return uses.end();};
    SymbolEntry* getSymbolEntry(){return se;}
    Type* getType() {return se->getType();};
    std::string toStr() const;
    SymbolEntry * getEntry() { return se; };
};

#endif