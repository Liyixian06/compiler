#ifndef __INSTRUCTION_H__
#define __INSTRUCTION_H__

#include "Operand.h"
#include "AsmBuilder.h"
#include <vector>
#include <map>
#include <sstream>

class BasicBlock;

class Instruction
{
public:
    Instruction(unsigned instType, BasicBlock *insert_bb = nullptr);
    virtual ~Instruction();
    BasicBlock *getParent();
    bool isUncond() const {return instType == UNCOND;};
    bool isCond() const {return instType == COND;};
    bool isRet() const {return instType == RET;}
    bool isAlloc() const {return instType == ALLOCA;}
    void setParent(BasicBlock *);
    void setNext(Instruction *);
    void setPrev(Instruction *);
    Instruction *getNext();
    Instruction *getPrev();
    virtual Operand *getDef() { return nullptr; }
    virtual std::vector<Operand *> getUse() { return {}; }
    virtual void output() const = 0;
    MachineOperand* genMachineOperand(Operand*, bool is_para);
    MachineOperand* genMachineReg(int reg);
    MachineOperand* genMachineVReg();
    MachineOperand* genMachineImm(int val);
    MachineOperand* genMachineLabel(int block_no);
    virtual void genMachineCode(AsmBuilder*) = 0;
    unsigned getType() { return instType; }
    std::vector<Operand*> getOperands() { return operands; }
protected:
    unsigned instType;
    unsigned opcode;
    Instruction *prev;
    Instruction *next;
    BasicBlock *parent; // ��ָ�������ĸ���
    std::vector<Operand*> operands;
    enum {BINARY, COND, UNCOND, RET, LOAD, STORE, CMP, ALLOCA, UNARY, GLOBAL, ZEXT, XOR, CALL};
};

// meaningless instruction, used as the head node of the instruction list.
class DummyInstruction : public Instruction
{
public:
    DummyInstruction() : Instruction(-1, nullptr) {};
    void output() const {};
    void genMachineCode(AsmBuilder *) {};
};

// ����������ռ䣬dst ΪҪ����Ĳ�����
class AllocaInstruction : public Instruction
{
public:
    AllocaInstruction(Operand *dst, SymbolEntry *se, BasicBlock *insert_bb = nullptr);
    ~AllocaInstruction();
    void output() const;
    void genMachineCode(AsmBuilder *);
private:
    SymbolEntry *se; // Ҫ����ռ�ı����ı���
};

// ȫ�ֱ�������ռ�
class GlobalAllocaInstruction : public Instruction
{
public:
    GlobalAllocaInstruction(Operand *dst, SymbolEntry *se, Operand *value = nullptr, BasicBlock* insert_bb = nullptr);
    ~GlobalAllocaInstruction();
    void output() const;
    void genMachineCode(AsmBuilder *);
private:
    SymbolEntry *se;
    Operand *value; // ȫ�ֱ�����ֵ
};

// ���أ���src���ص�dst
class LoadInstruction : public Instruction
{
public:
    LoadInstruction(Operand *dst, Operand *src_addr, BasicBlock *insert_bb = nullptr);
    ~LoadInstruction();
    void output() const;
    void genMachineCode(AsmBuilder *);
};

// ��src�浽dst��ַ
class StoreInstruction : public Instruction
{
public:
    StoreInstruction(Operand *dst_addr, Operand *src, BasicBlock *insert_bb = nullptr);
    ~StoreInstruction();
    void output() const;
    void genMachineCode(AsmBuilder *);
};

class BinaryInstruction : public Instruction
{
public:
    BinaryInstruction(unsigned opcode, Operand *dst, Operand *src1, Operand *src2, BasicBlock *insert_bb = nullptr);
    ~BinaryInstruction();
    void output() const;
    void genMachineCode(AsmBuilder *);
    enum {SUB, ADD, AND, OR, MUL, DIV, MOD};
};

class UnaryInstruction : public Instruction
{
public:
    UnaryInstruction(unsigned opcode, Operand *dst, Operand *src, BasicBlock *insert_bb = nullptr);
    ~UnaryInstruction();
    void output() const;
    void genMachineCode(AsmBuilder *);
    enum {ADD, SUB, NOT};
};

class CmpInstruction : public Instruction
{
public:
    CmpInstruction(unsigned opcode, Operand *dst, Operand *src1, Operand *src2, BasicBlock *insert_bb = nullptr);
    ~CmpInstruction();
    void output() const;
    void genMachineCode(AsmBuilder *);
    enum {E, NE, L, GE, G, LE};
};

// unconditional branch
class UncondBrInstruction : public Instruction
{
public:
    UncondBrInstruction(BasicBlock*, BasicBlock *insert_bb = nullptr);
    void output() const;
    void genMachineCode(AsmBuilder *);
    void setBranch(BasicBlock *);
    BasicBlock *getBranch();
protected:
    BasicBlock *branch; // ��֧Ҫ��ת�Ŀ�
};

// conditional branch
// ���ݲ�������������ֱ���ת��true��false��
class CondBrInstruction : public Instruction
{
public:
    CondBrInstruction(BasicBlock*, BasicBlock*, Operand *, BasicBlock *insert_bb = nullptr);
    ~CondBrInstruction();
    void output() const;
    void genMachineCode(AsmBuilder *);
    enum {E, NE, L, GE, G, LE};
    void setTrueBranch(BasicBlock*);
    BasicBlock* getTrueBranch();
    void setFalseBranch(BasicBlock*);
    BasicBlock* getFalseBranch();
    void setOp(int op) { opcode = op; }
protected:
    BasicBlock* true_branch;
    BasicBlock* false_branch;
};

// ������ز�����Ϊ�վͷ���void
class RetInstruction : public Instruction
{
public:
    RetInstruction(Operand *src, BasicBlock *insert_bb = nullptr);
    ~RetInstruction();
    void output() const;
    void genMachineCode(AsmBuilder *);
};

// ����չ
class ZextInstruction : public Instruction
{
public:
    ZextInstruction(Operand *dst, Operand *src, BasicBlock *insert_bb = nullptr);
    ~ZextInstruction();
    void output() const;
    void genMachineCode(AsmBuilder *);
};

// ����ȡ����!a = a xor 1
class XorInstruction : public Instruction
{
public:
    XorInstruction(Operand *dst, Operand *src, BasicBlock *insert_bb = nullptr);
    ~XorInstruction();
    void output() const;
    void genMachineCode(AsmBuilder *);
};

// ��������
class CallInstruction : public Instruction
{
public:
    CallInstruction(Operand *dst, SymbolEntry *se, std::vector<Operand*> params = {}, BasicBlock *insert_bb = nullptr);
    ~CallInstruction();
    void output() const;
    void genMachineCode(AsmBuilder *);
    SymbolEntry* getEntry() { return this->func; }
private:
    Operand *dst; // ����ֵ��ֵ�������������һ���У�
    SymbolEntry *func; // �������
};

#endif