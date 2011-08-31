TOOLCHAIN = /home/h2co3/ios-toolchain/toolchain/
TOOLCHAIN_BIN = $(TOOLCHAIN)/pre/bin
TOOLCHAIN_SYS = /User/sysroot # $(TOOLCHAIN)/sys

PROJECT = MFMusicLibrary
ID = org.h2co3.mfmusiclibrary
NAME = MFMusicLibrary.framework
VERSION = 0.4
DEPS = glib, libgpod, libid3tag
ARCH = iphoneos-arm
PACKAGE = $(ID)_$(VERSION)_$(ARCH)

CC = gcc # $(TOOLCHAIN_BIN)/arm-apple-darwin9-gcc
LD = $(CC)
CFLAGS  = -isysroot $(TOOLCHAIN_SYS) \
	  -Wall \
	  -std=gnu99 \
	  -I. \
	  -I/usr/include/glib-2.0 \
	  -I/usr/include/gpod-1.0 \
	  -c
LDFLAGS = -isysroot $(TOOLCHAIN_SYS) \
	  -w \
	  -dynamiclib \
	  -install_name /System/Library/Frameworks/$(PROJECT).framework/$(PROJECT) \
	  -lglib-2.0 \
	  -lgpod \
	  -lid3tag \
	  -framework Foundation
	  
OBJECTS = MFMusicLibrary.o MFMusicTrack.o MFID3Tag.o
HEADERS = MFMusicLibrary.h MFMusicTrack.h MFID3Tag.h MFCommonDefines.h

all: $(PROJECT)

$(PROJECT): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $(PROJECT) $(OBJECTS)

package: $(PROJECT)
	mkdir -p ../bld/$(PACKAGE)/System/Library/Frameworks/$(PROJECT).framework/Headers
	mkdir -p ../bld/$(PACKAGE)/DEBIAN
	cp $(PROJECT) ../bld/$(PACKAGE)/System/Library/Frameworks/$(PROJECT).framework/
	cp $(HEADERS) ../bld/$(PACKAGE)/System/Library/Frameworks/$(PROJECT).framework/Headers/
	cp -r ../misc/* ../bld/$(PACKAGE)/System/Library/Frameworks/$(PROJECT).framework/
	echo Package: $(ID) >> ../bld/$(PACKAGE)/DEBIAN/control
	echo Name: $(NAME) >> ../bld/$(PACKAGE)/DEBIAN/control
	echo Version: $(VERSION) >> ../bld/$(PACKAGE)/DEBIAN/control
	echo Depends: $(DEPS) >> ../bld/$(PACKAGE)/DEBIAN/control
	echo Architecture: $(ARCH) >> ../bld/$(PACKAGE)/DEBIAN/control
	echo Section: Development >> ../bld/$(PACKAGE)/DEBIAN/control
	echo 'Author: Arpad Goretity (H2CO3) <arpad.goretity@gmail.com>' >> ../bld/$(PACKAGE)/DEBIAN/control
	echo 'Maintainer: Arpad Goretity (H2CO3) <arpad.goretity@gmail.com>' >> ../bld/$(PACKAGE)/DEBIAN/control
	echo Depiction: http://h2co3.zxq.net/ >> ../bld/$(PACKAGE)/DEBIAN/control
	echo Description: Objective-C wrapper library around libgpod >> ../bld/$(PACKAGE)/DEBIAN/control
	cp postinst ../bld/$(PACKAGE)/DEBIAN
	dpkg-deb --build ../bld/$(PACKAGE)
	rm -rf ../bld/$(PACKAGE)

clean:
	rm -rf $(OBJECTS) $(PROJECT)

%.o: %.m
	$(CC) $(CFLAGS) -o $@ $^

