#include <stdio.h>
#include <limits.h>
#include <stdlib.h>
#include <regex.h>
#include <string.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include "console.h"

#define RO_AI_PATH "AI/"

//#define L_PARAM_GLOBAL_FNC "___write_arguments"
//#define L_PARAM_FUNCTION "function "L_PARAM_GLOBAL_FNC"(...)\n"\
                         "  return table.concat(arg, \", \")\n"\
			 "end\n"


void path_from_ro(char *dest, const char *filename)
{
  char buffer[PATH_MAX];
  if(!realpath(filename, buffer)) {
    fprintf(stderr, "path_from_ro error: Could not get path from realpath()\n");
    fprintf(stderr, "Path: %s\n", filename);
    exit(1);
  }
  
  regex_t regex;
  regmatch_t pmatch[2];
  size_t nmatch = 2;
  int reti;

  regcomp(&regex, RO_AI_PATH, 0);
  reti = regexec(&regex, buffer, nmatch, pmatch, 0);
  regfree(&regex);

  if(reti) {
    fprintf(stderr, "path_from_ro error: Could not find path from RO's direcotry\n");
    exit(1);
  }
  strncpy(dest, "./", PATH_MAX-1);
  strncat(dest, &(buffer[pmatch[0].rm_so]), PATH_MAX-strlen(dest));
}

void set_value(lua_State *l, FILE *file)
{
  const char *name = luaL_checkstring(l, 1);
  fprintf(file, "%s = ", name);
  const char *value = luaL_checkstring(l, 2);
  fprintf(file, "%s\n", value);
}

/*  */
lua_State *console_open(char *ro_path, char *save_path, char *loadfilename, char *definefilename, char *setfilename)
{
  c_ro_path = ro_path;
  c_save_path = save_path;
  c_save_loadfilename = loadfilename;
  c_save_definefilename = definefilename;
  c_save_setfilename = setfilename;
  // debug
  puts(c_save_path);
  puts(c_save_loadfilename);
  puts(c_save_definefilename);
  puts(c_save_setfilename);

  lua_State *l = lua_open();
  luaL_openlibs(l);

  //if(luaL_loadbuffer(l, L_PARAM_FUNCTION, strlen(L_PARAM_FUNCTION)+1, "console_parser")) {
  //  printf(L_PARAM_FUNCTION);
  //  fprintf(stderr, "console_open error: Could not load " L_PARAM_GLOBAL_FNC "\n");
  //  exit(1);
  //}
  //if(luaL_loadfile(l, save_loadfilename), lua_pcall(l, 0, 0, 0)) {
  //  fprintf(stderr, "console_open: Could not load %s file.\n", save_loadfilename);
  //  lua_close(l);
  //  exit(1);
  //}
  if((luaL_loadfile(l, c_save_definefilename) || lua_pcall(l, 0, 0, 0)) && file_exists(c_save_definefilename) ) {
    fprintf(stderr, "console_open: Could not load %s file.\n", c_save_definefilename);
    lua_close(l);
    exit(1);
  }
  if(luaL_loadfile(l, c_save_setfilename) || lua_pcall(l, 0, 0, 0) && file_exists(c_save_setfilename)) {
    fprintf(stderr, "console_open: Could not load %s file.\n", c_save_setfilename);
    lua_close(l);
    exit(1);
  }

  lua_newtable(l);

  lua_pushstring(l, "load"); /* key */
  lua_pushcfunction(l, console_load); /* value */
  lua_settable(l, -3);

  lua_pushstring(l, "unload"); /* key */
  lua_pushcfunction(l, console_unload); /* value */
  lua_settable(l, -3);

  lua_pushstring(l, "define"); /* key */
  lua_pushcfunction(l, console_define); /* value */
  lua_settable(l, -3);

  lua_pushstring(l, "set"); /* key */
  lua_pushcfunction(l, console_set); /* value */
  lua_settable(l, -3);

  lua_pushstring(l, "exit"); /* key */
  lua_pushcfunction(l, console_exit); /* value */
  lua_settable(l, -3);

  lua_pushstring(l, "running"); /* key */
  lua_pushboolean(l, 1); /* value */
  lua_settable(l, -3);

  lua_pushstring(l, "loadsave"); /* key */
  lua_pushcfunction(l, console_loadsave); /* value */
  lua_settable(l, -3);

  lua_pushstring(l, "matches"); /* key */
  lua_pushcfunction(l, console_matches);
  lua_settable(l, -3);

  lua_setglobal(l, "console");

  // consolerc
  char buffer[PATH_MAX];
  strncpy(buffer, c_save_path, PATH_MAX-1);
  strncat(buffer, "/consolerc.lua", PATH_MAX-1-strlen(buffer));
  if(file_exists(buffer)) {
    if(luaL_loadfile(l, buffer) || lua_pcall(l, 0, 0, 0)) {
      fprintf(stderr, "console_open: Could not load %s.\n", buffer);
      lua_close(l);
      exit(1);
    }
  }
  return l;
}

void console_close(lua_State *l)
{
  lua_close(l);
}

// console.load(filename, ...)
int console_load(lua_State *l)
{
  char buffer1[PATH_MAX];
  char buffer2[PATH_MAX];
  const char *filename = luaL_checkstring(l, 1);

  strncpy(buffer1, c_ro_path, PATH_MAX-1);
  strncat(buffer1, "/", PATH_MAX-1-strlen(buffer1));
  strncat(buffer1, filename, PATH_MAX-1-strlen(buffer1));
  //path_from_ro(buffer2, buffer1);
  if(!realpath(buffer1, buffer2)) {
    fprintf(stderr, "path_from_ro error: Could not get path from realpath()\n");
    fprintf(stderr, "Path: %s\n", filename);
    exit(1);
  }

  if(!file_exists(buffer2)) {
    fprintf(stderr, "console.load error: No %s AI file\n", buffer2);
    return 0;
  }
  FILE *loadfile = fopen(c_save_loadfilename,"w");
  if(!loadfile) {
    fprintf(stderr, "console.load error: Could not open %s\n", c_save_loadfilename);
    return 0;
  }
  //int n = lua_gettop(l);
  //lua_getglobal(l, L_PARAM_GLOBAL_FNC);
  //if(lua_pcall(l, n, 1, 0)) {
  //  fprintf(stderr, "console.load error: Could not call " L_PARAM_GLOBAL_FNC "\n");
  //  remove(save_loadfilename);
  //  exit(1);
  //}
  //path_from_ro(buffer, c_save_setfilename);
  //fprintf(loadfile, "require \"%s\"\n", buffer); // maybe not that necessary...?
  fprintf(loadfile, "return {\"%s\"", filename);
  lua_remove(l, 1);
  int i,n = lua_gettop(l);
  for(i = 0; i < n; i++)
    switch(lua_type(l, i)) {
    case LUA_TNIL:     fprintf(loadfile, ", nil"); break;
    case LUA_TBOOLEAN: fprintf(loadfile, ", %s", (lua_toboolean(l, i)?"true":"false")); break;
    case LUA_TNUMBER:  fprintf(loadfile, ", %.20g", luaL_checknumber(l, i)); break;
    case LUA_TSTRING:  fprintf(loadfile, ", \"%s\"", luaL_checkstring(l, i)); break;
    }
  fprintf(loadfile, "}\n");
  fclose(loadfile);
  return 0;
}

// console.unload()
int console_unload(lua_State *l)
{
  remove(c_save_loadfilename);
  return 0;
}

// console.define(name, value)
int console_define(lua_State *l)
{
  FILE *file = fopen(c_save_definefilename, "a");
  if(!file) {
    fprintf(stderr, "console.define error: Could not open %s\n", c_save_definefilename);
    return 0;
  }
  set_value(l, file);
  fclose(file);
  if((luaL_loadfile(l, c_save_definefilename) || lua_pcall(l, 0, 0, 0)) && file_exists(c_save_definefilename) ) {
    fprintf(stderr, "console.define: Could not load %s file.\n", c_save_definefilename);
    lua_close(l);
    exit(1);
  }
  if(luaL_loadfile(l, c_save_setfilename) || lua_pcall(l, 0, 0, 0) && file_exists(c_save_setfilename)) {
    fprintf(stderr, "console.define: Could not load %s file.\n", c_save_setfilename);
    lua_close(l);
    exit(1);
  }
  return 0;
}

// console.set(name, value)
int console_set(lua_State *l)
{
  FILE *file = fopen(c_save_setfilename, "a");
  if(!file) {
    fprintf(stderr, "console.set error: Could not open %s\n", c_save_setfilename);
    return 0;
  }
  set_value(l, file);
  fclose(file);
  if(luaL_loadfile(l, c_save_setfilename) || lua_pcall(l, 0, 0, 0) && file_exists(c_save_setfilename)) {
    fprintf(stderr, "console.set: Could not load %s file.\n", c_save_setfilename);
    lua_close(l);
    exit(1);
  }
  return 0;
}

int console_exit(lua_State *l)
{
  lua_getglobal(l, "console");
  lua_pushboolean(l, 0);  /* value */
  lua_setfield(l, -2, "running");
  return 0;
}

/* Not a function to run with Lua */
int console_running(lua_State *l)
{
  lua_settop(l, 0);
  lua_getglobal(l, "console");
  if(!lua_istable(l, 1)) {
    fprintf(stderr, "console_running error: Expected table value from console.\n");
    lua_pop(l, 1);
    return 0;
  }
  lua_getfield(l, 1, "running");
  if(!lua_isboolean(l, 2)) {
    fprintf(stderr, "console.running error: Expected boolean value.\n");
    lua_pop(l, 2);
    return 0;
  }
  int running = lua_toboolean(l, 2);
  lua_settop(l, 0);
  return running;
}

// console.loadsave(filename)
int console_loadsave(lua_State *l)
{
  const char *savefile = luaL_checkstring(l, 1);
  char buffer[PATH_MAX];
  int n = 1;
  if(lua_gettop(l) > 1) {
    n = (int)luaL_checknumber(l, 2);
  }

  strncpy(buffer, c_save_path, PATH_MAX-1);
  strncat(buffer, "/", PATH_MAX-strlen(buffer)-1);
  strncat(buffer, savefile, PATH_MAX-strlen(buffer)-1);

  if(!file_exists(buffer)) {
    fprintf(stderr, "console.loadsave: Save file %s doesn not exist.\n", savefile);
    return 0;
  }

  if(luaL_loadfile(l, buffer) || lua_pcall(l, 0, n, 0)) {
    fprintf(stderr, "console.loadsave: Could not load %s file.\n", savefile);
    lua_close(l);
    exit(1);
  }
  return n;
}

int console_matches(lua_State *l)
{
  const char *str_regex = luaL_checkstring(l, 2);
  const char *str;
  regex_t regex;
  regmatch_t pmatch[2];
  size_t nmatch = 2;
  int reti;

  if(regcomp(&regex, str_regex, 0)) {
    fprintf(stderr, "console.matches: Invalid Regex.\n");
    return 0;
  }
  str = luaL_checkstring(l, 1);

  reti = regexec(&regex, str, nmatch, pmatch, 0);
  regfree(&regex);

  lua_pushboolean(l, !reti);
  return 1;
}
