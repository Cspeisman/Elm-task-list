install_dependencies:
	npm i

build:
	elm make src/Main.elm --output elm.js

app:
	make install_dependencies && make build && npm start

.PHONY: build app install_dependencies
