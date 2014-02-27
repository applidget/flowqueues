NPM_EXECUTABLE_HOME := node_modules/.bin

PATH := ${NPM_EXECUTABLE_HOME}:${PATH}

test: deps
	@find tests -name '*_test.coffee' | xargs -n 1 -t mocha --compilers coffee:coffee-script 

dev: lib
	@coffee -wc --bare -o lib src/*.coffee

lib: license
	@find src -name '*.coffee' -maxdepth 1 | xargs coffee -c -o lib
	@find src/frontend -name '*.coffee' -maxdepth 1 | xargs coffee -c -o lib/frontend
	@cp -R src/frontend/public lib/frontend

license:
	@bash inject_license.sh
	
clean:
	@rm -fr lib/

publish: lib
	@npm publish
	
deps:

.PHONY: all lib license clean publish

