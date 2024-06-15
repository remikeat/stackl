stackl.exe:
	dune build --profile release $@

clean:
	@rm -rf _build
