stackl.exe:
	dune build --profile release .

wasm:
	cd _build/default; wasm_of_ocaml worker_js.bc
	cd _build/default; wasm-opt -O3 --all-features -o worker_js.wasm worker_js.wasm

clean:
	@rm -rf _build
	@rm -rf stackl.zip
	@rm -rf stackl_wasm.zip

zip:
	zip stackl.zip _build/default/*.bc.js index.html styles.css scripts/*.sl

wasm_zip:
	zip stackl_wasm.zip _build/default/*.bc.js _build/default/*.js _build/default/*.wasm index.html styles.css scripts/*.sl
