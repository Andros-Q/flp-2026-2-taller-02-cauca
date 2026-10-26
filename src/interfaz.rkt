#lang eopl
;Autores: Andres Felipe Quiceno gil Codigo:2477362
;Yonier Alejandro Vega Rojas Codigo:2477056
;Jhon Fabricio Hurtado Marin Codigo: 2459472
;Juan Esteban Aguirre Castañeda Codigo:2459676

;; Taller 2 — El intérprete de Cauca.
;; El punto de entrada y el REPL. Requiere sintaxis.rkt e interprete.rkt.

(require "sintaxis.rkt")
(require "interprete.rkt")

;; interpretar : string -> valor
;; Analiza el texto de un programa con el parser y evalúa el árbol
;; resultante con evaluar-programa.
(define interpretar
  (lambda (texto)  ;;Le paso como argumento el string que contiene todo el codigo escrito
    (evaluar-programa (parser texto));;ese texto se va al parser que lo transforma en un AST
    ))   ;; y finalmente evaluar programa recorre el AST y arroja el resultado

;; interpretador : -> void
;; REPL de Cauca, que se abre con (interpretador). Se construye con
;; sllgen:make-rep-loop sobre evaluar-programa y el parser de flujo que
;; da sllgen:make-stream-parser.
(define interpretador
  (lambda ()
   ((sllgen:make-rep-loop
      "xxx->Cauca> "
      evaluar-programa
      (sllgen:make-stream-parser especificacion-lexica
       especificacion-gramatical))) 
  ))

(provide (all-defined-out))
