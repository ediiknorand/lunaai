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
  char str_dir[64];
  strcpy(str_dir, "../saves/");
  strcat(str_dir, save_dir);
  strcat(str_dir, "/define.lua");
  FILE *file = fopen(str_dir, "a");
  fprintf(file, "%s\n", str);
  fclose(file);
}

void ins_set(char *str)
{
  char str_dir[64];
  strcpy(str_dir, "../saves/");
  strcat(str_dir, save_dir);
  strcat(str_dir, "/set.lua");
  FILE *file = fopen(str_dir, "a");
  fprintf(file, "%s\n", str);
  fclose(file);
}

void ins_load(char *str)
{
  char str_dir[64];
  strcpy(str_dir, "../saves/");
  strcat(str_dir, save_dir);
  strcat(str_dir, "/load.lua");
  FILE *load_file = fopen(str_dir, "w");
  //fprintf(load_file, "require \"./AI/USER_AI/saves/%s/set.lua\"\n", save_dir);
  fprintf(load_file, "return {%s}\n", str);
  fclose(load_file);
}

void ins_unload()
{
  char str_dir[64];
  strcpy(str_dir, "../saves/");
  strcat(str_dir, save_dir);
  strcat(str_dir, "/load.lua");
  remove(str_dir);
}

void ins_print(char *str)
{
  puts(str);
}
