%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include"y.tab.h"
%}

ALPH  [a-zA-Z]
INT [0-9]
NUM {INT}+"."?{INT}*
ID  {ALPH}({ALPH}|{INT})*

%%
"main"  {return MN;}
"block" {return BLK;}
"void"  {strcpy(yylval.type,"void"); return DT;}
"int"   {strcpy(yylval.type,"int"); return DT;}
"float" {strcpy(yylval.type,"float"); return DT;}
"char"  {strcpy(yylval.type,"char"); return DT;}
"if"    {return IF;}
"else"  {return ELS;}
"print" {return PRT;}
"getInt" {return GIN;}
{ID}    {strcpy(yylval.lexeme,yytext) ;return ID;}
{NUM}   {strcpy(yylval.dval,yytext); return NUM;}
"?"     {return QM;}
"{"     {return OCB;}
"}"     {return CCB;}
"["     {return OSB;}
"]"     {return CSB;}
"("     {return OB;}
")"     {return CB;}
"="     {return ASG;}
","     {return COM;}
";"     {return SCL;}
":"     {return CL;}
"*"     {return STR;}
"+"     {return PLS;}
"-"     {return MIN;}
"/"     {return FSH;}
"\\"    {return BSH;}     
"%"     {return PCT;}
"||"    {return LOR;}
"&&"    {return LAND;}
"&"     {return BAND;}
"|"     {return BOR;}
"^"     {return BXOR;}
"=="    {return EQL;}
"!="    {return NEQL;}
">"     {return GT;}
"<"     {return LT;}
">="    {return GTE;}
"<="    {return LTE;}
" "
"\t"
"\n"
"$"		{ return 0; }
.  		{ return yytext[0]; }
%%