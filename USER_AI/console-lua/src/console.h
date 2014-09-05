#ifndef H_PARSER_CONSOLE_H
#define H_PARSER_CONSOLE_H

#include <lua.h>

char *c_ro_path;
char *c_save_path;
char *c_save_loadfilename;
char *c_save_definefilename;
char *c_save_setfilename;

lua_State *console_open(char *ro_path, char *save_path, char *loadfile, char *definefile, char *setfile);
void console_close(lua_State *l);

int console_load(lua_State *l);
int console_unload(lua_State *l);

int console_define(lua_State *l);
int console_set(lua_State *l);

int console_exit(lua_State *l);
int console_running(lua_State *l); // not a c function to lua. Just a way to check if console.exit() was called

int console_loadsave(lua_State *l);
int console_matches(lua_State *l);
#endif
