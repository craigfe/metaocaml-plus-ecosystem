# MetaOCaml + ecosystem

An experiment in getting MetaOCaml to work with modern OCaml tooling (`dune`,
`ocamlformat`, GitHub actions etc.). Requires `ocaml-variants.4.11.1+BER`, and a
[patched OCamlformat][ocamlformat-metaocaml].

Most of the code is due to Oleg's [MetaOCaml tutorial][metaocaml-tutorial].

**TODO**:

- fix native code executables with more than one file (inscrutable `Unbound module: Codelib` error);
- fix Dune's generation of `.merlin` files (needs at least `EXT meta`);
- test with [Alcotest][alcotest];
- benchmark with [Bechamel][bechamel];
- lift code with [Repr][repr].

[ocamlformat-metaocaml]: https://github.com/CraigFe/ocamlformat/tree/metaocaml
[metaocaml-tutorial]: http://okmij.org/ftp/meta-programming/tutorial
[alcotest]: https://github.com/mirage/alcotest
[bechamel]: https://github.com/dinosaure/bechamel
[repr]: https://github.com/mirage/repr
