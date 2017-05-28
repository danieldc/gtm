#!/bin/sh
export PATH=/c/msys64/mingw64/bin:/c/msys64/usr/bin:/c/Go/bin:/c/gopath/go/bin:$PATH

GIT2GO_PATH=$GOPATH/src/github.com/libgit2/git2go
cd $GIT2GO_PATH/vendor/libgit2 && mkdir build && cd build
LIBGIT2_BUILD=$GIT2GO_PATH/vendor/libgit2/build
FLAGS="-lws2_32"
export CGO_LDFLAGS="$LIBGIT2_BUILD/libgit2.a -L$LIBGIT2_BUILD ${FLAGS}"
cmake -DTHREADSAFE=ON \
      -DBUILD_CLAR=OFF \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_C_FLAGS=-fPIC \
      -DCMAKE_BUILD_TYPE="RelWithDebInfo" \
      -DCMAKE_INSTALL_PREFIX=../install \
      -DWINHTTP=OFF \
      -G "MSYS Makefiles" \
      .. &&
cmake --build . --target install
cd $GIT2GO_PATH && go install --tags static

cd /c/gopath/src/github.com/git-time-metric/gtm
go get -d ./...
go test --tags static ./...
if [[ "${APPVEYOR_REPO_TAG}" = true ]]; then
    go build --tags static -v -ldflags "-X main.Version=${APPVEYOR_REPO_TAG_NAME}"
    tar -zcf gtm.${APPVEYOR_REPO_TAG_NAME}.windows.tar.gz gtm.exe
else
    timestamp=$(date +%s)
    go build --tags static -v -ldflags "-X main.Version=developer-build-$timestamp"
    tar -zcf "gtm.developer-build-$timestamp.windows.tar.gz" gtm.exe
fi
