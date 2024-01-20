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

// �ڵ�ǰ���ű���ǰ��ķ��ű��в���
// ͨ����������ÿ�����ű�ֱ���ҵ����ű�����ߵ���ȫ�ַ��ű�level == 0��Ϊֹ��
SymbolEntry* SymbolTable::lookup(std::string name)
{
    SymbolTable* p = this;
    std::map<std::string, SymbolEntry*>::iterator it = p->symbolTable.find(name);
    while(it == p->symbolTable.end() && p->level!=0){
        p = p->prev;
        it = p->symbolTable.find(name);
    }
    // ����ҵ����ű���򷵻ظ÷��ű�����򷵻�nullptr��
    if(it != p->symbolTable.end()) return it->second;
    else return nullptr;
}

// ֻ�ڵ�ǰ���ű��в��ҷ��ű���
// ʹ�� count ��������鵱ǰ���ű��Ƿ�����������Ƶķ��ű��
// ������������ظ÷��ű�����򷵻�nullptr��
SymbolEntry* SymbolTable::lookup_inthis(std::string name)
{
    SymbolTable* p = this;
    if(p->symbolTable.count(name)!=0)
        return p->symbolTable[name];
    return nullptr;
}

// ������������ķ��ű���
SymbolEntry* SymbolTable::search_func() 
{
    SymbolTable* p = this;  // �ӵ�ǰ���ű�ʼ����
    std::map<std::string, SymbolEntry*>::iterator it;
    // ѭ��������ǰ���ű��Լ���ǰ��ķ��ű�
    while(p->prev){
        it = p->symbolTable.begin();
        while(it!=p->symbolTable.end()){
            SymbolEntry* se = it->second;
            // ������ű��������Ϊ�������ͣ��򷵻ظ÷��ű���
            if(se->getType()->isFunc()==1){
                return se;
            }
            it++;
        }
        p = p->getPrev();  // �ƶ���ǰһ�����ű�
    }
    // ���ǰ��ķ��ű�û�а����������ű���ٴα�����ǰ���ű�
    it = p->symbolTable.begin();
    while(it!=p->symbolTable.end()){
        SymbolEntry* se = it->second;
        // ������ű��������Ϊ�������ͣ��򷵻ظ÷��ű���
        if(se->getType()->isFunc()==1){
            return se;
        }
        it++;
    }
    // �����û���ҵ��������ű���򷵻�nullptr
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
