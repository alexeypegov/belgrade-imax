RESVG = resvg --monospace-family "Courier New"
OUT   = docs

.PHONY : all build icons static dev clear

# Release site into docs/: optimized Elm, icons and public files.
all: build icons static

# Optimized, minified Elm bundle only.
build:
	mkdir -p $(OUT)
	elm make src/Main.elm --optimize --output=elm-stuff/elm.js
	esbuild elm-stuff/elm.js --minify --outfile=$(OUT)/elm.js

# Home-screen PNGs from icon.svg; "monospace" maps to Courier New, like Safari. Requires resvg.
icons:
	mkdir -p $(OUT)
	$(RESVG) -w 180 -h 180 icon.svg $(OUT)/apple-touch-icon.png
	$(RESVG) -w 192 -h 192 icon.svg $(OUT)/icon-192.png
	$(RESVG) -w 512 -h 512 icon.svg $(OUT)/icon-512.png

static:
	mkdir -p $(OUT)
	cp -R public/. $(OUT)/

# Live-reloading dev server on build/ with unoptimized Elm; docs/ is left alone.
dev: OUT = build
dev: icons static
	elm-live src/Main.elm --dir=$(OUT) -- --output=$(OUT)/elm.js

clear:
	rm -rf docs build
