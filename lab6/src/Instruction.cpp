#include "Instruction.h"
#include "BasicBlock.h"
#include <iostream>
#include "Function.h"
#include "Type.h"
extern FILE* yyout;

Instruction::Instruction(unsigned instType, BasicBlock *insert_bb)
{
    prev = next = this;
    opcode = -1;
    this->instType = instType;
    if (insert_bb != nullptr)
    {
        insert_bb->insertBack(this);
        parent = insert_bb;
    }
}

Instruction::~Instruction()
{
    parent->remove(this);
}

BasicBlock *Instruction::getParent()
{
    return parent;
}

void Instruction::setParent(BasicBlock *bb)
{
    parent = bb;
}

void Instruction::setNext(Instruction *inst)
{
    next = inst;
}

void Instruction::setPrev(Instruction *inst)
{
    prev = inst;
}

Instruction *Instruction::getNext()
{
    return next;
}

Instruction *Instruction::getPrev()
{
    return prev;
}

BinaryInstruction::BinaryInstruction(unsigned opcode, Operand *dst, Operand *src1, Operand *src2, BasicBlock *insert_bb) : Instruction(BINARY, insert_bb)
{
    this->opcode = opcode;
    operands.push_back(dst);
    operands.push_back(src1);
    operands.push_back(src2);
    dst->setDef(this); // ָ�����dst
    src1->addUse(this); // ָ��ʹ����src
    src2->addUse(this);
}

BinaryInstruction::~BinaryInstruction()
{
    operands[0]->setDef(nullptr); // ����dst�Ķ���
    if(operands[0]->usersNum() == 0) // ���û��ָ��ʹ���ˣ����ͷ�
        delete operands[0];
    operands[1]->removeUse(this);
    operands[2]->removeUse(this);
}

void BinaryInstruction::output() const
{
    std::string s1, s2, s3, op, type;
    s1 = operands[0]->toStr();
    s2 = operands[1]->toStr();
    s3 = operands[2]->toStr();
    type = operands[0]->getType()->toStr();
    if(type=="const") type = "i32";
    if(type=="const*") type = "i32*";
    switch (opcode)
    {
    case ADD:
        op = "add";
        break;
    case SUB:
        op = "sub";
        break;
    case MUL:
        op = "mul";
        break;
    case DIV:
        op = "sdiv";
        break;
    case MOD:
        op = "srem";
        break;
    default:
        break;
    }
    fprintf(yyout, "  %s = %s %s %s, %s\n", s1.c_str(), op.c_str(), type.c_str(), s2.c_str(), s3.c_str());
}

UnaryInstruction::UnaryInstruction(unsigned opcode, Operand *dst, Operand *src, BasicBlock *insert_bb) : Instruction(UNARY, insert_bb)
{
    this->opcode = opcode;
    operands.push_back(dst);
    operands.push_back(src);
    dst->setDef(this);
    src->addUse(this);
}

UnaryInstruction::~UnaryInstruction()
{
    operands[0]->setDef(nullptr);
    if(operands[0]->usersNum() == 0)
        delete operands[0];
    operands[1]->removeUse(this);
}

void UnaryInstruction::output() const
{
    std::string s1, s2, op, type;
    s1 = operands[0]->toStr();
    s2 = operands[1]->toStr();
    type = operands[0]->getType()->toStr();
    if(type=="const") type = "i32";
    if(type=="const*") type = "i32*";
    switch (opcode)
    {
    case ADD:
        op = "add";
        break;
    case SUB:
        op = "sub"; 
        break;
    /*
    case NOT: // ȡ��Ҫ����������
        op = "xor";
        fprintf(yyout, "  %s = %s %s %s\n", s1.c_str(), op.c_str(), type.c_str(), s2.c_str());
        break;
    */
    default:
        break;
    }
    fprintf(yyout, "  %s = %s i32 0, %s\n", s1.c_str(), op.c_str(), s2.c_str());
}

CmpInstruction::CmpInstruction(unsigned opcode, Operand *dst, Operand *src1, Operand *src2, BasicBlock *insert_bb): Instruction(CMP, insert_bb){
    this->opcode = opcode;
    operands.push_back(dst);
    operands.push_back(src1);
    operands.push_back(src2);
    dst->setDef(this);
    src1->addUse(this);
    src2->addUse(this);
}

CmpInstruction::~CmpInstruction()
{
    operands[0]->setDef(nullptr);
    if(operands[0]->usersNum() == 0)
        delete operands[0];
    operands[1]->removeUse(this);
    operands[2]->removeUse(this);
}

void CmpInstruction::output() const
{
    std::string s1, s2, s3, op, type;
    s1 = operands[0]->toStr();
    s2 = operands[1]->toStr();
    s3 = operands[2]->toStr();
    type = operands[1]->getType()->toStr();
    if(type=="const") type = "i32";
    if(type=="const*") type = "i32*";
    switch (opcode)
    {
    case E:
        op = "eq";
        break;
    case NE:
        op = "ne";
        break;
    case L:
        op = "slt";
        break;
    case LE:
        op = "sle";
        break;
    case G:
        op = "sgt";
        break;
    case GE:
        op = "sge";
        break;
    default:
        op = "";
        break;
    }

    fprintf(yyout, "  %s = icmp %s %s %s, %s\n", s1.c_str(), op.c_str(), type.c_str(), s2.c_str(), s3.c_str());
}

UncondBrInstruction::UncondBrInstruction(BasicBlock *to, BasicBlock *insert_bb) : Instruction(UNCOND, insert_bb)
{
    branch = to;
}

void UncondBrInstruction::output() const
{
    fprintf(yyout, "  br label %%B%d\n", branch->getNo());
}

void UncondBrInstruction::setBranch(BasicBlock *bb)
{
    branch = bb;
}

BasicBlock *UncondBrInstruction::getBranch()
{
    return branch;
}

CondBrInstruction::CondBrInstruction(BasicBlock*true_branch, BasicBlock*false_branch, Operand *cond, BasicBlock *insert_bb) : Instruction(COND, insert_bb){
    this->true_branch = true_branch;
    this->false_branch = false_branch;
    cond->addUse(this);
    operands.push_back(cond);
}

CondBrInstruction::~CondBrInstruction()
{
    operands[0]->removeUse(this);
}

void CondBrInstruction::output() const
{
    std::string cond, type;
    cond = operands[0]->toStr();
    type = operands[0]->getType()->toStr();
    if(type=="const") type = "i32";
    if(type=="const*") type = "i32*";
    int true_label = true_branch->getNo();
    int false_label = false_branch->getNo();
    fprintf(yyout, "  br %s %s, label %%B%d, label %%B%d\n", type.c_str(), cond.c_str(), true_label, false_label);
}

void CondBrInstruction::setFalseBranch(BasicBlock *bb)
{
    false_branch = bb;
}

BasicBlock *CondBrInstruction::getFalseBranch()
{
    return false_branch;
}

void CondBrInstruction::setTrueBranch(BasicBlock *bb)
{
    true_branch = bb;
}

BasicBlock *CondBrInstruction::getTrueBranch()
{
    return true_branch;
}

RetInstruction::RetInstruction(Operand *src, BasicBlock *insert_bb) : Instruction(RET, insert_bb)
{
    if(src != nullptr)
    {
        operands.push_back(src);
        src->addUse(this);
    }
}

RetInstruction::~RetInstruction()
{
    if(!operands.empty())
        operands[0]->removeUse(this);
}

void RetInstruction::output() const
{
    if(operands.empty())
    {
        fprintf(yyout, "  ret void\n");
    }
    else
    {
        std::string ret, type;
        ret = operands[0]->toStr();
        type = operands[0]->getType()->toStr();
        if(type=="const") type = "i32";
        if(type=="const*") type = "i32*";
        fprintf(yyout, "  ret %s %s\n", type.c_str(), ret.c_str());
    }
}

AllocaInstruction::AllocaInstruction(Operand *dst, SymbolEntry *se, BasicBlock *insert_bb) : Instruction(ALLOCA, insert_bb)
{
    operands.push_back(dst);
    dst->setDef(this);
    this->se = se;
}

AllocaInstruction::~AllocaInstruction()
{
    operands[0]->setDef(nullptr);
    if(operands[0]->usersNum() == 0)
        delete operands[0];
}

void AllocaInstruction::output() const
{
    std::string dst, type;
    dst = operands[0]->toStr();
    type = se->getType()->toStr();
    if(type=="const") type = "i32";
    if(type=="const*") type = "i32*";
    fprintf(yyout, "  %s = alloca %s, align 4\n", dst.c_str(), type.c_str());
}

GlobalAllocaInstruction::GlobalAllocaInstruction(Operand *dst, SymbolEntry *se, Operand *value, BasicBlock* insert_bb) : Instruction(GLOBAL, insert_bb)
{
    operands.push_back(dst);
    dst->setDef(this);
    this->se = se;
    this->value = value;
}

GlobalAllocaInstruction::~GlobalAllocaInstruction()
{
    operands[0]->setDef(nullptr);
    if(operands[0]->usersNum() == 0)
        delete operands[0];
}

void GlobalAllocaInstruction::output() const
{
    std::string dst, type;
    dst = operands[0]->toStr();
    type = se->getType()->toStr();
    std::string name = static_cast<IdentifierSymbolEntry*>(se)->get_name(); // ȫ�ֱ�����
    int val = 0;
    if(value)
        val = static_cast<ConstantSymbolEntry*>(value->getSymbolEntry())->getValue();
    if(type=="i32")
        fprintf(yyout, "@%s = dso_local global i32 %d, align 4\n", name.c_str(), val);
    else if(type == "const")
        fprintf(yyout, "@%s = dso_local constant i32 %d, align 4\n", name.c_str(), val);
}

LoadInstruction::LoadInstruction(Operand *dst, Operand *src_addr, BasicBlock *insert_bb) : Instruction(LOAD, insert_bb)
{
    operands.push_back(dst);
    operands.push_back(src_addr);
    dst->setDef(this);
    src_addr->addUse(this);
}

LoadInstruction::~LoadInstruction()
{
    operands[0]->setDef(nullptr);
    if(operands[0]->usersNum() == 0)
        delete operands[0];
    operands[1]->removeUse(this);
}

void LoadInstruction::output() const
{
    std::string dst = operands[0]->toStr();
    std::string src = operands[1]->toStr();
    std::string src_type;
    std::string dst_type;
    dst_type = operands[0]->getType()->toStr();
    src_type = operands[1]->getType()->toStr();
    if(dst_type=="const") dst_type = "i32";
    if(dst_type=="const*") dst_type = "i32*";
    if(src_type=="const") src_type = "i32";
    if(src_type=="const*") src_type = "i32*";
    fprintf(yyout, "  %s = load %s, %s %s, align 4\n", dst.c_str(), dst_type.c_str(), src_type.c_str(), src.c_str());
}

StoreInstruction::StoreInstruction(Operand *dst_addr, Operand *src, BasicBlock *insert_bb) : Instruction(STORE, insert_bb)
{
    operands.push_back(dst_addr);
    operands.push_back(src);
    dst_addr->addUse(this);
    src->addUse(this);
}

StoreInstruction::~StoreInstruction()
{
    operands[0]->removeUse(this);
    operands[1]->removeUse(this);
}

void StoreInstruction::output() const
{
    std::string dst = operands[0]->toStr();
    std::string src = operands[1]->toStr();
    std::string dst_type = operands[0]->getType()->toStr();
    std::string src_type = operands[1]->getType()->toStr();
    if(dst_type=="const") dst_type = "i32";
    if(dst_type=="const*") dst_type = "i32*";
    if(src_type=="const") src_type = "i32";
    if(src_type=="const*") src_type = "i32*";
    fprintf(yyout, "  store %s %s, %s %s, align 4\n", src_type.c_str(), src.c_str(), dst_type.c_str(), dst.c_str());
}

ZextInstruction::ZextInstruction(Operand *dst, Operand *src, BasicBlock *insert_bb) : Instruction(ZEXT, insert_bb)
{
    operands.push_back(dst);
    operands.push_back(src);
    dst->setDef(this);
    src->addUse(this);
}

ZextInstruction::~ZextInstruction()
{
    operands[0]->setDef(nullptr);
    if(operands[0]->usersNum() == 0)
        delete operands[0];
    operands[1]->removeUse(this);
}

void ZextInstruction::output() const
{
    std::string dst = operands[0]->toStr();
    std::string src = operands[1]->toStr();
    //std::string src_type = operands[1]->getType()->toStr();
    fprintf(yyout, "  %s = zext i1 %s to i32\n", dst.c_str(), src.c_str());
}

XorInstruction::XorInstruction(Operand *dst, Operand *src, BasicBlock *insert_bb) : Instruction(XOR, insert_bb)
{
    operands.push_back(dst);
    operands.push_back(src);
    dst->setDef(this);
    src->addUse(this);
}

XorInstruction::~XorInstruction()
{
    operands[0]->setDef(nullptr);
    if(operands[0]->usersNum() == 0)
        delete operands[0];
    operands[1]->removeUse(this);
}

void XorInstruction::output() const
{
    std::string dst = operands[0]->toStr();
    std::string src = operands[1]->toStr();
    std::string src_type = operands[1]->getType()->toStr();
    fprintf(yyout, "  %s = xor %s %s, true\n", dst.c_str(), src_type.c_str(), src.c_str());
}

CallInstruction::CallInstruction(Operand *dst, SymbolEntry *se, std::vector<Operand*> params, BasicBlock *insert_bb) : Instruction(CALL, insert_bb)
{
    this->dst = dst;
    this->func = se;
    if(dst) dst->setDef(this);
    for(auto p : params){
        operands.push_back(p);
        p->addUse(this);
    }
}

CallInstruction::~CallInstruction()
{
    if(dst){
        dst->setDef(nullptr);
        if(dst->usersNum()==0)
            delete dst;
    }
    for(long unsigned i = 0; i<operands.size(); i++)
        operands[i]->removeUse(this);
}

void CallInstruction::output() const
{
    fprintf(yyout, "  ");
    if(!dst->getType()->isVoid())
        fprintf(yyout, "%s = ", dst->toStr().c_str());
    FunctionType* type = (FunctionType*)(func->getType());
    fprintf(yyout, "call %s %s(", type->getRetType()->toStr().c_str(), func->toStr().c_str());
    for(long unsigned i = 0; i<operands.size(); i++){
        if(i!=0)
            fprintf(yyout, ",");
        fprintf(yyout, "%s %s", (operands[i]->getType()->toStr() == "const"? "i32" : operands[i]->getType()->toStr().c_str()), operands[i]->toStr().c_str());
    }
    fprintf(yyout, ")\n");
}


/*Machine Operation******************************************************************************************************************************/
MachineOperand* Instruction::genMachineOperand(Operand* ope)
{
    auto se = ope->getEntry();
    MachineOperand* mope = nullptr;
    if(se->isConstant())
        mope = new MachineOperand(MachineOperand::IMM, dynamic_cast<ConstantSymbolEntry*>(se)->getValue());
    else if(se->isTemporary())
        mope = new MachineOperand(MachineOperand::VREG, dynamic_cast<TemporarySymbolEntry*>(se)->getLabel());
    else if(se->isVariable())
    {
        auto id_se = dynamic_cast<IdentifierSymbolEntry*>(se);
        if(id_se->isGlobal())
            mope = new MachineOperand(id_se->toStr().c_str());
        else
            exit(0);
    }
    return mope;
}

MachineOperand* Instruction::genMachineReg(int reg) 
{
    return new MachineOperand(MachineOperand::REG, reg);
}

MachineOperand* Instruction::genMachineVReg() 
{
    return new MachineOperand(MachineOperand::VREG, SymbolTable::getLabel());
}

MachineOperand* Instruction::genMachineImm(int val) 
{
    return new MachineOperand(MachineOperand::IMM, val);
}

MachineOperand* Instruction::genMachineLabel(int block_no)
{
    std::ostringstream buf;
    buf << ".L" << block_no;
    std::string label = buf.str();
    return new MachineOperand(label);
}

void AllocaInstruction::genMachineCode(AsmBuilder* builder)
{
    /* HINT:
    * Allocate stack space for local variabel
    * Store frame offset in symbol entry */
    auto cur_func = builder->getFunction();
    int offset = cur_func->AllocSpace(4);
    dynamic_cast<TemporarySymbolEntry*>(operands[0]->getEntry())->setOffset(-offset);
}

void GlobalAllocaInstruction::genMachineCode(AsmBuilder* builder)
{
    //TODO
    //fprintf(stderr, "insert global\n");
    auto cur_block = builder->getBlock();
    auto cur_unit = builder->getUnit();
    MachineInstruction *cur_inst = 0;
    auto dst = genMachineOperand(operands[0]);
    std::vector<MachineOperand*> src = {};
    if(value)
        src.push_back(genMachineOperand(value));
    else{
        //fprintf(stderr, "global no value\n");
        SymbolEntry* s = new ConstantSymbolEntry(TypeSystem::constType, 0);
        Operand* n1 = new Operand(s);
        src.push_back(genMachineOperand(n1));
    }
    cur_inst = new GlobalMInstruction(cur_block, dst, src, se);
    cur_unit->InsertGlobal(dynamic_cast<GlobalMInstruction*>(cur_inst));
    /*
    if(value){
        // ������ֵ�����������ȫ�ַ����ֵ��Ŀ�Ļ���������
        auto src = genMachineOperand(value);
        cur_inst = new LoadMInstruction(cur_block, dst, src);
        cur_block->InsertInst(cur_inst);
    }*/
}

void LoadInstruction::genMachineCode(AsmBuilder* builder)
{
    auto cur_block = builder->getBlock();
    MachineInstruction* cur_inst = nullptr;
    // Load global operand
    if(operands[1]->getEntry()->isVariable()
    && dynamic_cast<IdentifierSymbolEntry*>(operands[1]->getEntry())->isGlobal())
    {
        auto dst = genMachineOperand(operands[0]);
        auto internal_reg1 = genMachineVReg();
        auto internal_reg2 = new MachineOperand(*internal_reg1);
        auto src = genMachineOperand(operands[1]);
        // example: load r0, addr_a
        cur_inst = new LoadMInstruction(cur_block, internal_reg1, src);
        cur_block->InsertInst(cur_inst);
        // example: load r1, [r0]
        cur_inst = new LoadMInstruction(cur_block, dst, internal_reg2);
        cur_block->InsertInst(cur_inst);
    }
    // Load local operand
    else if(operands[1]->getEntry()->isTemporary()
    && operands[1]->getDef()
    && operands[1]->getDef()->isAlloc())
    {
        // example: load r1, [r0, #4]
        auto dst = genMachineOperand(operands[0]);
        auto src1 = genMachineReg(11);
        int off = dynamic_cast<TemporarySymbolEntry*>(operands[1]->getEntry())->getOffset();
        auto src2 = genMachineImm(off);
        if (off > 255 || off < -255)
        {
            fprintf(stderr, "%d", off);
            auto operand = genMachineVReg();
            if (AsmBuilder::is_imm_legal(off))
                cur_block->InsertInst((new LoadMInstruction(cur_block, operand, src2)));
            else
            {
                cur_block->InsertInst(new MovMInstruction(cur_block, MovMInstruction::MOV, operand, genMachineImm(off & 0xffff)));
                if (off & 0xffff00)
                    cur_block->InsertInst(new BinaryMInstruction(cur_block, BinaryMInstruction::ADD, operand, operand, genMachineImm(off & 0xff0000)));
                if (off & 0xff000000)
                    cur_block->InsertInst(new BinaryMInstruction(cur_block, BinaryMInstruction::ADD, operand, operand, genMachineImm(off & 0xff000000)));
            }
            src2 = operand;
        }
        cur_inst = new LoadMInstruction(cur_block, dst, src1, src2);
        cur_block->InsertInst(cur_inst);
    }
    // Load operand from temporary variable
    else
    {
        // example: load r1, [r0]
        auto dst = genMachineOperand(operands[0]);
        auto src = genMachineOperand(operands[1]);
        cur_inst = new LoadMInstruction(cur_block, dst, src);
        cur_block->InsertInst(cur_inst);
    }
}

void StoreInstruction::genMachineCode(AsmBuilder* builder)
{
    // TODO
    auto cur_block = builder->getBlock();
    MachineInstruction* cur_inst = nullptr;

    MachineOperand* dst = nullptr;
    MachineOperand* src = nullptr;

    dst = genMachineOperand(operands[0]);
    src = genMachineOperand(operands[1]);

    // store immediate
    if (operands[1]->getEntry()->isConstant()) {
        fprintf(stderr, "store immediate\n");
        auto dst1 = genMachineVReg();
        cur_inst = new LoadMInstruction(cur_block, dst1, src);
        cur_block->InsertInst(cur_inst);
        src = new MachineOperand(*dst1);
    }

    // store to a local operand �洢һ��ջ�е���ʱ����
    if (operands[0]->getEntry()->isTemporary() && operands[0]->getDef() &&
        operands[0]->getDef()->isAlloc()) {
        // example: store r1, [r0, #4]
        fprintf(stderr, "store local\n");
        auto src1 = genMachineReg(11);
        int off = dynamic_cast<TemporarySymbolEntry*>(operands[0]->getEntry())
                      ->getOffset();
        auto src2 = genMachineImm(off);
        if (src->isImm())
        {
            int off = src->getVal();
            auto operand = genMachineVReg();
            if (AsmBuilder::is_imm_legal(off))
                cur_block->InsertInst((new LoadMInstruction(cur_block, operand, src)));
            else
            {
                cur_block->InsertInst(new MovMInstruction(cur_block, MovMInstruction::MOV, operand, genMachineImm(off & 0xffff)));
                if (off & 0xffff00)
                    cur_block->InsertInst(new BinaryMInstruction(cur_block, BinaryMInstruction::ADD, operand, operand, genMachineImm(off & 0xff0000)));
                if (off & 0xff000000)
                    cur_block->InsertInst(new BinaryMInstruction(cur_block, BinaryMInstruction::ADD, operand, operand, genMachineImm(off & 0xff000000)));
            }
            src = new MachineOperand(*operand);
        }
        cur_inst = new StoreMInstruction(cur_block, src, src1, src2);
        cur_block->InsertInst(cur_inst);
    }

    // store to global
    else if (operands[0]->getEntry()->isVariable() &&
             dynamic_cast<IdentifierSymbolEntry*>(operands[0]->getEntry())
                 ->isGlobal()) {
        fprintf(stderr, "store local\n");
        auto internal_reg1 = genMachineVReg();
        auto internal_reg2 = new MachineOperand(*internal_reg1);
        // example: load r0, addr_a
        cur_inst = new LoadMInstruction(cur_block, internal_reg2, dst);
        cur_block->InsertInst(cur_inst);
        // example: store r1, [r0]
        cur_inst = new StoreMInstruction(cur_block, src, internal_reg2);
        cur_block->InsertInst(cur_inst);
    }
}

void BinaryInstruction::genMachineCode(AsmBuilder* builder)
{
    // complete other instructions
    auto cur_block = builder->getBlock();
    auto dst = genMachineOperand(operands[0]);
    auto src1 = genMachineOperand(operands[1]);
    auto src2 = genMachineOperand(operands[2]);
    /* HINT:
    * The source operands of ADD instruction in ir code both can be immediate num.
    * However, it's not allowed in assembly code.
    * So you need to insert LOAD/MOV instrucrion to load immediate num into register.
    * As to other instructions, such as MUL, CMP, you need to deal with this situation, too.*/
    MachineInstruction* cur_inst = nullptr;
    if(src1->isImm())
    {
        auto internal_reg = genMachineVReg();
        cur_inst = new LoadMInstruction(cur_block, internal_reg, src1);
        cur_block->InsertInst(cur_inst);
        src1 = new MachineOperand(*internal_reg);
    }
    switch (opcode)
    {
    case ADD:
        cur_inst = new BinaryMInstruction(cur_block, BinaryMInstruction::ADD, dst, src1, src2);
        break;
    case SUB:
        cur_inst = new BinaryMInstruction(cur_block, BinaryMInstruction::SUB, dst, src1, src2);
        break;
    case MUL:
        if (src2->isImm())
        {
            auto internal_reg = genMachineVReg();
            cur_inst = new LoadMInstruction(cur_block, internal_reg, src2);
            cur_block->InsertInst(cur_inst);
            src2 = new MachineOperand(*internal_reg);
        }
        cur_inst = new BinaryMInstruction(cur_block, BinaryMInstruction::MUL, dst, src1, src2);
        break;
    case DIV:
        if (src2->isImm())
        {
            auto internal_reg = genMachineVReg();
            cur_inst = new LoadMInstruction(cur_block, internal_reg, src2);
            cur_block->InsertInst(cur_inst);
            src2 = new MachineOperand(*internal_reg);
        }
        cur_inst = new BinaryMInstruction(cur_block, BinaryMInstruction::DIV, dst, src1, src2);
        break;
    case MOD:
    {
        // a%b = a-(a/b)*b
        if (src2->isImm())
        {
            auto internal_reg = genMachineVReg();
            cur_inst = new LoadMInstruction(cur_block, internal_reg, src2);
            cur_block->InsertInst(cur_inst);
            src2 = new MachineOperand(*internal_reg);
        }
        // DIV
        auto dst_div = genMachineVReg();
        cur_inst = new BinaryMInstruction(cur_block, BinaryMInstruction::DIV, dst_div, src1, src2);
        cur_block->InsertInst(cur_inst);
        // MUL
        auto dst_mul = genMachineVReg();
        cur_inst = new BinaryMInstruction(cur_block, BinaryMInstruction::MUL, dst_mul, dst_div, src2);
        cur_block->InsertInst(cur_inst);
        // SUB
        cur_inst = new BinaryMInstruction(cur_block, BinaryMInstruction::SUB, dst, src1, dst_mul);
        break;
    }
    default:
        break;
    }
    cur_block->InsertInst(cur_inst);
}

void UnaryInstruction::genMachineCode(AsmBuilder* builder)
{
    auto cur_block = builder->getBlock();
    auto dst = genMachineOperand(operands[0]);
    auto src = genMachineOperand(operands[1]);
    MachineInstruction* cur_inst = nullptr;
    auto internal_reg = genMachineVReg();
    cur_inst = new MovMInstruction(cur_block, MovMInstruction::MOV, internal_reg, genMachineImm(0));
    cur_block->InsertInst(cur_inst);
    MachineOperand* imm_0 = new MachineOperand(*internal_reg);
    if(src->isImm())
    {
        auto internal_reg = genMachineVReg();
        cur_inst = new LoadMInstruction(cur_block, internal_reg, src);
        cur_block->InsertInst(cur_inst);
        src = new MachineOperand(*internal_reg);
    }
    switch (opcode)
    {
    case ADD:
        cur_inst = new BinaryMInstruction(cur_block, BinaryMInstruction::ADD, dst, imm_0, src);
        break;
    case SUB:
        cur_inst = new BinaryMInstruction(cur_block, BinaryMInstruction::SUB, dst, imm_0, src);
        break;
    default:
        break;
    }
    cur_block->InsertInst(cur_inst);
}

void CmpInstruction::genMachineCode(AsmBuilder* builder)
{
    auto cur_block = builder->getBlock();
    auto src1 = genMachineOperand(operands[1]);
    auto src2 = genMachineOperand(operands[2]);
    MachineInstruction *cur_inst = nullptr;
    // cmp R,R OR cmp R,#imm
    if (src1->isImm())
    {
        auto internal_reg = genMachineVReg();
        cur_inst = new LoadMInstruction(cur_block, internal_reg, src1);
        cur_block->InsertInst(cur_inst);
        src1 = new MachineOperand(*internal_reg);
    }
    if (src2->isImm())
    {
        auto internal_reg = genMachineVReg();
        cur_inst = new LoadMInstruction(cur_block, internal_reg, src2);
        cur_block->InsertInst(cur_inst);
        src2 = new MachineOperand(*internal_reg);
    }
    cur_inst = new CmpMInstruction(cur_block, src1, src2);
    cur_block->InsertInst(cur_inst);

    auto dst = genMachineOperand(operands[0]);
    int OP_TRUE = INT16_MIN;
    int OP_FALSE = INT16_MIN;
    switch (opcode)
    {
    case E:
        OP_TRUE = CmpMInstruction::EQ;
        OP_FALSE = CmpMInstruction::NE;
        break;
    case NE:
        OP_TRUE = CmpMInstruction::NE;
        OP_FALSE = CmpMInstruction::EQ;
        break;
    case L:
        OP_TRUE = CmpMInstruction::LT;
        OP_FALSE = CmpMInstruction::GE;
        break;
    case LE:
        OP_TRUE = CmpMInstruction::LE;
        OP_FALSE = CmpMInstruction::GT;
        break;
    case G:
        OP_TRUE = CmpMInstruction::GT;
        OP_FALSE = CmpMInstruction::LE;
        break;
    case GE:
        OP_TRUE = CmpMInstruction::GE;
        OP_FALSE = CmpMInstruction::LT;
        break;
    default:
        break;
    }
    MachineOperand* One = genMachineImm(1);
    MachineOperand* Zero = genMachineImm(0);
    cur_block->InsertInst(new MovMInstruction(cur_block, MovMInstruction::MOV, dst, One, OP_TRUE));
    cur_block->InsertInst(new MovMInstruction(cur_block, MovMInstruction::MOV, dst, Zero, OP_FALSE));
    builder->setCmpOpcode(OP_TRUE);
}

void UncondBrInstruction::genMachineCode(AsmBuilder* builder)
{
    auto cur_block = builder->getBlock();
    MachineOperand* dst = genMachineLabel(branch->getNo());
    cur_block->InsertInst(new BranchMInstruction(cur_block, BranchMInstruction::B, dst));
}

void CondBrInstruction::genMachineCode(AsmBuilder* builder)
{
    auto cur_block = builder->getBlock();
    auto Cond = builder->getCmpOpcode();
    auto dst = genMachineLabel(true_branch->getNo());
    cur_block->InsertInst(new BranchMInstruction(cur_block, BranchMInstruction::B, dst, Cond));//������ת
    dst = genMachineLabel(false_branch->getNo());
    cur_block->InsertInst(new BranchMInstruction(cur_block, BranchMInstruction::B, dst));
}

void RetInstruction::genMachineCode(AsmBuilder* builder)
{
    /* HINT:
    * 1. Generate mov instruction to save return value in r0
    * 2. Restore callee saved registers and sp, fp
    * 3. Generate bx instruction */
    auto bb = builder->getBlock();
    if (!operands.empty())
    {
        auto dst = genMachineReg(0);
        auto src = genMachineOperand(operands[0]);
        // ���淵��ֵ
        bb->InsertInst(new MovMInstruction(bb, MovMInstruction::MOV, dst, src));
    }

    bb->InsertInst(new BinaryMInstruction(bb, BinaryMInstruction::SUB, genMachineReg(13), genMachineReg(11), genMachineImm(0)));
    bb->InsertInst(new BranchMInstruction(bb, BranchMInstruction::BX, genMachineReg(14)));
}

void ZextInstruction::genMachineCode(AsmBuilder* builder)
{
    auto cur_block = builder->getBlock();
    auto dst = genMachineOperand(operands[0]);
    auto src = genMachineOperand(operands[1]);
    MachineInstruction *cur_inst = new MovMInstruction(cur_block, MovMInstruction::MOV, dst, src);
    cur_block->InsertInst(cur_inst);
}

void XorInstruction::genMachineCode(AsmBuilder* builder)
{
    MachineBlock *cur_block = builder->getBlock();
    MovMInstruction *cur_inst = new MovMInstruction(cur_block, MovMInstruction::MOV, genMachineOperand(operands[0]), genMachineImm(1), MachineInstruction::EQ);
    cur_block->InsertInst(cur_inst);
    cur_inst = new MovMInstruction(cur_block, MovMInstruction::MOV, genMachineOperand(operands[0]), genMachineImm(0), MachineInstruction::NE);
    cur_block->InsertInst(cur_inst);
}

void CallInstruction::genMachineCode(AsmBuilder* builder)
{
    auto cur_block = builder->getBlock();
    MachineInstruction *cur_inst = 0;

    for (unsigned int i = 0; i < operands.size(); i++)
    {
        fprintf(stderr, "passing param\n");
        // ����ֵ���ݰ�˳�����ڼĴ���r0,r1,r2,r3�����4������ֵ�������ջ��
        // r0���ڴ�ŷ���ֵ
        if (i >= 4)
        {
            auto reg1 = genMachineVReg();
            cur_inst = new MovMInstruction(cur_block, MovMInstruction::MOV, reg1, genMachineOperand(operands[i]));
            cur_block->InsertInst(cur_inst);
            cur_inst = new StoreMInstruction(cur_block, reg1, genMachineReg(13), genMachineImm(-(operands.size() - i) * 4));
            cur_block->InsertInst(cur_inst);
            builder->getFunction()->AllocSpace(4);

            continue;
        }
        else
        {
            // auto reg1 = genMachineVReg();
            cur_inst = new MovMInstruction(cur_block, MovMInstruction::MOV, genMachineReg(i), genMachineOperand(operands[i]));
            cur_block->InsertInst(cur_inst);
        }
    }
    if (operands.size() > 5)
    {
        cur_inst = new BinaryMInstruction(nullptr, BinaryMInstruction::SUB, genMachineReg(13), genMachineReg(13), genMachineImm((operands.size() - 5) * 4));
        cur_block->InsertInst(cur_inst);
    }
    // example:  bl func
    std::string label = dynamic_cast<IdentifierSymbolEntry *>(this->getEntry())->get_name();
    auto dst = new MachineOperand(label, 1);
    cur_inst = new BranchMInstruction(cur_block, BranchMInstruction::BL, dst);
    cur_block->InsertInst(cur_inst);

    if (operands.size() > 5)
    {
        auto off = genMachineImm((operands.size() - 5) * 4);
        auto sp = new MachineOperand(MachineOperand::REG, 13);
        cur_inst = new BinaryMInstruction(cur_block, BinaryMInstruction::ADD,
                                          sp, sp, off);
        cur_block->InsertInst(cur_inst);
    }

    // save the return value
    if (dynamic_cast<FunctionType *>(this->getEntry()->getType())->getRetType()->toStr() != "void")
    {
        auto ret = genMachineOperand(operands[0]);
        // r0�洢��������ֵ
        auto r0 = genMachineReg(0);
        cur_inst = new MovMInstruction(cur_block, MovMInstruction::MOV, ret, r0);
        cur_block->InsertInst(cur_inst);
    }
}