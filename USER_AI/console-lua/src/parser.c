#include <stdio.h>
#include <string.h>
#include "console.h"
#include "util.h"

#define BUF_SIZE 128
#define DIR_PATH_REGEX "^\\([-a-zA-Z0-9_\\.]\\+/\\)*[-a-zA-Z0-9_\\.]\\+/\\?$"
#define L_RO_PATH "../../../"
#define L_DEFINE_FILE "/define.lua"
#define L_SET_FILE "/set.lua"
#define L_LOAD_FILE "/load.lua"

int main(int argc, char **argv)
{
  // ./parser save_dir
  if(argc < 2) {
    fprintf(stderr, "Usage: %s save-dir\n", argv[0]);
    return 1;
  }

  char load_path[BUF_SIZE];
  char define_path[BUF_SIZE];
  char set_path[BUF_SIZE];

  char *save_dir = argv[1];

  if(!matches(save_dir, DIR_PATH_REGEX)) {
    fprintf(stderr, "Invalid path for save-dir\n");
    return 1;
  }
  path_to_file(load_path, save_dir, L_LOAD_FILE, BUF_SIZE);
  path_to_file(define_path, save_dir, L_DEFINE_FILE, BUF_SIZE);
  path_to_file(set_path, save_dir, L_SET_FILE, BUF_SIZE);

  FILE *in = stdin;

  lua_State *l = console_open(L_RO_PATH, save_dir, load_path, define_path, set_path);
  char buffer[256];
  fgets(buffer, 256, in);
  luaL_loadbuffer(l, buffer, strlen(buffer), "line");
  lua_pcall(l, 0, 0, 0);
  console_close(l);

  return 0;
}
