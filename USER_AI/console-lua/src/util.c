#include <string.h>
#include <stdlib.h>
#include <regex.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "util.h"

int matches(const char *string, const char *str_regex)
{
  regex_t regex;
  regmatch_t pmatch[2];
  size_t nmatch = 2;
  int reti;

  regcomp(&regex, str_regex, 0);
  reti = regexec(&regex, string, nmatch, pmatch, 0);
  regfree(&regex);

  return !reti;
}

void path_to_file(char *dest, const char *path, const char *filename, size_t n)
{
  strncpy(dest, path, n);
  strncat(dest, filename, n);
}

int file_exists(const char *filename)
{
  struct stat st;
  return !stat(filename, &st);
}
