all: unpacker

unpacker: unpacker.cxx
	g++ unpacker.cxx -o unpacker.exe $(shell root-config --cflags --libs) -I${FAIRLOGGER_ROOT}/include/ -I${FAIRROOT_ROOT}/include/ -I${FAIRSHIP_ROOT}/include/ -I${BOOST_ROOT}/include -lboost_program_options -L${BOOST_ROOT}/lib -L${FAIRSHIP_ROOT}/lib -lOnline -L${FAIRROOT_ROOT}/lib -lBase -lFairLogger -L${FAIRLOGGER_ROOT}/lib -lcharmdet -O2 -march=native
