# Makefile for the MetaOCaml tutorial

OCAMLC=metaocamlc
OCAMLOPT=ocamlopt
MOCAMLOPT=metaocamlopt
MOCAML=metaocaml

.SUFFIXES: .ml .mli .cmo .cmi .cmx .tex .pdf

.mli.cmi:
	$(OCAMLC) -c $<
.ml.cmo:
	$(OCAMLC) -c $<
.ml.cmx:
	$(OCAMLOPT) -c $<

clean::
	rm -f *.cm[ixo] *.[oa] *~ a.out

# All tests
tests: power_rts powerf_rts filter complex mvmult_full run_image

# Power example
power_rts: power_rts.ml square.cmx
	$(MOCAMLOPT) -o $@ square.cmx power_rts.ml
	./$@
	rm -f power_rts

clean:: 
	rm -f power_rts

square.cmo: square.ml
square.cmx: square.ml

powerf_rts: powerf_rts.cmo
	$(OCAMLC) -o $@ $@.cmo
	./powerf_rts

clean:: 
	rm -f powerf_rts

pw7.cmo: pw7.ml

clean:: 
	rm -f pw7.ml

filter:	filter.cmo
	$(OCAMLC) -o $@ filter.cmo 
	./$@
	rm -f $@

# Complex vectors
cmplx.cmi: cmplx.mli

# Shonan challenges
complex.cmo: complex.ml ring.cmo vector.cmo cmplx.cmi

complex: complex.cmo ring.cmo vector.cmo
	$(OCAMLC) -o $@ ring.cmo vector.cmo complex.cmo 
	./$@
	rm -f $@

clean:: 
	rm -f complex

mvmult_full.cmo: mvmult_full.ml ring.cmo vector.cmo lift.cmo

mvmult_full: mvmult_full.cmo lift.cmo
	$(OCAMLC) -o $@ ring.cmo vector.cmo lift.cmo mvmult_full.cmo 
	./$@
	rm -f $@

# DSL for image processing
.PHONY: image

image: grayimg.cmi grayimg.cmo \
	imgdsl.cmi img_ex.cmo \
	img_interp.cmo img_comp.cmo \
	grayimg.cmx

run_image: image
	echo -n '#use "img_trans.ml";;' | $(MOCAML) 

clean:: 
	rm -f run_image

grayimg.cmo: grayimg.cmi

