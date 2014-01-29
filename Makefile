NPM_EXECUTABLE_HOME := node_modules/.bin

PATH := ${NPM_EXECUTABLE_HOME}:${PATH}

test: deps
	@find tests -name '*_test.coffee' | xargs -n 1 -t mocha --compilers coffee:coffee-script

dev: generate-js
	@coffee -wc --bare -o lib src/*.coffee

generate-js: license
	@find src -name '*.coffee' | xargs coffee -c -o lib
	@cp src/*.js lib

license:
	@bash inject_license.sh
	
clean:
	@rm -fr lib/

publish: generate-js
	@npm publish
	
deps:

.PHONY: all generate-js license clean publish

