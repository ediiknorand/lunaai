#ifndef H_INSTRUCTION_H
#define H_INSTRUCTION_H

char *save_dir;

char *get_exp(char *str);
void ins_define(char *str);
void ins_set(char *str);
void ins_load(char *str);
void ins_unload();
void ins_print(char *str);

#endif
