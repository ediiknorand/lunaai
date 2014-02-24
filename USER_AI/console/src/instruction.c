#include <string.h>
#include <stdio.h>
#include "instruction.h"

void remove_command(char *str, char *command)
{
  int idx = strlen(str) - strlen(command);
  if(idx >= 0 && !strcmp(&str[idx], command))
    str[idx] = '\0';
}

char *get_exp(char *str)
{
  char *exp = strdup(str);

  if(exp[strlen(exp)-1] == '\n')
    exp[strlen(exp)] = '\0';

  if(strcmp("define", exp) >= 0)
    remove_command(exp, "define");
  if(strcmp("set", exp) >= 0)
    remove_command(exp, "set");
  if(strcmp("unload", exp) >= 0)
    remove_command(exp, "unload");
  if(strcmp("load", exp) >= 0)
    remove_command(exp, "load");
  if(strcmp("print", exp) >= 0)
    remove_command(exp, "print");

  return exp;
}

void ins_define(char *str)
{
  FILE *file = fopen("define.lua", "a");
  fprintf(file, "%s\n", str);
  fclose(file);
}

void ins_set(char *str)
{
  FILE *file = fopen("set.lua", "a");
  fprintf(file, "%s\n", str);
  fclose(file);
}

void ins_load(char *str)
{
  FILE *load_file = fopen("load.lua", "w");
  fprintf(load_file, "require \"./AI/USER_AI/console/set.lua\"\n");
  fprintf(load_file, "return {%s}\n", str);
  fclose(load_file);
}

void ins_unload()
{
  remove("load.lua");
}

void ins_print(char *str)
{
  puts(str);
}
