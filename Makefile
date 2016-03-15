build:
	elm make src/Main.elm --output elm.js

app:
	npm start

.PHONY: build app
