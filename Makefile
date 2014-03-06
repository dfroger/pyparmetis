default: ext

help:
	@echo "Use one of the following target:"
	@echo "main    build C++ main program"
	@echo "ext     build Python extension module"
	@echo "test    test Python module with 4 procs"

%.o: %.c
	mpicc -c $<

main: main.o
	mpicc -o $@ $< -lparmetis

ext: pyparmetis.i setup.py
	python setup.py build_ext --inplace

clean:
	@rm -rf build/ main *.o pyparmetis_wrap.c pyparmetis.py \
			_pyparmetis.so

notebook:
	ipython notebook --browser=firefox

ipcluster:
	ipcluster start -n 6 --profile='mpi'

test:
	mpiexec -n 3 python main.py
