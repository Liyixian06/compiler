#include <iostream>
#include <string.h>
#include <unistd.h>
#include "common.h"
#include "Ast.h"
#include "SymbolTable.h"
#include "Type.h"

extern FILE *yyin;
extern FILE *yyout;

int yyparse();

Ast ast;
char outfile[256] = "a.out";
dump_type_t dump_type = ASM;

int main(int argc, char *argv[])
{
    int opt;
    while ((opt = getopt(argc, argv, "ato:")) != -1)
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
    SymbolEntry *se1,*se2,*se3,*se4,*se5,*se6,*se7;
    se1 = new IdentifierSymbolEntry(TypeSystem::intType, "getint", identifiers->getLevel());
    identifiers->install("getint", se1);
    se2 = new IdentifierSymbolEntry(TypeSystem::intType, "getch", identifiers->getLevel());
    identifiers->install("getch", se2);
    se3 = new IdentifierSymbolEntry(TypeSystem::intType, "getarray", identifiers->getLevel());
    identifiers->install("getarray", se3);
    se4 = new IdentifierSymbolEntry(TypeSystem::voidType, "putint", identifiers->getLevel());
    identifiers->install("putint", se4);
    se5 = new IdentifierSymbolEntry(TypeSystem::voidType, "putch", identifiers->getLevel());
    identifiers->install("putch", se5);
    se6 = new IdentifierSymbolEntry(TypeSystem::voidType, "putarray", identifiers->getLevel());
    identifiers->install("putarray", se6);
    se7 = new IdentifierSymbolEntry(TypeSystem::voidType, "putf", identifiers->getLevel());
    identifiers->install("putf", se7);
    yyparse();
    if(dump_type == AST)
        ast.output();
    return 0;
}
