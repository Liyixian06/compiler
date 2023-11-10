float  
```
FLO [0-9]*\.[0-9]+([Ee][+-]?[0-9]+)?  
FLOAT "float"  
"float" {
    if(dump_type == TOKENS)
        print_str("FLOAT\tfloat");
    columns += strlen(yytext);
    return FLOAT;
}
{FLO} {
    float num;
    sscanf(yytext, "%f", &num);
    if(dump_type == TOKENS)
        print_num(string("FLOAT_CONST\t") + to_string(num), string(yytext));
    words++;
    chars += yyleng;
    columns += strlen(yytext);
    return FLO;
}
```