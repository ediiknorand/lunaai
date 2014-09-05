getcmd: getcmd.c console.o util.o
	gcc -o ../getcmd getcmd.c console.o util.o -llua
	rm -f console.o util.o

parser: parser.c console.o util.o
	gcc -o ../parser parser.c console.o util.o -llua
	rm -f console.o util.o

console.o: console.c console.h
	gcc -c console.c -llua

util.o: util.c util.h
	gcc -c util.c

clean:
	rm -f ../parser ../getcmd console.o util.o
