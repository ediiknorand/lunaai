#ifndef H_PARSER_UTIL_H
#define H_PARSER_UTIL_H

int matches(const char *string, const char *str_regex);
void path_to_file(char *dest, const char *path, const char *filename, size_t n);
int file_exists(const char *filename);

#endif
