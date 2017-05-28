#!/bin/sh
set -ex

export PATH=/c/msys64/mingw64/bin:/c/msys64/usr/bin:/c/Go/bin:/c/gopath/go/bin:$PATH
export GOROOT=/c/Go/
export GOPATH=/c/gopath

# remove zlib
rm C:/msys64/mingw64/lib/libz.dll.a
rm C:/msys64/mingw64/lib/libz.a
rm C:/msys64/mingw64/bin/zlib1.dll

PROJPATH="$GOPATH/src/github.com/libgit2/git2go"
git clone https://github.com/libgit2/git2go.git $PROJPATH
cd $PROJPATH
git submodule update --init
cd vendor/libgit2 && mkdir build
cd build

LGIT2_BUILD=$PROJPATH/vendor/libgit2/build
FLAGS="${FLAGS} -lwinhttp -lcrypt32 -lrpcrt4 -lole32"
export CGO_LDFLAGS="$LGIT2_BUILD/libgit2.a -L$LGIT2_BUILD ${FLAGS}"
cmake -DTHREADSAFE=ON \
      -DBUILD_CLAR=OFF \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_C_FLAGS=-fPIC \
      -DCMAKE_BUILD_TYPE="RelWithDebInfo" \
      -DCMAKE_INSTALL_PREFIX=../install \
      -G "MSYS Makefiles" \
      .. &&
cmake --build . --target install

cd /c/gopath/src/github.com/libgit2/git2go
go install --tags static

cd /c/gopath/src/github.com/git-time-metric/gtm
go get -d ./...
go test --tags static ./...

if [[ "${APPVEYOR_REPO_TAG}" = true ]]; then
    go build -v -ldflags "-X main.Version=${APPVEYOR_REPO_TAG_NAME}"
    tar -zcf gtm.${APPVEYOR_REPO_TAG_NAME}.windows.tar.gz gtm.exe
else
    timestamp=$(date +%s)
    go build -v -ldflags "-X main.Version=developer-build-$timestamp"
    tar -zcf "gtm.developer-build-$timestamp.windows.tar.gz" gtm.exe
fi
