build: 
	dune build
	npm run --prefix frontend build

play:
	OCAMLRUNPARAM=b dune exec bin/main.exe

run:
	pkill -f _build/default/ocaml_webapp/bin/main.exe || true
	OCAMLRUNPARAM=b dune exec ocaml_webapp/bin/main.exe &

serve:
	pkill -f _build/default/ocaml_webapp/bin/main.exe || true
	OCAMLRUNPARAM=b dune exec ocaml_webapp/bin/main.exe &
	npm run --prefix frontend serve