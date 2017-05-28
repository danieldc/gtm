#!/bin/sh
set -ex

export PATH=/c/msys64/mingw64/bin:/c/msys64/usr/bin:/c/Go/bin:/c/gopath/go/bin:$PATH
export GOROOT=/c/Go/
export GOPATH=/c/gopath

git clone https://github.com/libgit2/git2go.git $GOPATH/src/github.com/libgit2/git2go
cd /c/gopath/src/github.com/libgit2/git2go
git checkout master
git submodule update --init
cd vendor/libgit2
mkdir build
cd build

export PATH=/c/msys64/mingw64/bin:/c/msys64/usr/bin:/c/Go/bin:/c/gopath/go/bin:$PATH
VENDORED_PATH=vendor/libgit2
cd $VENDORED_PATH &&
mkdir -p install/lib &&
mkdir -p build &&
cd build &&
cmake -DTHREADSAFE=ON \
      -DBUILD_CLAR=OFF \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_C_FLAGS=-fPIC \
      -DCMAKE_BUILD_TYPE="RelWithDebInfo" \
      -DCMAKE_INSTALL_PREFIX=../install \
      .. &&
cmake --build .

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
