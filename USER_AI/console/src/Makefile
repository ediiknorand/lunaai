parser: console.tab.c console.tab.h lex.yy.o instruction.o
	gcc -o parser console.tab.c lex.yy.o instruction.o -lfl

console.tab.c: console.y
	bison -d console.y

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

lex.yy.c: console.l
	flex console.l

instruction.o: instruction.c instruction.h
	gcc -c instruction.c

clean:
	rm -f parser console.tab.c console.tab.h lex.yy.c lex.yy.o instruction.o
