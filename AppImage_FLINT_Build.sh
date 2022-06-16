#!/bin/bash
# Author: Amit Kulkarni (https://github.com/crystalsage)
# Last tested on: Arch Linux 5.18.3

# This script automates most of the FLINT AppImage installation.

clear

sudo pacman -Syyu base-devel fuse2 openssl cmake sqlite boost unixodbc pcre

WORKDIR=$PWD/build
mkdir -p $WORKDIR

# Build Turtle from source
build_turtle() {
	cd $WORKDIR
	git clone https://www.github.com/mat007/turtle.git 
	mkdir turtle/build
	cd turtle/build
	cmake .. 
	make 
	sudo make install
}

build_poco() {
	cd $WORKDIR
	wget https://github.com/pocoproject/poco/archive/refs/tags/poco-1.11.1-release.tar.gz 
	tar xvf poco-*.tar.gz
	cd poco-*-release
	mkdir cmake-build
	cd cmake-build
	cmake -DCMAKE_BUILD_TYPE=RELEASE -DPOCO_UNBUNDLED=ON \
        -DENABLE_JSON=ON \
        -DENABLE_DATA=ON \
        -DENABLE_DATA_ODBC=ON \
        -DENABLE_DATA_SQLITE=ON \
        -DENABLE_DATA_MYSQL=OFF \
        -DENABLE_ACTIVERECORD=OFF \
        -DENABLE_ACTIVERECORD_COMPILER=OFF \
        -DENABLE_ENCODINGS=OFF \
        -DENABLE_ENCODINGS_COMPILER=OFF \
        -DENABLE_XML=OFF \
        -DENABLE_MONGODB=OFF \
        -DENABLE_REDIS=OFF \
        -DENABLE_PDF=OFF \
        -DENABLE_UTIL=OFF \
        -DENABLE_NET=OFF \
        -DENABLE_NETSSL=OFF \
        -DENABLE_CRYPTO=OFF \
        -DENABLE_SEVENZIP=OFF \
        -DENABLE_ZIP=OFF \
        -DENABLE_PAGECOMPILER=OFF \
        -DENABLE_PAGECOMPILER_FILE2PAGE=OFF ..
	make 
	sudo make install
}

build_flint(){
	cd $WORKDIR
	# This should be changed to moja-global/FLINT.git once PR 119 is merged.
	git clone https://www.github.com/ankitaS11/FLINT.git
	cd FLINT 
	git checkout fix_poco_include
	mkdir Source/build
	cd Source/build
	cmake ..
	make
	make install DESTDIR=AppDir
}

get_linuxdeploy(){
	cd $WORKDIR/FLINT/Source/build/
	wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
	chmod +x linuxdeploy-x86_64.AppImage
	cd $WORKDIR/FLINT/Source/build/ && ./linuxdeploy-x86_64.AppImage --appdir AppDir || true
}

build_appimage() {
	# Copy the files from the GitHub repository:
	cd $WORKDIR/FLINT/Source/build
	git clone https://www.github.com/ankitaS11/AppImageDataForFlint.git
	cd AppImageDataForFlint
	cp icon.png $WORKDIR/FLINT/Source/build/AppDir
	cp usr/share/applications/AppDir.desktop $WORKDIR/FLINT/Source/build/AppDir/usr/share/applications/
	cd $WORKDIR/FLINT/Source/build
	cp bin/* AppDir/usr/bin/
	./linuxdeploy-x86_64.AppImage --appdir AppDir --output appimage -i AppDir/icon.png
	mv $WORKDIR/FLINT/Source/build/FLINT-*-x86_64.AppImage $WORKDIR
}

build_turtle
build_poco
build_flint
get_linuxdeploy
build_appimage

printf "\n\nAll done! The AppImage should be in the build folder"
