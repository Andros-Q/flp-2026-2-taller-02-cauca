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
    (comentario("//"(arbno (not #\newline)))skip);;Comentario
    (espacio-blanco(whitespace)skip);;Espacios en Blanco
    (identificador (letter(arbno(or letter digit "_" "?"))) symbol);;Identificadores que comienzan con una letra seguido de cero o mas digitos,letras,guiones bajos o signos de interrogacion
    (numero (digit(arbno digit))number);;Numeros Enteros positivo
    (numero ("-" digit(arbno digit))number);;Numeros Enteros negativos
    (numero (digit(arbno digit) "." digit(arbno digit))number);;Numero Flotante positivo
    (numero ("-" digit(arbno digit) "." digit(arbno digit)) number);;Numero Flotante negativo
    
    ))

(define especificacion-gramatical
  '(
    (programa (expresion) a-program);;Datatype base del programa 
    ;;Expresiones de la sintaxis de nuestro lenguaje
    (expresion (numero) lit-exp)
    (expresion (identificador) var-exp)
    (expresion ("true") true-exp)
    (expresion ("false") false-exp)
    (expresion (primitiva "("
      (separated-list expresion ",") ")") prim-exp)
    (expresion ("if" expresion "then" expresion "else"
                     expresion "end")if-exp)
    (expresion ("let" (arbno identificador "=" expresion)
                "in" expresion "end") let-exp)
    ;;Colocando las primitivas
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
    (primitiva ("not") not-prim)
    (primitiva ("and") and-prim)
    (primitiva ("or") or-prim)
    ;;Parte 2: primitivas nuevas
    (primitiva ("abs") abs-prim);;Valor absoluto, unaria sobre numeros
    (primitiva ("mcd") mcd-prim);;Maximo comun divisor, n-aria con n>=2 sobre enteros
    (primitiva ("mcm") mcm-prim);;Minimo comun multiplo, n-aria con n>=2 sobre enteros
    (primitiva ("promedio") promedio-prim);;Media aritmetica, n-aria con n>=1 sobre numeros
    (primitiva ("xor") xor-prim);;O exclusivo, binaria sobre booleanos
    (primitiva ("implica") implica-prim);;Implicacion logica, binaria sobre booleanos
    (primitiva ("entre") entre-prim);;Pertenencia a un intervalo cerrado, ternaria sobre numeros
    ))

(sllgen:make-define-datatypes especificacion-lexica especificacion-gramatical)

;; mostrar-datatypes : -> void
;; Lista en pantalla los datatypes que SLLGEN genera a partir de la
;; gramática. Sirve para revisar los nombres de los constructores.
(define mostrar-datatypes
  (lambda ()
    (sllgen:list-define-datatypes especificacion-lexica especificacion-gramatical)))

;;Para probar
 ;;(scanner "if >(x, 2) then 2 else 3 end")
  ;;(parser "// comentario +(2.5, -1)")

;; scanner : string -> lista de tokens
;; Convierte el texto de un programa en la lista de sus tokens.
(define scanner
    (sllgen:make-string-scanner  especificacion-lexica
        especificacion-gramatical))

;;Prueba con "+(3,5)"
;; parser : string -> programa
;; Convierte el texto de un programa en su árbol de sintaxis abstracta.
(define parser
   (sllgen:make-string-parser  especificacion-lexica
        especificacion-gramatical) )

(provide (all-defined-out))
