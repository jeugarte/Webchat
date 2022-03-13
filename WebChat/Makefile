site_gen := main

all:
	ocamlfind ocamlc bin/main.ml -short-paths -package tyxml -linkpkg -o ${site_gen}
	./${site_gen}

clean:
	rm -f *.cmo *.cmt *.cmi ${site_gen} index.html

.PHONY: play

build: 
	dune build

play:
	OCAMLRUNPARAM=b dune exec bin/main.exe

run:
	OCAMLRUNPARAM=b dune exec ocaml_webapp/bin/main.exe &
