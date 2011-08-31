all:
	make -C src

package:
	make package -C src

clean:
	make clean -C src
