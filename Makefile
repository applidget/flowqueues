NPM_EXECUTABLE_HOME := node_modules/.bin

PATH := ${NPM_EXECUTABLE_HOME}:${PATH}

test: deps
	@find tests -name '*_test.coffee' | xargs -n 1 -t mocha --compilers coffee:coffee-script

dev: lib
	@coffee -wc --bare -o lib src/*.coffee

lib: license
	@find src -name '*.coffee' | xargs coffee -c -o lib

license:
	@bash inject_license.sh
	
clean:
	@rm -fr lib/

publish: generate-js
	@npm publish
	
deps:

.PHONY: all lib license clean publish

