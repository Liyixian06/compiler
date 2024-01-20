#include <iostream>
#include <string.h>
#include <unistd.h>
#include "common.h"
#include "Type.h"
#include "Ast.h"
#include "Unit.h"
#include "MachineCode.h"
#include "LinearScan.h"

extern FILE *yyin;
extern FILE *yyout;
int yyparse();

Ast ast;
Unit unit;
MachineUnit mUnit;
char outfile[256] = "a.out";
dump_type_t dump_type = ASM;

int main(int argc, char *argv[])
{
    int opt;
    while ((opt = getopt(argc, argv, "Siato:")) != -1)
    {
        switch (opt)
        {
        case 'o':
            strcpy(outfile, optarg);
            break;
        case 'a':
            dump_type = AST;
            break;
        case 't':
            dump_type = TOKENS;
            break;
        case 'i':
            dump_type = IR;
            break;
        case 'S':
            dump_type = ASM;
            break;
        default:
            fprintf(stderr, "Usage: %s [-o outfile] infile\n", argv[0]);
            exit(EXIT_FAILURE);
            break;
        }
    }
    if (optind >= argc)
    {
        fprintf(stderr, "no input file\n");
        exit(EXIT_FAILURE);
    }
    if (!(yyin = fopen(argv[optind], "r")))
    {
        fprintf(stderr, "%s: No such file or directory\nno input file\n", argv[optind]);
        exit(EXIT_FAILURE);
    }
    if (!(yyout = fopen(outfile, "w")))
    {
        fprintf(stderr, "%s: fail to open output file\n", outfile);
        exit(EXIT_FAILURE);
    }

    /*添加运行时库************************************************************************************************/
    // getint
    Type *funcType;
    funcType = new FunctionType(TypeSystem::intType, {});
    SymbolEntry *se = new IdentifierSymbolEntry(funcType, "getint", identifiers->getLevel());
    identifiers->install("getint", se);
    unit.push_sys_func((IdentifierSymbolEntry*)se);

    // getch
    funcType = new FunctionType(TypeSystem::intType, {});
    se = new IdentifierSymbolEntry(funcType, "getch", identifiers->getLevel());
    identifiers->install("getch", se);
    unit.push_sys_func((IdentifierSymbolEntry*)se);

    // getarray
    funcType = new FunctionType(TypeSystem::intType, {});
    se = new IdentifierSymbolEntry(funcType, "getarray", identifiers->getLevel());
    identifiers->install("getarray", se);
    unit.push_sys_func((IdentifierSymbolEntry*)se);

    // putint
    funcType = new FunctionType(TypeSystem::voidType, {TypeSystem::intType});
    se = new IdentifierSymbolEntry(funcType, "putint", identifiers->getLevel());
    identifiers->install("putint", se);
    unit.push_sys_func((IdentifierSymbolEntry*)se);

    // putch
    funcType = new FunctionType(TypeSystem::voidType, {TypeSystem::intType});
    se = new IdentifierSymbolEntry(funcType, "putch", identifiers->getLevel());
    identifiers->install("putch", se);
    unit.push_sys_func((IdentifierSymbolEntry*)se);

    // putarray
    funcType = new FunctionType(TypeSystem::voidType, {});
    se = new IdentifierSymbolEntry(funcType, "putarray", identifiers->getLevel());
    identifiers->install("putarray", se);
    unit.push_sys_func((IdentifierSymbolEntry*)se);

    // putf
    funcType = new FunctionType(TypeSystem::voidType, {});
    se = new IdentifierSymbolEntry(funcType, "putf", identifiers->getLevel());
    identifiers->install("putf", se);
    unit.push_sys_func((IdentifierSymbolEntry*)se);

    // starttime
    funcType = new FunctionType(TypeSystem::voidType, {});
    se = new IdentifierSymbolEntry(funcType, "starttime", identifiers->getLevel());
    identifiers->install("starttime", se);
    unit.push_sys_func((IdentifierSymbolEntry*)se);

    // stoptime
    funcType = new FunctionType(TypeSystem::voidType, {});
    se = new IdentifierSymbolEntry(funcType, "stoptime", identifiers->getLevel());
    identifiers->install("stoptime", se);
    unit.push_sys_func((IdentifierSymbolEntry*)se);

    yyparse();
    if(dump_type == AST){
        ast.output();
        //fprintf(stderr, "ast output finished\n");
    }
    ast.typeCheck();
    //fprintf(stderr, "typecheck finished\n");
    ast.genCode(&unit);
    //fprintf(stderr, "LLVM IR finished\n");
    if(dump_type == IR){
        unit.output();
        //fprintf(stderr, "LLVM IR output finished\n");
    }    

    unit.genMachineCode(&mUnit);
    LinearScan linearScan(&mUnit);
    linearScan.allocateRegisters();
    if(dump_type == ASM)
        mUnit.output();
    return 0;
}
