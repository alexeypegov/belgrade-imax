default = live

.PHONY : live build icons

live:
	elm-live src/Main.elm --dir=./dist -- --output=./dist/elm.js

build:
	elm make src/Main.elm --optimize --output=./dist/elm.js
	esbuild ./dist/elm.js --minify --outfile=./docs/elm.min.js

icons:
	./icons.sh
