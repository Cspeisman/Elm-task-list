build:
	elm make src/Main.elm --output elm.js

app:
	make build && npm start

.PHONY: build app
