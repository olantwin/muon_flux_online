all: unpacker

CXX:=g++
CXXFLAGS:=-O2
INCLUDE:=$(shell root-config --cflags) -I${FAIRROOT_ROOT}/include/ -I${FAIRSHIP_ROOT}/include/ -I${BOOST_ROOT}/include -I${FAIRSHIP_ROOT}/online
LIBS:=$(shell root-config --libs) -lboost_program_options -L${BOOST_ROOT}/lib -L${FAIRSHIPRUN}/lib -lOnline -L${FAIRROOT_ROOT}/lib -lBase -lcharmdet -lFairTools -lLogger

unpacker: unpacker.cxx
	$(CXX) $^ -o $@ $(CXXFLAG) $(INCLUDE) $(LIBS)
