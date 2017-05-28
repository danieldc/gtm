BINARY=gtm
VERSION=v1.2.9-dev

LDFLAGS=-ldflags "-X main.Version=${VERSION}"

build:
	go build --tags static  ${LDFLAGS} -o ${BINARY}

test:
	go test --tags static  $$(go list ./... | grep -v vendor)

vet:
	go vet $$(go list ./... | grep -v vendor)

fmt:
	go fmt $$(go list ./... | grep -v vendor)

install:
	go install --tags static  ${LDFLAGS}

clean:
	go clean

.PHONY: test vet install clean fmt todo note
