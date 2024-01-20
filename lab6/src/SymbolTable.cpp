#include "SymbolTable.h"
#include "Type.h"
#include <iostream>
#include <sstream>
extern FILE* yyout;

SymbolEntry::SymbolEntry(Type *type, int kind) 
{
    this->type = type;
    this->kind = kind;
}

ConstantSymbolEntry::ConstantSymbolEntry(Type *type, int value) : SymbolEntry(type, SymbolEntry::CONSTANT)
{
    this->value = value;
}

std::string ConstantSymbolEntry::toStr()
{
    std::ostringstream buffer;
    buffer << value;
    return buffer.str();
}

IdentifierSymbolEntry::IdentifierSymbolEntry(Type *type, std::string name, int scope) : SymbolEntry(type, SymbolEntry::VARIABLE), name(name)
{
    this->scope = scope;
    addr = nullptr;
}

std::string IdentifierSymbolEntry::toStr()
{
    return "@" + name;
}

void IdentifierSymbolEntry::outputsysfunc()
{
    /*
    fprintf(yyout, "declare %s @%s(", 
        dynamic_cast<FunctionType*>(type)->getRetType()->toStr().c_str(), (const char*)name.c_str());
    bool first = true;
    for(auto type : dynamic_cast<FunctionType*>(type)->getParamsType()){
        if(!type->isVoid()){
            if(!first){
                first = false;
                fprintf(yyout, ", ");
            }
            fprintf(yyout,"%s", type->toStr().c_str());
        }
    }
    fprintf(yyout, ")\n");
    */
}

TemporarySymbolEntry::TemporarySymbolEntry(Type *type, int label) : SymbolEntry(type, SymbolEntry::TEMPORARY)
{
    this->label = label;
}

std::string TemporarySymbolEntry::toStr()
{
    std::ostringstream buffer;
    buffer << "%t" << label;
    return buffer.str();
}

SymbolTable::SymbolTable()
{
    prev = nullptr;
    level = 0;
}

SymbolTable::SymbolTable(SymbolTable *prev)
{
    this->prev = prev;
    this->level = prev->level + 1;
}

/*
    Description: lookup the symbol entry of an identifier in the symbol table
    Parameters: 
        name: identifier name
    Return: pointer to the symbol entry of the identifier

    hint:
    1. The symbol table is a stack. The top of the stack contains symbol entries in the current scope.
    2. Search the entry in the current symbol table at first.
    3. If it's not in the current table, search it in previous ones(along the 'prev' link).
    4. If you find the entry, return it.
    5. If you can't find it in all symbol tables, return nullptr.
*/

// 在当前符号表及其前面的符号表中查找
// 通过迭代遍历每个符号表，直到找到符号表项或者到达全局符号表（level == 0）为止。
SymbolEntry* SymbolTable::lookup(std::string name)
{
    SymbolTable* p = this;
    std::map<std::string, SymbolEntry*>::iterator it = p->symbolTable.find(name);
    while(it == p->symbolTable.end() && p->level!=0){
        p = p->prev;
        it = p->symbolTable.find(name);
    }
    // 如果找到符号表项，则返回该符号表项；否则返回nullptr。
    if(it != p->symbolTable.end()) return it->second;
    else return nullptr;
}

// 只在当前符号表中查找符号表项
// 使用 count 函数来检查当前符号表是否包含给定名称的符号表项。
// 如果包含，返回该符号表项；否则返回nullptr。
SymbolEntry* SymbolTable::lookup_inthis(std::string name)
{
    SymbolTable* p = this;
    if(p->symbolTable.count(name)!=0)
        return p->symbolTable[name];
    return nullptr;
}

// 查找最近函数的符号表项
SymbolEntry* SymbolTable::search_func() 
{
    SymbolTable* p = this;  // 从当前符号表开始搜索
    std::map<std::string, SymbolEntry*>::iterator it;
    // 循环遍历当前符号表以及其前面的符号表
    while(p->prev){
        it = p->symbolTable.begin();
        while(it!=p->symbolTable.end()){
            SymbolEntry* se = it->second;
            // 如果符号表项的类型为函数类型，则返回该符号表项
            if(se->getType()->isFunc()==1){
                return se;
            }
            it++;
        }
        p = p->getPrev();  // 移动到前一个符号表
    }
    // 如果前面的符号表没有包含函数符号表项，再次遍历当前符号表
    it = p->symbolTable.begin();
    while(it!=p->symbolTable.end()){
        SymbolEntry* se = it->second;
        // 如果符号表项的类型为函数类型，则返回该符号表项
        if(se->getType()->isFunc()==1){
            return se;
        }
        it++;
    }
    // 如果都没有找到函数符号表项，则返回nullptr
    return nullptr;
}

// install the entry into current symbol table.
void SymbolTable::install(std::string name, SymbolEntry* entry)
{
    symbolTable[name] = entry;
}

int SymbolTable::counter = 0;
static SymbolTable t;
SymbolTable *identifiers = &t;
SymbolTable *globals = &t;
