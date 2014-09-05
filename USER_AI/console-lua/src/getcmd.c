#include <stdio.h>
#include <string.h>
#include "console.h"
#include "util.h"

#define BUF_SIZE 1024
#define DIR_PATH_REGEX "^\\([-a-zA-Z0-9_\\.]\\+/\\)*[-a-zA-Z0-9_\\.]\\+/\\?$"
#define L_RO_PATH "../../../"
#define L_DEFINE_FILE "/define.lua"
#define L_SET_FILE "/set.lua"
#define L_LOAD_FILE "/load.lua"

int main(int argc, char **argv)
{
  // ./parser save_dir
  if(argc < 4) {
    fprintf(stderr, "Usage: %s chat-file name save-dir\n", argv[0]);
    return 1;
  }

  char load_path[BUF_SIZE];
  char define_path[BUF_SIZE];
  char set_path[BUF_SIZE];

  char *chat_file = argv[1];
  char *name = argv[2];
  char *save_dir = argv[3];

  if(!matches(save_dir, DIR_PATH_REGEX)) {
    fprintf(stderr, "Invalid path for save-dir\n");
    return 1;
  }
  path_to_file(load_path, save_dir, L_LOAD_FILE, BUF_SIZE);
  path_to_file(define_path, save_dir, L_DEFINE_FILE, BUF_SIZE);
  path_to_file(set_path, save_dir, L_SET_FILE, BUF_SIZE);


  lua_State *l = console_open(L_RO_PATH, save_dir, load_path, define_path, set_path);
  char buffer[BUF_SIZE];
  char command[BUF_SIZE];
  FILE *in;

  snprintf(command, BUF_SIZE, "cat %s | tr -d \r | sed s\"/|00//\" | grep \"^%s : \\^\" | tr -d ^ | tail -n 1 | cut -d: -f2-", chat_file, name);
  while(console_running(l)) {
    in = popen(command, "r");
    if(!in) {
      fprintf(stderr, "Could not execute command\n");
      return 1;
    }
    while(fgets(buffer, BUF_SIZE-1, in)) {
      luaL_loadbuffer(l, buffer, strlen(buffer), "line");
      lua_pcall(l, 0, 0, 0);
    }
    pclose(in);
  }
  console_close(l);

  return 0;
}
