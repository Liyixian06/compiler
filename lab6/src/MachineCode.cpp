#include "MachineCode.h"
#include "AsmBuilder.h"
#include "Type.h"
#include <string>
extern FILE* yyout;

MachineOperand::MachineOperand(int tp, int val)
{
    this->type = tp;
    if(tp == MachineOperand::IMM)
        this->val = val;
    else 
        this->reg_no = val;
}

MachineOperand::MachineOperand(std::string label)
{
    this->type = MachineOperand::LABEL;
    this->label = label;
}

MachineOperand::MachineOperand(std::string label, bool isfunc)
{
    this->type = MachineOperand::LABEL;
    this->label = label;
    this->isfunc = isfunc;
}

bool MachineOperand::operator==(const MachineOperand&a) const
{
    if (this->type != a.type)
        return false;
    if (this->type == IMM)
        return this->val == a.val;
    return this->reg_no == a.reg_no;
}

bool MachineOperand::operator<(const MachineOperand&a) const
{
    if(this->type == a.type)
    {
        if(this->type == IMM)
            return this->val < a.val;
        return this->reg_no < a.reg_no;
    }
    return this->type < a.type;

    if (this->type != a.type)
        return false;
    if (this->type == IMM)
        return this->val == a.val;
    return this->reg_no == a.reg_no;
}

void MachineOperand::PrintReg()
{
    switch (reg_no)
    {
    case 11:
        fprintf(yyout, "fp");
        break;
    case 13:
        fprintf(yyout, "sp");
        break;
    case 14:
        fprintf(yyout, "lr"); // link register，保存函数返回地址
        break;
    case 15:
        fprintf(yyout, "pc");
        break;
    default:
        fprintf(yyout, "r%d", reg_no);
        break;
    }
}

void MachineOperand::output() 
{
    /* HINT：print operand
    * Example:
    * immediate num 1 -> print #1;
    * register 1 -> print r1;
    * lable addr_a -> print addr_a; */
    switch (this->type)
    {
    case IMM:
        fprintf(yyout, "#%d", this->val);
        break;
    case VREG:
        fprintf(yyout, "v%d", this->reg_no);
        break;
    case REG:
        PrintReg();
        break;
    case LABEL:
        if (this->label.substr(0, 2) == ".L" || isfunc) // 标签或函数
            fprintf(yyout, "%s", this->label.c_str());
        else {// 变量
            char* var_name = (char*)this->label.c_str();
            var_name = AsmBuilder::erase_at_from_str(var_name);
            fprintf(yyout, "addr_%s", var_name);
        }
    default:
        break;
    }
}


void MachineInstruction::PrintCond()
{
    switch (cond)
    {
    case EQ:
        fprintf(yyout, "eq");
        break;
    case NE:
        fprintf(yyout, "ne");
        break;
    case LT:
        fprintf(yyout, "lt");
        break;
    case LE:
        fprintf(yyout, "le");
        break;
    case GT:
        fprintf(yyout, "gt");
        break;
    case GE:
        fprintf(yyout, "ge");
        break;
    default:
        break;
    }
}

void MachineInstruction::insertBefore(MachineInstruction* inst) {
    auto& instructions = parent->getInsts();
    auto it = std::find(instructions.begin(), instructions.end(), this);
    instructions.insert(it, inst);
}

void MachineInstruction::insertAfter(MachineInstruction* inst) {
    auto& instructions = parent->getInsts();
    auto it = std::find(instructions.begin(), instructions.end(), this);
    instructions.insert(++it, inst);
}


BinaryMInstruction::BinaryMInstruction(
    MachineBlock* p, int op, 
    MachineOperand* dst, MachineOperand* src1, MachineOperand* src2, 
    int cond)
{
    this->parent = p;
    this->type = MachineInstruction::BINARY;
    this->op = op;
    this->cond = cond;
    this->def_list.push_back(dst);
    this->use_list.push_back(src1);
    this->use_list.push_back(src2);
    dst->setParent(this);
    src1->setParent(this);
    src2->setParent(this);
}

void BinaryMInstruction::output() 
{
    switch (this->op)
    {
    case BinaryMInstruction::ADD:
        fprintf(yyout, "\tadd ");
        break;
    case BinaryMInstruction::SUB:
        fprintf(yyout, "\tsub ");
        break;
    case BinaryMInstruction::MUL:
        fprintf(yyout, "\tmul ");
        break;
    case BinaryMInstruction::DIV:
        fprintf(yyout, "\tsdiv ");
        break;
    default:
        break;
    }
    this->PrintCond();
    this->def_list[0]->output();
    fprintf(yyout, ", ");
    this->use_list[0]->output();
    fprintf(yyout, ", ");
    this->use_list[1]->output();
    fprintf(yyout, "\n");
}

LoadMInstruction::LoadMInstruction(MachineBlock* p,
    MachineOperand* dst, MachineOperand* src1, MachineOperand* src2,
    int cond)
{
    this->parent = p;
    this->type = MachineInstruction::LOAD;
    this->op = -1;
    this->cond = cond;
    this->def_list.push_back(dst);
    this->use_list.push_back(src1);
    if (src2)
        this->use_list.push_back(src2);
    dst->setParent(this);
    src1->setParent(this);
    if (src2)
        src2->setParent(this);
}

void LoadMInstruction::output()
{
    fprintf(yyout, "\tldr ");
    this->def_list[0]->output();
    fprintf(yyout, ", ");

    // Load immediate num, eg: ldr r1, =8
    if(this->use_list[0]->isImm())
    {
        fprintf(yyout, "=%d\n", this->use_list[0]->getVal());
        return;
    }

    // Load address
    if(this->use_list[0]->isReg()||this->use_list[0]->isVReg())
        fprintf(yyout, "[");

    this->use_list[0]->output();
    if( this->use_list.size() > 1 )
    {
        fprintf(yyout, ", ");
        this->use_list[1]->output();
    }

    if(this->use_list[0]->isReg()||this->use_list[0]->isVReg())
        fprintf(yyout, "]");
    fprintf(yyout, "\n");
}

StoreMInstruction::StoreMInstruction(MachineBlock* p,
    MachineOperand* src, MachineOperand* dst, MachineOperand* off, 
    int cond)
{
    this->parent = p;
    this->type = MachineInstruction::STORE;
    this->cond = cond;
    this->use_list.push_back(src);
    this->use_list.push_back(dst);
    src->setParent(this);
    dst->setParent(this);
    if(off){
        this->use_list.push_back(off);
        off->setParent(this);
    }
}

void StoreMInstruction::output()
{
    fprintf(yyout, "\tstr ");
    this->use_list[0]->output();
    fprintf(yyout, ", ");
    // Store address
    if (this->use_list[1]->isReg() || this->use_list[1]->isVReg())
        fprintf(yyout, "[");
    this->use_list[1]->output();
    if (this->use_list.size() > 2)
    {
        fprintf(yyout, ", ");
        this->use_list[2]->output();
    }
    if (this->use_list[1]->isReg() || this->use_list[1]->isVReg())
        fprintf(yyout, "]");
    fprintf(yyout, "\n");
}

MovMInstruction::MovMInstruction(MachineBlock* p, int op, 
    MachineOperand* dst, MachineOperand* src,
    int cond)
{
    this->parent = p;
    this->type = MachineInstruction::MOV;
    this->op = op;
    this->cond = cond;
    this->def_list.push_back(dst);
    this->use_list.push_back(src);
    dst->setParent(this);
    src->setParent(this);
}

void MovMInstruction::output() 
{
    fprintf(yyout, "\tmov");
    PrintCond();
    fprintf(yyout, " ");
    this->def_list[0]->output();
    fprintf(yyout, ", ");
    this->use_list[0]->output();
    fprintf(yyout, "\n");
}

BranchMInstruction::BranchMInstruction(MachineBlock* p, int op, 
    MachineOperand* dst, 
    int cond)
{
    this->parent = p;
    this->type = MachineInstruction::BRANCH;
    this->op = op;
    this->cond = cond;
    this->use_list.push_back(dst);
    dst->setParent(this);
}

void BranchMInstruction::output()
{
    switch (op)
    {
    case B:
        fprintf(yyout, "\tb");
        break;
    case BL:
        fprintf(yyout, "\tbl");
        break;
    case BX:
        fprintf(yyout, "\tbx");
        break;
    default:
        break;
    }
    PrintCond();
    fprintf(yyout, " ");
    use_list[0]->output();
    fprintf(yyout, "\n");
}

CmpMInstruction::CmpMInstruction(MachineBlock* p, 
    MachineOperand* src1, MachineOperand* src2, 
    int cond)
{
    this->parent = p;
    this->type = MachineInstruction::CMP;
    this->cond = cond;
    p->setCmpCond(cond);
    this->use_list.push_back(src1);
    this->use_list.push_back(src2);
    src1->setParent(this);
    src2->setParent(this);
}

void CmpMInstruction::output()
{
    // Jsut for reg alloca test
    // delete it after test
    fprintf(yyout, "\tcmp ");
    this->use_list[0]->output();
    fprintf(yyout, ", ");
    this->use_list[1]->output();
    fprintf(yyout, "\n");
}

StackMInstrcuton::StackMInstrcuton(MachineBlock* p, int op, 
    std::vector<MachineOperand*> srcs,
    int cond)
{
    this->parent = p;
    this->type = MachineInstruction::STACK;
    this->op = op;
    this->cond = cond;
    for (auto operand : srcs)
    {
        this->use_list.push_back(operand);
        operand->setParent(this);
    }
}

StackMInstrcuton::StackMInstrcuton(MachineBlock *p, int op,
    std::vector<MachineOperand *> srcs,
    MachineOperand *src,
    MachineOperand *src1,
    int cond)
{
    this->parent = p;
    this->type = MachineInstruction::STACK;
    this->op = op;
    this->cond = cond;
    if (srcs.size())
        for (auto it = srcs.begin(); it != srcs.end(); it++)
            this->use_list.push_back(*it);
    this->use_list.push_back(src);
    src->setParent(this);
    if (src1)
    {
        this->use_list.push_back(src1);
        src1->setParent(this);
    }
}

void StackMInstrcuton::output()
{
    switch (op)
    {
    case POP:
        fprintf(yyout, "\tpop ");
        break;
    case PUSH:
        fprintf(yyout, "\tpush ");
        break;
    default:
        break;
    }
    fprintf(yyout, "{");
    for (long unsigned int i = 0; i < use_list.size(); i++)
    {
        if (i != 0)
        {
            fprintf(yyout, ", ");
        }
        use_list[i]->output();
    }
    fprintf(yyout, "}\n");
}

GlobalMInstruction::GlobalMInstruction(MachineBlock *p, MachineOperand *dst, std::vector<MachineOperand *> src, SymbolEntry *se)
{
    this->parent = p;
    this->se = se;
    this->def_list.push_back(dst);
    dst->setParent(this);
    for (unsigned int i = 0; i < src.size(); i++)
    {
        this->use_list.push_back(src[i]);
        src[i]->setParent(this);
    }
};

void GlobalMInstruction::output_decl()
{
    char* global_name = (char*)def_list[0]->getLabel().c_str();
    global_name = AsmBuilder::erase_at_from_str(global_name);
    fprintf(yyout, ".global %s\n", global_name);
    //fprintf(yyout, ".align 4\n");
    fprintf(yyout, ".size %s, %d\n", global_name, (int)(4 * use_list.size()));
    fprintf(yyout, "%s:\n", global_name);
    if(use_list.empty())
        fprintf(yyout, "\t.word 0\n");
    else{
    for (unsigned int i = 0; i < use_list.size(); i++)
        fprintf(yyout, "\t.word %d\n", use_list[i]->getVal());
    }
};

void GlobalMInstruction::output()
{
    char* global_name = (char*)def_list[0]->getLabel().c_str();
    global_name = AsmBuilder::erase_at_from_str(global_name);
    fprintf(yyout, "addr_%s:\n", global_name);
    fprintf(yyout, "\t.word %s\n", global_name);
};

MachineFunction::MachineFunction(MachineUnit* p, SymbolEntry* sym_ptr) 
{ 
    this->parent = p; 
    this->sym_ptr = sym_ptr; 
    this->stack_size = 0;
    //addSavedRegs(11); // fp
    //addSavedRegs(14); // lr
};

void MachineBlock::output()
{
    fprintf(yyout, ".L%d:\n", this->no);
    //fprintf(stderr, "MachineBlock::output, .L%d:\n", this->no);
    for (auto iter : inst_list)
    {
        if (iter->isBX())
        {
            auto fp = new MachineOperand(MachineOperand::REG, 11);
            auto lr = new MachineOperand(MachineOperand::REG, 14);
            auto cur_inst = new StackMInstrcuton(this, StackMInstrcuton::POP, parent->getSavedRegs(), fp, lr);
            cur_inst->output();
        }
        iter->output();
    }
}

std::vector<MachineOperand *> MachineFunction::getSavedRegs()
{
    std::vector<MachineOperand *> saved_regs;
    for (auto reg_no : this->saved_regs) {
        saved_regs.push_back(new MachineOperand(MachineOperand::REG, reg_no));
    }
    return saved_regs;
}

void MachineFunction::output()
{
    const char *func_name = this->sym_ptr->toStr().c_str() + 1;
    fprintf(yyout, "\t.global %s\n", func_name);
    fprintf(yyout, "\t.type %s , %%function\n", func_name);
    fprintf(yyout, "%s:\n", func_name);
    /* Hint:
    *  1. Save fp
    *  2. fp = sp
    *  3. Save callee saved register
    *  4. Allocate stack space for local variable */
    
    // Traverse all the block in block_list to print assembly code.
    MachineBlock* entry = this->block_list[0];
    auto fp = new MachineOperand(MachineOperand::REG, 11);
    auto sp = new MachineOperand(MachineOperand::REG, 13);
    auto lr = new MachineOperand(MachineOperand::REG, 14);
    (new StackMInstrcuton(nullptr, StackMInstrcuton::PUSH, getSavedRegs(), fp, lr))->output();

    (new MovMInstruction(nullptr, MovMInstruction::MOV, fp, sp))->output();
    int off = AllocSpace(0);
    // 用 SUB 指令为局部变量生成栈内空间（实际栈内空间大小已知）
    // SUB 只能操作 8 位立即数，需要分段处理
    auto size = new MachineOperand(MachineOperand::IMM, off);
    if (off < -255 || off > 255)
    {
        auto r4 = new MachineOperand(MachineOperand::REG, 4);
        // 先把低 16 位放到寄存器里
        (new MovMInstruction(nullptr, MovMInstruction::MOV, r4, new MachineOperand(MachineOperand::IMM, off & 0xffff)))->output();
        // 再把高 16 位的两个字节加到寄存器里
        if (off & 0xffff00)
            (new BinaryMInstruction(nullptr, BinaryMInstruction::ADD, r4, r4, new MachineOperand(MachineOperand::IMM, off & 0xff0000)))->output();
        if (off & 0xff000000)
            (new BinaryMInstruction(nullptr, BinaryMInstruction::ADD, r4, r4, new MachineOperand(MachineOperand::IMM, off & 0xff000000)))->output();
        (new BinaryMInstruction(nullptr, BinaryMInstruction::SUB, sp, sp, r4))->output();
    }
    else
    {
        (new BinaryMInstruction(nullptr, BinaryMInstruction::SUB, sp, sp, size))->output();
    }
    for (auto iter : block_list)
    {
        iter->output();
    }
    fprintf(yyout, "\n");
}

void MachineUnit::PrintGlobalDecl()
{
    // You need to print global variable/const declarition code;
    for (auto global : global_list)
        global->output_decl();
}

void MachineUnit::PrintGlobalBridge()
{
    for (auto global : global_list)
        global->output();
}

void MachineUnit::output()
{
    /* Hint:
    * 1. You need to print global variable/const declarition code;
    * 2. Traverse all the function in func_list to print assembly code;
    * 3. Don't forget print bridge label at the end of assembly code!! */
    fprintf(yyout, "\t.arch armv8-a\n");
    fprintf(yyout, "\t.arch_extension crc\n");
    fprintf(yyout, "\t.arm\n");
    fprintf(yyout, "\t.data\n");
    PrintGlobalDecl();
    fprintf(yyout, "\n\t.text\n");
    for(auto iter : func_list)
        iter->output();
    PrintGlobalBridge();
}
