.DEFAULT_GOAL := build

clean:
	swift package clean

force-clean:
	rm -rf .build

build: 
	swift build

build-release:
	swift build -c release --disable-sandbox

test:
	swift test
