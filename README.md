#echossembly
echossembly is a simple POC exploratory program that experiments with TCP and Assembly. The project
is written using NASM Assembly and is oriented towards x64 bit Linux Architectures

#Prerequisites
To use the program, you will need `gcc` and `nasm` installed. You can install them on Ubuntu/Debian
with the following commands
```
sudo apt-get install build-essentials
sudo apt-get install nasm
```
#Setup
Simply execute the Makefile to build the project. Run the following:
* `make all` - Builds both the echo server and client
* `make clean` - Cleans up all build components for the server and client

Startup the server by executing the following command
`./echo_server.out`
By default the echo_server listens on port 8000

Startup the client and follow the on screen prompts by executing the following command
`./tcp_clnt.out 127.0.0.1 8000`

Note that also telnet works on the echo server. You can use telnet the same by running
```
telent 127.0.0.1 8000
```

