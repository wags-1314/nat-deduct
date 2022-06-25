# Natural Deduction Proof Checker
An example is included in `input.nat`
## Compilation
Compilation of this project requires `gcc/++`, `flex`, and `bison` installed.
You can build this project by running:
```bash
make
```
## Execution
You can run this project by running:
```bash
./main input.nat
```
## Syntax
```
Theorem.
  <hypothesis> |- <goal>
Proof.
  1: <expr>; <reasoning>.
  <expr>; <reasoning>: 1.
  ...
  <goal>; reasoning: 4, 5.
Qed.
```
Line numbers are optional. If line numbers are typed out, then they have to correspond to the correct line.

`lexer.l` contains all the different symbols used. Keywords used for reasonings have both a short and a long variant for ease of use.
