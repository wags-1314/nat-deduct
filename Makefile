main: main.cc parser.y lexer.l parser_util.cc
	bison -d parser.y -o parser.cc -x
	flex lexer.l
	g++ -o $@ main.cc parser.cc lex.yy.c parser_util.cc terminal.cc -Wall -Wextra -std=c++17
	@echo "Compiled to ./main"

.PHONY: clean

clean:
	-rm main parser.cc parser.hh lex.yy.c parser.xml
