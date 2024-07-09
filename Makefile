stackl.exe:
	dune build --profile release .

clean:
	@rm -rf _build
	@rm -rf stackl.zip

zip:
	zip stackl.zip _build/default/stackl_js.bc.js index.html styles.css scripts/*.sl
