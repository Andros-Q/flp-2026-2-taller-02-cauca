#lang eopl
;Autores: Andres Felipe Quiceno gil Codigo:2477362
;Yonier Alejandro Vega Rojas Codigo:2477056
;Jhon Fabricio Hurtado Marin Codigo: 2459472
;Juan Esteban Aguirre Castañeda Codigo:2459676

;; Taller 2 — El intérprete de Cauca.
;; Fachada: reúne los seis módulos de src/ y reexporta todo lo que
;; definen, de modo que quien la requiera vea todos los nombres sin
;; requerir los módulos uno por uno.
;;
;;   src/sintaxis.rkt    especificación léxica y gramatical, scanner, parser
;;   src/valores.rkt     el valor procedimiento
;;   src/ambiente.rkt    el TAD ambiente y el ambiente inicial
;;   src/primitivas.rkt  las primitivas y sus verificaciones
;;   src/interprete.rkt  la evaluación y la aplicación de procedimientos
;;   src/interfaz.rkt    el punto de entrada y el REPL
;;
;; Los require van en un solo sentido. Racket no carga dos módulos que se
;; requieran entre sí.

(require "src/sintaxis.rkt")
(require "src/valores.rkt")
(require "src/ambiente.rkt")
(require "src/primitivas.rkt")
(require "src/interprete.rkt")
(require "src/interfaz.rkt")

(provide (all-from-out "src/sintaxis.rkt"
                       "src/valores.rkt"
                       "src/ambiente.rkt"
                       "src/primitivas.rkt"
                       "src/interprete.rkt"
                       "src/interfaz.rkt"))

;;; ==========================================================
;;; Ejemplos
;;; ==========================================================

#|
  Aquí van los ejemplos que pide el enunciado: 5 del scanner, 5 del
  parser y los de ejecución de cada parte, con el resultado de cada uno
  escrito al lado. Las pruebas con rackunit viven en pruebas-cauca.rkt.

  Scanner
    (scanner "...")   =>

  Parser
    (parser "...")    =>

  Ejecución del lenguaje base
    (interpretar "...")   =>

  Primitivas nuevas
    (interpretar "...")   =>

    Ambiente inicial: n = 10, m = 3, p = 7, q = 2, r = 5.

    abs
      (interpretar "abs(-7)")                  => 7
      (interpretar "abs(7)")                   => 7
      (interpretar "abs(-3.5)")                => 3.5
      (interpretar "abs(true)")                => error: abs exige un numero

    mcd
      (interpretar "mcd(12, 18)")              => 6
      (interpretar "mcd(7, 13)")               => 1
      (interpretar "mcd(12, 18, 24)")          => 6
      (interpretar "mcd(1.5, 2)")              => error: mcd exige enteros

    mcm
      (interpretar "mcm(4, 6)")                => 12
      (interpretar "mcm(3, 5)")                => 15
      (interpretar "mcm(2, 3, 4)")             => 12
      (interpretar "mcm(2.5, 5)")              => error: mcm exige enteros

    promedio
      (interpretar "promedio(1, 2, 3, 4)")     => 5/2
      (interpretar "promedio(10)")             => 10
      (interpretar "promedio(n, m)")           => 13/2
      (interpretar "promedio(true, 2)")        => error: promedio exige numeros

    xor
      (interpretar "xor(true, false)")         => #t
      (interpretar "xor(true, true)")          => #f
      (interpretar "xor(false, false)")        => #f
      (interpretar "xor(1, true)")             => error: xor exige booleanos

    implica
      (interpretar "implica(true, false)")     => #f
      (interpretar "implica(false, false)")    => #t
      (interpretar "implica(true, true)")      => #t
      (interpretar "implica(true, 1)")         => error: implica exige booleanos

    entre
      (interpretar "entre(5, 1, 10)")          => #t
      (interpretar "entre(1, 1, 10)")          => #t
      (interpretar "entre(11, 1, 10)")         => #f
      (interpretar "entre(1, 2)")              => error: entre exige tres argumentos

  Procedimientos
    (interpretar "...")   =>

  Recursión y case
    (interpretar "...")   =>
|#
