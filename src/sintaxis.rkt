#lang eopl
;Autores: Andres Felipe Quiceno gil Codigo:2477362
;Yonier Alejandro Vega Rojas Codigo:2477056
;Jhon Fabricio Hurtado Marin Codigo: 2459472
;Juan Esteban Aguirre Castañeda Codigo:2459676

;; Taller 2 — El intérprete de Cauca.
;; Especificación léxica, especificación gramatical, scanner y parser.
;; Este módulo no requiere ningún otro.
;;
;; Lo que se escribe aquí:
;;
;;   especificacion-lexica      comentarios que empiezan con //, espacios
;;                              en blanco, números enteros y flotantes con
;;                              signo, e identificadores que empiezan por
;;                              letra y siguen con letras, dígitos, guion
;;                              bajo o signo de interrogación
;;   especificacion-gramatical  las producciones de <programa>,
;;                              <expresion> y <primitiva>, con los nombres
;;                              de constructor que indican los recuadros
;;                              del enunciado
;;   scanner : string -> lista de tokens   se construye con
;;                                         sllgen:make-string-scanner
;;   parser  : string -> programa          se construye con
;;                                         sllgen:make-string-parser
;;
;; La llamada a sllgen:make-define-datatypes genera los datatypes
;; programa, expresion y primitiva a partir de la gramática, con sus
;; constructores y sus predicados. Mientras la gramática esté vacía no
;; genera ninguno.


(define especificacion-lexica
  '(
    (comentario ("//" (arbno (not #\newline))) skip) ;; Comentario
    (espacio-blanco (whitespace) skip) ;; Espacios en blanco

    ;; Identificadores que comienzan con una letra, seguidos de cero
    ;; o más letras, dígitos, guiones bajos o signos de interrogación.
    (identificador
     (letter (arbno (or letter digit "_" "?")))
     symbol)

    (numero (digit (arbno digit)) number) ;; Números enteros positivos
    (numero ("-" digit (arbno digit)) number) ;; Números enteros negativos

    ;; Números flotantes positivos y negativos
    (numero (digit (arbno digit) "." digit (arbno digit)) number)
    (numero ("-" digit (arbno digit) "." digit (arbno digit)) number)
    ))


(define especificacion-gramatical
  '(
    ;; Datatype base del programa
    (programa (expresion) a-program)

    ;; Expresiones de la sintaxis de nuestro lenguaje
    (expresion (numero) lit-exp)
    (expresion (identificador) var-exp)
    (expresion ("true") true-exp)
    (expresion ("false") false-exp)

    ;; Aplicación de primitivas
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

    ;; Procedimientos y aplicación de procedimientos
    (expresion
     ("proc" "(" (separated-list identificador ",") ")"
      expresion "end")
     proc-exp)

    (expresion
     ("apply" expresion "(" (separated-list expresion ",") ")")
     apply-exp)

    ;; Recursión mediante letrec
    (expresion
     ("letrec"
      (arbno identificador
             "(" (separated-list identificador ",") ")"
             "=" expresion)
      "in" expresion "end")
     letrec-exp)

    ;; Selección de una expresión mediante case.
    ;; Cada alternativa contiene un número y una expresión.
    ;; La alternativa otherwise es obligatoria.
    (expresion
     ("case" expresion
      (arbno "of" numero "=>" expresion)
      "otherwise" "=>" expresion "end")
     case-exp)


    ;; Primitivas aritméticas y relacionales
    (primitiva ("+") sum-prim)
    (primitiva ("-") minus-prim)
    (primitiva ("*") mult-prim)
    (primitiva ("/") div-prim)
    (primitiva ("add1") add-prim)
    (primitiva ("sub1") sub-prim)

    (primitiva (">") mayor-prim)
    (primitiva (">=") mayorigual-prim)
    (primitiva ("<") menor-prim)
    (primitiva ("<=") menorigual-prim)
    (primitiva ("==") igual-prim)

    ;; Primitivas booleanas
    (primitiva ("not") not-prim)
    (primitiva ("and") and-prim)
    (primitiva ("or") or-prim)
    (primitiva ("xor") xor-prim)
    (primitiva ("implica") implica-prim)

    ;; Primitivas numéricas nuevas
    (primitiva ("abs") abs-prim)
    (primitiva ("mcd") mcd-prim)
    (primitiva ("mcm") mcm-prim)
    (primitiva ("promedio") promedio-prim)
    (primitiva ("entre") entre-prim)
    ))


;; Genera los datatypes programa, expresion y primitiva
;; a partir de la especificación gramatical.
(sllgen:make-define-datatypes
 especificacion-lexica
 especificacion-gramatical)


;; mostrar-datatypes : -> void
;; Lista en pantalla los datatypes que SLLGEN genera a partir de la
;; gramática. Sirve para revisar los nombres de los constructores.
(define mostrar-datatypes
  (lambda ()
    (sllgen:list-define-datatypes
     especificacion-lexica
     especificacion-gramatical)))


;; Para probar:
;; (scanner "if >(x, 2) then 2 else 3 end")
;; (parser "// comentario +(2.5, -1)")


;; scanner : string -> lista de tokens
;; Convierte el texto de un programa en la lista de sus tokens.
(define scanner
  (sllgen:make-string-scanner
   especificacion-lexica
   especificacion-gramatical))


;; parser : string -> programa
;; Convierte el texto de un programa en su árbol de sintaxis abstracta.
(define parser
  (sllgen:make-string-parser
   especificacion-lexica
   especificacion-gramatical))


(provide (all-defined-out))
