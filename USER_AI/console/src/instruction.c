#include <string.h>
#include <stdio.h>
#include <regex.h>
#include "instruction.h"

char *get_exp(char *str)
{
  char *exp = strdup(str);
  regex_t regex;
  regmatch_t pmatch[2];
  size_t nmatch = 2;
  int reti;

  regcomp(&regex, "\\(define\\|set\\|load\\|unload\\|print\\)\\?[ ]*$", 0);
  reti = regexec(&regex, str, nmatch, pmatch, 0);
  regfree(&regex);

  if(!reti)
    exp[pmatch[0].rm_so] = '\0';

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
