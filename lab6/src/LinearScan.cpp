#include <algorithm>
#include "LinearScan.h"
#include "MachineCode.h"
#include "LiveVariableAnalysis.h"

LinearScan::LinearScan(MachineUnit *unit)
{
    this->unit = unit;
    for (int i = 4; i < 11; i++)
        regs.push_back(i);
}

void LinearScan::allocateRegisters()
{
    for (auto &f : unit->getFuncs())
    {
        func = f;
        bool success;
        success = false;
        while (!success)        // repeat until all vregs can be mapped
        {
            computeLiveIntervals();
            success = linearScanRegisterAllocation();
            if (success)        // all vregs can be mapped to real regs
                modifyCode();
            else                // spill vregs that can't be mapped to real regs
                genSpillCode();
        }
    }
}

void LinearScan::makeDuChains() // 构建Def-Use链
{
    LiveVariableAnalysis lva;
    lva.pass(func);
    du_chains.clear();
    int i = 0;
    std::map<MachineOperand, std::set<MachineOperand *>> liveVar;
    for (auto &bb : func->getBlocks())
    {
        liveVar.clear();
        for (auto &t : bb->getLiveOut())
            liveVar[*t].insert(t);
        int no;
        no = i = bb->getInsts().size() + i;
        for (auto inst = bb->getInsts().rbegin(); inst != bb->getInsts().rend(); inst++)
        {
            (*inst)->setNo(no--);  // 逆序遍历基本块指令
            for (auto &def : (*inst)->getDef())
            {
                if (def->isVReg())
                {
                    auto &uses = liveVar[*def]; // 获取当前定义对应的活跃变量集合
                    du_chains[def].insert(uses.begin(), uses.end());
                    auto &kill = lva.getAllUses()[*def];  // 获取当前定义对应的被杀死的变量集合
                    std::set<MachineOperand *> res; 
                    set_difference(uses.begin(), uses.end(), kill.begin(), kill.end(), inserter(res, res.end()));  // 计算差集，得到新的活跃变量集合
                    liveVar[*def] = res;  // 更新liveVar
                }
            }
            for (auto &use : (*inst)->getUse())
            {
                if (use->isVReg())
                    liveVar[*use].insert(use);  // 将使用的变量加入liveVar中
            }
        }
    }
}

void LinearScan::computeLiveIntervals() {
    makeDuChains();
    intervals.clear();

    // Step 1: 遍历Def-Use链，为每个虚拟寄存器创建Interval对象
    for (const auto& du_chain : du_chains) {
        int maxUseNo = -1;

        // 找到使用点的最大序号
        for (const auto& use : du_chain.second)
            maxUseNo = std::max(maxUseNo, use->getParent()->getNo());

        // 创建 Interval 对象
        Interval* interval = new Interval{
            du_chain.first->getParent()->getNo(),  // start
            maxUseNo,                               // end
            false,                                  // spill
            0,                                      // disp
            0,                                      // rreg
            {du_chain.first},                       // defs
            du_chain.second                         // uses
        };

        intervals.push_back(interval);
    }

    // Step 2: 处理每个 Interval 对象的使用点
    for (auto& interval : intervals) {
        auto uses = interval->uses;
        auto& begin = interval->start;
        auto& end = interval->end;

        // 遍历基本块
        for (const auto& block : func->getBlocks()) {
            auto liveIn = block->getLiveIn();
            auto liveOut = block->getLiveOut();
            bool in = false;
            bool out = false;

            // 判断是否在入口和出口活跃
            for (const auto& use : uses)
                if (liveIn.count(use)) {
                    in = true;
                    break;
                }

            for (const auto& use : uses)
                if (liveOut.count(use)) {
                    out = true;
                    break;
                }

            // 更新 begin 和 end
            if (in && out) {
                begin = std::min(begin, (*(block->begin()))->getNo());
                end = std::max(end, (*(block->rbegin()))->getNo());
            } else if (!in && out) {
                for (const auto& inst : block->getInsts())
                    if (inst->getDef().size() > 0 &&
                        inst->getDef()[0] == *(uses.begin())) {
                        begin = std::min(begin, inst->getNo());
                        break;
                    }
                end = std::max(end, (*(block->rbegin()))->getNo());
            } else if (in && !out) {
                begin = std::min(begin, (*(block->begin()))->getNo());
                int temp = 0;

                for (const auto& use : uses)
                    if (use->getParent()->getParent() == block)
                        temp = std::max(temp, use->getParent()->getNo());

                end = std::max(temp, end);
            }
        }
    }

    // Step 3: 合并相交的活跃区间
    bool change = true;
    while (change) {
        change = false;
        std::vector<Interval*> temp(intervals.begin(), intervals.end());

        for (size_t i = 0; i < temp.size(); i++)
            for (size_t j = i + 1; j < temp.size(); j++) {
                Interval* w1 = temp[i];
                Interval* w2 = temp[j];

                if (**w1->defs.begin() == **w2->defs.begin()) {
                    std::set<MachineOperand*> commonUses;
                    set_intersection(w1->uses.begin(), w1->uses.end(),
                                     w2->uses.begin(), w2->uses.end(),
                                     inserter(commonUses, commonUses.end()));

                    if (!commonUses.empty()) {
                        change = true;
                        w1->defs.insert(w2->defs.begin(), w2->defs.end());
                        w1->uses.insert(w2->uses.begin(), w2->uses.end());

                        auto w1Min = std::min(w1->start, w1->end);
                        auto w1Max = std::max(w1->start, w1->end);
                        auto w2Min = std::min(w2->start, w2->end);
                        auto w2Max = std::max(w2->start, w2->end);

                        w1->start = std::min(w1Min, w2Min);
                        w1->end = std::max(w1Max, w2Max);

                        auto it = std::find(intervals.begin(), intervals.end(), w2);
                        if (it != intervals.end())
                            intervals.erase(it);
                    }
                }
            }
    }

    // Step 4: 按照起始位置排序
    sort(intervals.begin(), intervals.end(), compareStart);
}

bool LinearScan::linearScanRegisterAllocation()
{
    // _Todo
    /*
        active ←{}
        foreach live interval i, in order of increasing start point
            ExpireOldIntervals(i)
            if length(active) = R then
                SpillAtInterval(i)
            else
                register[i] ← a register removed from pool of free registers
                add i to active, sorted by increasing end point
    */
   bool success = true;
    active.clear();
    regs.clear();
    for (int i = 4; i < 11; i++)
        regs.push_back(i);

    for (auto& i : intervals) {
        expireOldIntervals(i);
        if (regs.empty()) {
            spillAtInterval(i);
            success = false;
        } else {
            i->rreg = regs.front();
            regs.erase(regs.begin());
            active.push_back(i);
            sort(active.begin(), active.end(), compareEnd);
        }
    }
    return success;
}

void LinearScan::modifyCode()
{
    for (auto &interval : intervals)
    {
        func->addSavedRegs(interval->rreg);
        for (auto def : interval->defs)
            def->setReg(interval->rreg);
        for (auto use : interval->uses)
            use->setReg(interval->rreg);
    }
}

// 补充store和load命令，溢出代码生成
void LinearScan::genSpillCode()
{
    for(auto &interval:intervals)
    {
        if(!interval->spill)
            continue;
        // _TODO
        /* HINT:
         * The vreg should be spilled to memory.
         * 1. insert ldr inst before the use of vreg
         * 2. insert str inst after the def of vreg
         */ 

        // 为间隔分配一个在堆栈上的新位置，负号以FP寄存器为基准
        interval->disp = -func->AllocSpace(4);
        // 获取偏移和FP寄存器的值
        auto off = new MachineOperand(MachineOperand::IMM, interval->disp);
        auto fp = new MachineOperand(MachineOperand::REG, 11);

        // 遍历use，处理加入load指令
        for (auto use : interval->uses) {
            auto temp = new MachineOperand(*use);
            MachineOperand* operand = nullptr;

            // 如果偏移大于255或小于-255，则创建一个新的虚拟寄存器
            if (interval->disp > 255 || interval->disp < -255) {
                operand = new MachineOperand(MachineOperand::VREG, SymbolTable::getLabel());
                auto inst1 = new LoadMInstruction(use->getParent()->getParent(), operand, off);
                use->getParent()->insertBefore(inst1);
            }

            // 插入加载指令（ldr）
            if (operand) {
                auto inst = new LoadMInstruction(use->getParent()->getParent(), temp, fp, new MachineOperand(*operand));
                use->getParent()->insertBefore(inst);
            } 
            else {
                auto inst = new LoadMInstruction(use->getParent()->getParent(), temp, fp, off);
                use->getParent()->insertBefore(inst);
            }
        }

        // 处理定义该间隔的每个指令
        for (auto def : interval->defs) {
            auto temp = new MachineOperand(*def);
            MachineOperand* operand = nullptr;
            MachineInstruction *inst1 = nullptr, *inst = nullptr;

            // 如果偏移大于255或小于-255，则创建一个新的虚拟寄存器
            if (interval->disp > 255 || interval->disp < -255) {
                operand = new MachineOperand(MachineOperand::VREG, SymbolTable::getLabel());
                inst1 = new LoadMInstruction(def->getParent()->getParent(), operand, off);
                def->getParent()->insertAfter(inst1);
            }

            // 插入存储指令（str）
            if (operand) {
                auto inst = new StoreMInstruction(def->getParent()->getParent(), temp, fp, new MachineOperand(*operand));
            } 
            else {
                auto inst = new StoreMInstruction(def->getParent()->getParent(), temp, fp, off);
            }

            // 将存储指令插入到定义指令的后面
            if (inst1)
                inst1->insertAfter(inst);
            else
                def->getParent()->insertAfter(inst);
        }
    }
}

void LinearScan::expireOldIntervals(Interval *interval)
{
    // _Todo
    /*
        foreach interval j in active, in order of increasing end point
            if endpoint[j] ≥ startpoint[i] then
                return
            remove j from active
            add register[j] to pool of free registers
    */
    auto it = active.begin();
    //查看active中是否有结束时间早于interval起始时间
    //active按照end时间升序排列，所以只用看头部
    //头部如果大于 那么直接返回
    //头部小于 那么active的寄存器可以回收
    while (it != active.end()) {
        if ((*it)->end >= interval->start)
            return;
        regs.push_back((*it)->rreg);
        it = active.erase(find(active.begin(), active.end(), *it));
        sort(regs.begin(), regs.end());
    }
}

void LinearScan::spillAtInterval(Interval *interval)
{
    // _Todo
    /*
        spill ← last interval in active
        if endpoint[spill] > endpoint[i] then
            register[i] ← register[spill]
            location[spill] ← new stack location
            remove spill from active
            add i to active, sorted by increasing end point
        else
            location[i] ← new stack location

    */

   auto spill = active.back();  // 都被占用，选择active列表末尾与当前unhandled的一个溢出到栈中
    if (spill->end > interval->end) { // 将结束时间更晚的溢出
        spill->spill = true;  // 置位
        interval->rreg = spill->rreg;  // 重新分配
        active.push_back(interval);  // 再按照 unhandled interval活跃区间结束位置，将其插入到 active 列表中
        sort(active.begin(), active.end(), compareEnd);  // 插入后再次按照结束时间对活跃区间进行排序
    } 
    else {
        // unhandle溢出更晚只需置位spill标志位
        interval->spill = true;
    }
}

bool LinearScan::compareStart(Interval *a, Interval *b)
{
    return a->start < b->start;
}


bool LinearScan::compareEnd(Interval* a, Interval* b) {
    return a->end < b->end;
}

