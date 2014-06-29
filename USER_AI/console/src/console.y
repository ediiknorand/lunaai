%{
#include <stdio.h>
#include <stdlib.h>
#include "instruction.h"

extern char *yytext;
int yylex();
void yyerror(char *str);
int mode = -1;

%}

%union {
  char* num;
  char *id;
  char *str;
}


%token T_COMMAND
%token T_END
%token T_CONCAT
%token T_DOT
%token T_AND
%token T_NOT
%token T_OR
%token T_DIV
%token T_PRINT
%token T_SET
%token <str> T_DEFINE
%token T_LOAD
%token T_UNLOAD
%token T_STRING
/*%token<num> T_NUMBER*/
%token T_NUMBER
%token <str> T_ID
%token T_OP_PLUS
%token T_OP_MIN
%token T_OP_TIM
%token T_OP_DIV
%token T_OP_SET
%token T_OP_DDOT
%token T_OPEN_P
%token T_OPEN_C
%token T_OPEN_B
%token T_CLOSE_P
%token T_CLOSE_C
%token T_CLOSE_B
%token T_COMMA

%start start

/*%type <str> definition*/

%%

start:
  | commands;

commands: instruction
  | commands instruction;

instruction: T_DEFINE definition { char *exp = get_exp($<str>2); ins_define(exp); free(exp)}
  | T_SET setting { char *exp = get_exp($<str>2); ins_set(exp); free(exp)}
  | T_LOAD exp_list { char *exp=get_exp($<str>2); ins_load(exp); free(exp)}
  | T_UNLOAD {ins_unload()}
  | T_PRINT exp_list { char*exp=get_exp($<str>2); ins_print(exp); free(exp)};

definition: T_ID T_OP_SET exp;

setting: undef_exp T_OP_SET exp;

exp_list: exp
  | exp_list T_COMMA exp;

exp: undef_exp
  | string_exp
  | number_exp
  | table_exp
  | T_OPEN_P exp T_CLOSE_P;

undef_exp: T_ID
  | T_ID T_OPEN_P exp_list T_CLOSE_P
  | T_ID T_OPEN_C exp T_CLOSE_C
  | undef_exp T_DOT T_ID
  | undef_exp T_DOT T_ID T_OPEN_P exp_list T_CLOSE_P;

string_exp: T_STRING
  | concat_list;

concat_list: concat_item T_CONCAT concat_item
  | concat_list T_CONCAT concat_item;

concat_item: T_STRING
  | undef_exp
  | number_exp;

number_exp: T_NUMBER
  | arithmetic_exp;

arithmetic_exp: arithmetic_item arithmetic_operator arithmetic_item
  | arithmetic_exp arithmetic_operator arithmetic_item;

arithmetic_operator: T_OP_PLUS
  | T_OP_MIN
  | T_OP_TIM
  | T_OP_DIV;

arithmetic_item: T_NUMBER
  | undef_exp;

table_exp: T_OPEN_B table_list T_CLOSE_B
  | T_OPEN_B T_CLOSE_B;

table_list: table_item
  | table_list T_COMMA table_item;

table_item: exp
  | T_ID T_OP_SET exp;

%%

void yyerror(char *str)
{
  fprintf(stderr, "%s\n", str);
}

int main(int argc, char **argv)
{
  if(argc <= 1) {
    fprintf(stderr,"%s: No save directory\n",argv[0]);
    return 1;
  }
  save_dir = argv[1];
  return yyparse();
}
