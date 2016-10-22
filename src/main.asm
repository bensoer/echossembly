;;=============================================================================
;;	echossembly is a Linux NASM x64 echo server that repeats back content sent
;;	back from the client. The program works most effectively with a telnet
;;	client
;;
;;	Build: 
;;		nasm -f elf64 -d ELF_TYPE main.asm
;;		gcc main.asm -o main.out
;;	Execute:
;;		./main.out
;;
;; Sources:
;;	http://stackoverflow.com/questions/32541055/why-do-i-get-eacces-after-invoking-socket-bind-in-nasm-linux-x64
;;	https://ubuntuforums.org/archive/index.php/t-1105208.html
;;	https://github.com/arno01/SLAE/blob/master/exam1/shell_bind_tcp.nasm
;;	https://github.com/sathish09/SLAE-64/blob/master/Assignment%206/Bind-shell-TCP/original_shellcode.nasm
;;	https://www.exploit-db.com/exploits/39149/
;;	https://forum.nasm.us/index.php?topic=1638.0
;;	http://stackoverflow.com/questions/9417341/linux-nasm-detect-eof
;;	https://linux.die.net/man/2/read
;;	https://www.csee.umbc.edu/portal/help/nasm/sample_64.shtml#printf1_64.asm
;;	http://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/
;;	https://ubuntuforums.org/showthread.php?t=1105208
;;	http://man7.org/linux/man-pages/man2/shutdown.2.html
;;
;;=============================================================================

;;%include "asm_io.inc"

%define PROTO_FAM 			2					; AF_INET
%define PROTO_TYPE			1					; SOCK_STREAM
%define PROTO 				0
%define SYS_SOCKET			41					; sys_socket call name
%define SYS_BIND			49					; sys_bind call name
%define SYS_LISTEN			50					; sys_listen call name
%define SYS_LISTEN_BACKLOG	10					; how many tcp connections can be queued
%define SYS_ACCEPT			43					; accept a connection

%define SYS_READ			0					; sys call to read from descriptor
%define SYS_WRITE			1					; sys call to write to descriptor
%define SYS_CLOSE			3					; sys call to close the descriptor
%define SYS_SHUTDOWN		48					; sys call to shutdown connection




; Convert numbers (constants!) to network byte order
%define htonl(x) ((x & 0xFF000000) >> 24) | ((x & 0x00FF0000) >> 8) | ((x & 0x0000FF00) << 8) | ((x & 0x000000FF) << 24)
%define htons(x) ((x >> 8) & 0xFF) | ((x & 0xFF) << 8)


SECTION .data

format: dd `num: %d\n`, 10, 0
integer dd 0

struc sockaddr_in
    .sin_family resw 1
    .sin_port resw 1
    .sin_addr resd 1
    .sin_zero resb 8
endstruc

INADDR_ANY	equ		0							; bind to any nic

IP			equ		htonl(INADDR_ANY)
PORT 		equ 	htons(8000)

my_sa: istruc sockaddr_in
            at sockaddr_in.sin_family, dw PROTO_FAM
            at sockaddr_in.sin_port, dw PORT
            at sockaddr_in.sin_addr, dd INADDR_ANY
            at sockaddr_in.sin_zero, dd 0, 0   ;  for struct sockaddr
        iend


BUFFERLEN equ 16

SECTION .bss
BUFFER resb BUFFERLEN
fd_socket resd 1
fd_conn resd 1
fd_conn_bytes resd 1

SECTION .text
extern printf
global main

main:

	; create a socket
	mov rdi, PROTO_FAM
 	mov rsi, PROTO_TYPE
 	mov rdx, PROTO
	mov rax, SYS_SOCKET
	syscall

	mov [fd_socket], rax ; sockfd is in rax, put a copy in rbx for now

	; bind the socket to a port
	mov rdi, [fd_socket]
	mov rax, SYS_BIND
	mov rsi, my_sa								; address to struct sockaddr my_sa
	mov rdx, sockaddr_in_size
	syscall

	; start listening for connections
	mov rdi, [fd_socket]
	mov rsi, SYS_LISTEN_BACKLOG
	mov rax, SYS_LISTEN
	syscall


loop:

	; accept a connection
	mov rdi, [fd_socket]
	mov rsi, 0
	mov rdx, 0
	mov rax, SYS_ACCEPT
	syscall
 
	mov [fd_conn], rax ; session sockfd is in rax, put a copy in rcx for now


	; read from the descriptor
	mov rdi, [fd_conn]
	mov rsi, BUFFER
	mov rdx, BUFFERLEN
	mov rax, SYS_READ
	syscall

	;mov rbx, rax ; rax contains the number of bytes read
	mov [fd_conn_bytes], rax
	mov [integer], rax

	call asmprintf_int

	; write back to it
	mov rdi, [fd_conn]
	mov rsi, BUFFER
	mov rdx, [fd_conn_bytes]
	mov rax, SYS_WRITE
	syscall

	; shutdown connection
	mov rdi, [fd_conn]
	mov rsi, 2
	mov rax, SYS_SHUTDOWN
	syscall

	; close the connection
	;mov rdi, [fd_conn]
	;mov rax, SYS_CLOSE
	;syscall

	jmp loop

	ret


asmprintf_int:

     ;prep
     push rbp

     mov rdi, format
     mov rsi, [integer]
     mov rax, 0 

     call printf                 ; call printf system call
     
     ;cleanup
     pop rbp
    
     ret









