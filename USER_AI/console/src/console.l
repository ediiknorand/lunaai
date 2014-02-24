
%{
#include <stdio.h>
#include <math.h>
#include "console.tab.h"
%}

DIGIT	[0-9]
D_DIGIT "."{DIGIT}+
ID	[a-zA-Z_]+[a-zA-Z0-9_]*

%%

"^"	{
	return T_COMMAND;
	}

";"	{
	return T_END;
	}

".."	{
	return T_CONCAT;
	}

"."	{
	return T_DOT;
	}

and|or|not|div	{
	switch(yytext[0])
	{
		case 'a': return T_AND;
		case 'n': return T_NOT;
		case 'o': return T_OR;
		case 'd': return T_DIV;
	}
	}

print	{
	return T_PRINT;
	}

set	{
	return T_SET;
	}

define	{
	return T_DEFINE;
	}

load	{
	return T_LOAD;
	}

unload	{
	return T_UNLOAD;
	}

\"[^"]*\"	{
	yylval.str = yytext;
	return T_STRING;
	}

{DIGIT}+{D_DIGIT}?	{
	//yylval.num = (float)atof(yytext);
	//yylval.num = yytext;
	return T_NUMBER;
	}

{ID}	{
	yylval.id = yytext;
	return T_ID;
	}

"+"|"-"|"*"|"/"|"="|":"	{
	switch(yytext[0])
	{
		case '+': return T_OP_PLUS;
		case '-': return T_OP_MIN;
		case '*': return T_OP_TIM;
		case '/': return T_OP_DIV;
		case '=': return T_OP_SET;
		case ':': return T_OP_DDOT;
	}
	}

"("|")"	{
	switch(yytext[0])
	{
		case '(': return T_OPEN_P;
		case ')': return T_CLOSE_P;
	}
	}

"["|"]"	{
	switch(yytext[0])
	{
		case '[': return T_OPEN_C;
		case ']': return T_CLOSE_C;
	}
	}

"{"|"}"	{
	switch(yytext[0])
	{
		case '{': return T_OPEN_B;
		case '}': return T_CLOSE_B;
	}
	}

","	{
	return T_COMMA;
	}

[ \t]	{}

.	{}

%%
