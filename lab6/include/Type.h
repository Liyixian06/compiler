#ifndef __TYPE_H__
#define __TYPE_H__
#include <vector>
#include <string>
#include "Operand.h"

class Type
{
private:
    int kind;
protected:
    enum {INT, VOID, FUNC, PTR, CONST};
public:
    Type(int kind) : kind(kind) {};
    virtual ~Type() {};
    virtual std::string toStr() = 0;
    bool isInt() const {return kind == INT;};
    bool isVoid() const {return kind == VOID;};
    bool isFunc() const {return kind == FUNC;};
    bool isConst() const {return kind == CONST;};
};

class IntType : public Type
{
private:
    int size;
public:
    IntType(int size) : Type(Type::INT), size(size){};
    std::string toStr();
};

class VoidType : public Type
{
public:
    VoidType() : Type(Type::VOID){};
    std::string toStr();
};

class ConstType : public Type
{
private:
    int size;
public:
    ConstType(int size) : Type(Type::CONST), size(size){};
    std::string toStr();
};

class FunctionType : public Type
{
private:
    Type *returnType;
    std::vector<Type*> paramsType;
public:
    FunctionType(Type* returnType, std::vector<Type*> paramsType) : 
    Type(Type::FUNC), returnType(returnType), paramsType(paramsType){};
    Type* getRetType() {return returnType;};
    int getnum() {return paramsType.size();}
    std::vector<Type*> get_params() {return paramsType;}
    std::string toStr();
};

class PointerType : public Type
{
private:
    Type *valueType;
public:
    PointerType(Type* valueType) : Type(Type::PTR) {this->valueType = valueType;};
    std::string toStr();
};

class TypeSystem
{
private:
    static IntType commonInt;
    static IntType commonBool;
    static VoidType commonVoid;
    static ConstType commonConst;
public:
    static Type *intType;
    static Type *voidType;
    static Type *boolType;
    static Type *constType;
};

class FuncParaNum // 参数个数
{
private:
    int num;
public:
    FuncParaNum(){num = 0;}
    void plus(){num++;}
    void reset(){num = 0;}
    int ret_num(){return num;}  // 获取当前参数个数
};
static FuncParaNum funcdefpara, funccallpara;

class FuncParaType // 参数类型
{
private:
    std::vector<Type*> paramsType;
public:
    FuncParaType(){paramsType = {};}
    void push(Type* p) {paramsType.push_back(p);}  // 将参数类型加入参数类型列表
    std::vector<Type*> get() {return paramsType;}
    void reset() {paramsType.clear();}
};
static FuncParaType defpara;
static FuncParaType callpara;

class FuncCallParaType // 实参
{
private:
    std::vector<Operand*> paralist;
public:
    FuncCallParaType(){paralist={};}
    void push(Operand* p) {paralist.push_back(p);}
    std::vector<Operand*> get() {return paralist;}
    void reset() {paralist.clear();}
};
static FuncCallParaType callparamstype;

#endif
