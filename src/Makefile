buildclient: tcp_clnt.c
	gcc tcp_clnt.c -o tcp_clnt.out
buildserver: main.asm
	nasm -f elf64 -d ELF_TYPE main.asm
	gcc main.o -o echo_server.out
all: buildclient buildserver
clean:
	rm -f *.out
	rm -f *.o
