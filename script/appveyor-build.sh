#!/bin/sh
set -ex

export PATH=/c/msys64/mingw64/bin:/c/msys64/usr/bin:/c/Go/bin:/c/gopath/go/bin:$PATH
export GOROOT=/c/Go/
export GOPATH=/c/gopath

git clone https://github.com/libgit2/git2go.git $GOPATH/src/github.com/libgit2/git2go
cd /c/gopath/src/github.com/libgit2/git2go
git checkout master
git submodule update --init

$env:PKG_CONFIG_PATH="/c/gopath/src/github.com/libgit2/git2go/vendor/libgit2/install/lib"
make install-static

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
