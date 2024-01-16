#ifndef __ASMBUILDER_H__
#define __ASMBUILDER_H__

#include "MachineCode.h"

// 汇编代码辅助构造类，在中间代码向目标代码进行自顶向下的转换过程中，记录当前正在翻译的函数、基本块，以便于函数、基本块及指令的插入。

class AsmBuilder
{
private:
    MachineUnit* mUnit;  // mahicne unit
    MachineFunction* mFunction; // current machine code function;
    MachineBlock* mBlock; // current machine code block;
    int cmpOpcode; // CmpInstruction opcode, for CondInstruction;
public:
    void setUnit(MachineUnit* unit) { this->mUnit = unit; };
    void setFunction(MachineFunction* func) { this->mFunction = func; };
    void setBlock(MachineBlock* block) { this->mBlock = block; };
    void setCmpOpcode(int opcode) { this->cmpOpcode = opcode; };
    MachineUnit* getUnit() { return this->mUnit; };
    MachineFunction* getFunction() { return this->mFunction; };
    MachineBlock* getBlock() { return this->mBlock; };
    int getCmpOpcode() { return this->cmpOpcode; };
    static bool is_imm_legal(int imm){
        unsigned int num = (unsigned int)imm;
        // 每次循环左移两位，看结果能否用 8 位表示
        for (int i = 0; i < 16; i++){
            if (num <= 0xff)
                return true;
            num = ((num << 2) | (num >> 30));
        }
        return false;
    }
    static char* erase_at_from_str(char* str){
        char* _str = (char*)malloc(sizeof(str)+1);
        int _i = 0;
        for(int i = 0; i < sizeof(str); i++){
            if (str[i] != '@')
                _str[_i++] = str[i];
        }
        _str[_i] = '\0';
        return _str;
    }
};


#endif