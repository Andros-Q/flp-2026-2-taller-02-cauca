
#lang eopl
;Autores: Andres Felipe Quiceno gil Codigo:2477362
;Yonier Alejandro Vega Rojas Codigo:2477056
;Jhon Fabricio Hurtado Marin Codigo: 2459472
;Juan Esteban Aguirre Castañeda Codigo:2459676

;; Taller 2 — El intérprete de Cauca.
;; Las primitivas del lenguaje y las verificaciones de tipo y de
;; cantidad de argumentos que cada una exige. Requiere sintaxis.rkt.

(require "sintaxis.rkt")

;; exigir-numeros : lista x symbol -> boolean
;; Verifica que todos los argumentos sean numeros.
(define exigir-numeros
  (lambda (args quien)
    (cond
      [(null? args) #t]
      [(number? (car args))
       (exigir-numeros (cdr args) quien)]
      [else
       (eopl:error 'exigir-numeros
                   "Todos los argumentos deben ser numeros en ~s"
                   quien)])))

;; exigir-enteros : lista x symbol -> boolean
;; Verifica que todos los argumentos sean enteros.
(define exigir-enteros
  (lambda (args quien)
    (cond
        [(null? args) #t];;Si recorrio toda la lista y en efecto son numeros devuelve true
        [(integer? (car args));;Recorre lista si se cumple la condicion de que son enteros(integer)
         (exigir-enteros (cdr args) quien)]
        [else (eopl:error quien ;;Si no se cumple ningun caso siginifica que no todos los argumentos son enteros
           " Todos los argumentos deben ser enteros")]
      )
    ))

;; exigir-booleanos : lista x symbol -> boolean
;; Verifica que todos los argumentos sean booleanos.
(define exigir-booleanos
  (lambda (args quien)
    (cond
        [(null? args) #t];;Si recorrio toda la lista y en efecto son booleanos devuelve true
        [(boolean? (car args));;Recorre lista si se cumple la condicion de que son booleanos
         (exigir-booleanos (cdr args) quien)]
        [else (eopl:error quien ;;Si no se cumple ningun caso siginifica que no todos los argumentos son booleanos
           " Todos los argumentos deben ser booleanos")]
      )
    ))

;; exigir-cantidad : lista x int x symbol -> boolean
;; Verifica que lleguen exactamente n argumentos.
(define exigir-cantidad
  (lambda (args n quien)
    (cond
        [(= (length args) n) #t];;Valida que en efecto la cantidad de argumentos sea igual al n establecido
        [else (eopl:error quien
                    "Se esperaban ~s argumentos, pero llegaron ~s"
                    n
                    (length args))]
      )
    ))

;; exigir-minimo : lista x int x symbol -> boolean
;; Verifica que lleguen al menos n argumentos.
(define exigir-minimo
  (lambda (args n quien)
    (cond
        [(>= (length args) n) #t];;Valida que en efecto la cantidad de argumentos sea maypr o igual al n establecido
        [else (eopl:error quien
                    "Se esperaban al menos ~s argumentos, pero llegaron ~s"
                    n
                    (length args))]
      )
    ))

;; operar-primitiva : Lista(Valor) x Operación x ValorIdentidad -> Número
;; Fold-right auxiliar para evaluar primitivas y poder lograr que funcione la operacion.
(define operar-primitiva
  (lambda (vals operador term)
    (cond
      [(null? vals) term]
      [else
       (operador
        (car vals)
        (operar-primitiva (cdr vals) operador term))])))

;; mcd-dos : entero x entero -> entero
;; Calcula el maximo comun divisor de dos enteros.
(define mcd-dos
  (lambda (a b)
    (if (= b 0)
        (abs a)
        (mcd-dos b (remainder a b)))))

;; mcm-dos : entero x entero -> entero
;; Calcula el minimo comun multiplo de dos enteros.
(define mcm-dos
  (lambda (a b)
    (if (or (= a 0) (= b 0))
        0
        (abs (/ (* a b) (mcd-dos a b))))))

;; mcd-lista : lista de enteros -> entero
;; Calcula el MCD acumulado de una lista.
(define mcd-lista
  (lambda (args)
    (if (null? (cdr args))
        (abs (car args))
        (mcd-lista
         (cons (mcd-dos (car args) (cadr args))
               (cddr args))))))

;; mcm-lista : lista de enteros -> entero
;; Calcula el MCM acumulado de una lista.
(define mcm-lista
  (lambda (args)
    (if (null? (cdr args))
        (abs (car args))
        (mcm-lista
         (cons (mcm-dos (car args) (cadr args))
               (cddr args))))))

;; evaluar-primitiva : primitiva x lista de valores -> valor
;; Verifica los argumentos y evalua la primitiva correspondiente.
(define evaluar-primitiva
  (lambda (prim args)
    (cases primitiva prim

      ;; Primitivas aritmeticas

      (sum-prim ()
        (exigir-minimo args 1 '+)
        (exigir-numeros args '+)
        (operar-primitiva args + 0))

      (minus-prim ()
        (exigir-minimo args 1 '-)
        (exigir-numeros args '-)
        (- (car args)
           (operar-primitiva (cdr args) + 0)))

      (mult-prim ()
        (exigir-minimo args 1 '*)
        (exigir-numeros args '*)
        (operar-primitiva args * 1))

      (div-prim ()
        (exigir-minimo args 1 '/)
        (exigir-numeros args '/)
        (if (null? (cdr args))
            (/ 1 (car args))
            (let dividir
              ([restantes (cdr args)]
               [resultado (car args)])
              (if (null? restantes)
                  resultado
                  (dividir
                   (cdr restantes)
                   (/ resultado (car restantes)))))))

      (add-prim ()
        (exigir-cantidad args 1 'add1)
        (exigir-numeros args 'add1)
        (+ (car args) 1))

      (sub-prim ()
        (exigir-cantidad args 1 'sub1)
        (exigir-numeros args 'sub1)
        (- (car args) 1))

      ;; Primitivas relacionales

      (mayor-prim ()
        (exigir-cantidad args 2 '>)
        (exigir-numeros args '>)
        (> (car args) (cadr args)))

      (mayorigual-prim ()
        (exigir-cantidad args 2 '>=)
        (exigir-numeros args '>=)
        (>= (car args) (cadr args)))

      (menor-prim ()
        (exigir-cantidad args 2 '<)
        (exigir-numeros args '<)
        (< (car args) (cadr args)))

      (menorigual-prim ()
        (exigir-cantidad args 2 '<=)
        (exigir-numeros args '<=)
        (<= (car args) (cadr args)))

      (igual-prim ()
        (exigir-cantidad args 2 '==)
        (exigir-numeros args '==)
        (equal? (car args) (cadr args)))

      ;; Primitivas booleanas originales

      (not-prim ()
        (exigir-cantidad args 1 'not)
        (exigir-booleanos args 'not)
        (not (car args)))

      (and-prim ()
        (exigir-cantidad args 2 'and)
        (exigir-booleanos args 'and)
        (and (car args) (cadr args)))

      (or-prim ()
        (exigir-cantidad args 2 'or)
        (exigir-booleanos args 'or)
        (or (car args) (cadr args)))

      ;; XOR: disyuncion exclusiva

      (xor-prim ()
        (exigir-cantidad args 2 'xor)
        (exigir-booleanos args 'xor)
        (not (equal? (car args) (cadr args))))

      ;; Implicacion logica

      (implica-prim ()
        (exigir-cantidad args 2 'implica)
        (exigir-booleanos args 'implica)
        (or (not (car args)) (cadr args)))

      ;; Valor absoluto

      (abs-prim ()
        (exigir-cantidad args 1 'abs)
        (exigir-numeros args 'abs)
        (abs (car args)))

      ;; Maximo comun divisor

      (mcd-prim ()
        (exigir-minimo args 2 'mcd)
        (exigir-enteros args 'mcd)
        (mcd-lista args))

      ;; Minimo comun multiplo

      (mcm-prim ()
        (exigir-minimo args 2 'mcm)
        (exigir-enteros args 'mcm)
        (mcm-lista args))

      ;; Promedio aritmetico

      (promedio-prim ()
        (exigir-minimo args 1 'promedio)
        (exigir-numeros args 'promedio)
        (/ (operar-primitiva args + 0) (length args)))

      ;; Verifica si el primer argumento esta entre los limites.
      ;; Los limites se aceptan en cualquier orden, inclusive.
      (entre-prim ()
        (exigir-cantidad args 3 'entre)
        (exigir-numeros args 'entre)
        (let ([valor (car args)]
              [limite1 (cadr args)]
              [limite2 (caddr args)])
          (and (>= valor (min limite1 limite2))
               (<= valor (max limite1 limite2))))))))

(provide (all-defined-out))
