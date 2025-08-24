APP=DevTools

all: build

build:
	bash ./build.sh

run: build
	open .build-cli/$(APP).app

clean:
	rm -rf .build-cli