
#lang eopl
;Autores: Andres Felipe Quiceno gil Codigo:2477362
;Yonier Alejandro Vega Rojas Codigo:2477056
;Jhon Fabricio Hurtado Marin Codigo: 2459472
;Juan Esteban Aguirre Castañeda Codigo:2459676

;; Taller 2 — El intérprete de Cauca.
;; Especificación léxica, gramática, scanner y parser.

(define especificacion-lexica
  '(
    ;; Comentarios y espacios
    (comentario ("//" (arbno (not #\newline))) skip)
    (espacio-blanco (whitespace) skip)

    ;; Identificadores
    (identificador
     (letter (arbno (or letter digit "_" "?")))
     symbol)

    ;; Numeros enteros positivos y negativos
    (numero (digit (arbno digit)) number)
    (numero ("-" digit (arbno digit)) number)

    ;; Numeros flotantes positivos y negativos
    (numero (digit (arbno digit) "." digit (arbno digit)) number)
    (numero ("-" digit (arbno digit) "." digit (arbno digit)) number)
    ))

(define especificacion-gramatical
  '(
    ;; Programa
    (programa (expresion) a-program)

    ;; Expresiones basicas
    (expresion (numero) lit-exp)
    (expresion (identificador) var-exp)
    (expresion ("true") true-exp)
    (expresion ("false") false-exp)

    ;; Aplicacion de primitivas
    (expresion
     (primitiva "(" (separated-list expresion ",") ")")
     prim-exp)

    ;; Condicionales
    (expresion
     ("if" expresion "then" expresion "else" expresion "end")
     if-exp)

    ;; Ligadura local
    (expresion
     ("let" (arbno identificador "=" expresion)
      "in" expresion "end")
     let-exp)

    ;; Procedimientos
    (expresion
     ("proc" "(" (separated-list identificador ",") ")"
      expresion "end")
     proc-exp)

    ;; Aplicacion de procedimientos
    (expresion
     ("apply" expresion "(" (separated-list expresion ",") ")")
     app-exp)

    ;; Recursion mediante letrec
    (expresion
     ("letrec"
      (arbno identificador
             "(" (separated-list identificador ",") ")"
             "=" expresion)
      "in" expresion "end")
     letrec-exp)

    ;; Seleccion mediante case
    (expresion
     ("case" expresion
      (arbno "of" numero "=>" expresion)
      "otherwise" "=>" expresion "end")
     case-exp)

    ;; Primitivas aritmeticas
    (primitiva ("+") sum-prim)
    (primitiva ("-") minus-prim)
    (primitiva ("*") mult-prim)
    (primitiva ("/") div-prim)
    (primitiva ("add1") add-prim)
    (primitiva ("sub1") sub-prim)

    ;; Primitivas relacionales
    (primitiva (">") mayor-prim)
    (primitiva (">=") mayorigual-prim)
    (primitiva ("<") menor-prim)
    (primitiva ("<=") menorigual-prim)
    (primitiva ("==") igual-prim)

    ;; Primitivas booleanas originales
    (primitiva ("not") not-prim)
    (primitiva ("and") and-prim)
    (primitiva ("or") or-prim)

    ;; Primitivas adicionales
    (primitiva ("xor") xor-prim)
    (primitiva ("implica") implica-prim)
    (primitiva ("abs") abs-prim)
    (primitiva ("mcd") mcd-prim)
    (primitiva ("mcm") mcm-prim)
    (primitiva ("promedio") promedio-prim)
    (primitiva ("entre") entre-prim)
    ))

;; Generacion de datatypes
(sllgen:make-define-datatypes
 especificacion-lexica
 especificacion-gramatical)

;; Mostrar los datatypes generados
(define mostrar-datatypes
  (lambda ()
    (sllgen:list-define-datatypes
     especificacion-lexica
     especificacion-gramatical)))

;; Scanner: convierte texto en tokens
(define scanner
  (sllgen:make-string-scanner
   especificacion-lexica
   especificacion-gramatical))

;; Parser: convierte texto en un programa
(define parser
  (sllgen:make-string-parser
   especificacion-lexica
   especificacion-gramatical))

(provide (all-defined-out))
