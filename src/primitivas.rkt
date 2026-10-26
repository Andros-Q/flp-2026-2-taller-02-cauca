#lang eopl
;Autores: Andres Felipe Quiceno gil Codigo:2477362
;Yonier Alejandro Vega Rojas Codigo:2477056
;Jhon Fabricio Hurtado Marin Codigo: 2459472
;Juan Esteban Aguirre Castañeda Codigo:2459676

;; Taller 2 — El intérprete de Cauca.
;; Las primitivas del lenguaje y las verificaciones de tipo y de
;; cantidad de argumentos que cada una exige. Requiere sintaxis.rkt.
;;
;; Aridades: +, -, *, / son n-arias; add1, sub1, not y abs son unarias;
;; las relacionales, and, or, xor e implica son binarias; entre es
;; ternaria; mcd y mcm son n-arias sobre enteros con al menos dos
;; argumentos; promedio es n-aria sobre números con al menos uno.

(require "sintaxis.rkt")

;; exigir-numeros : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son números; si no, levanta
;; eopl:error a nombre de quien hizo la verificación.
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
;; Retorna #t si todos los argumentos son enteros; si no, levanta error.
(define exigir-enteros
  (lambda (args quien)
    (cond
      [(null? args) #t]
      [(integer? (car args))
       (exigir-enteros (cdr args) quien)]
      [else
       (eopl:error 'exigir-enteros
                   "Todos los argumentos deben ser enteros en ~s"
                   quien)])))

;; exigir-booleanos : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son booleanos; si no, levanta error.
(define exigir-booleanos
  (lambda (args quien)
    (cond
      [(null? args) #t]
      [(boolean? (car args))
       (exigir-booleanos (cdr args) quien)]
      [else
       (eopl:error 'exigir-booleanos
                   "Todos los argumentos deben ser booleanos en ~s"
                   quien)])))

;; exigir-cantidad : lista x int x symbol -> boolean
;; Retorna #t si llegaron exactamente n argumentos; si no, levanta error.
(define exigir-cantidad
  (lambda (args n quien)
    (cond
      [(= (length args) n) #t]
      [else
       (eopl:error 'exigir-cantidad
                   "Se esperaban ~s argumentos en ~s, pero llegaron ~s"
                   n
                   quien
                   (length args))])))

;; exigir-minimo : lista x int x symbol -> boolean
;; Retorna #t si llegaron al menos n argumentos; si no, levanta error.
(define exigir-minimo
  (lambda (args n quien)
    (cond
      [(>= (length args) n) #t]
      [else
       (eopl:error 'exigir-minimo
                   "Se esperaban al menos ~s argumentos en ~s, pero llegaron ~s"
                   n
                   quien
                   (length args))])))

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
;; Calcula el máximo común divisor de dos enteros no negativos.
(define mcd-dos
  (lambda (a b)
    (if (= b 0)
        (abs a)
        (mcd-dos b (remainder a b)))))

;; mcm-dos : entero x entero -> entero
;; Calcula el mínimo común múltiplo de dos enteros.
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
;; Verifica la cantidad y el tipo de los argumentos y aplica la
;; primitiva. Se resuelve con cases sobre el datatype primitiva.
(define evaluar-primitiva
  (lambda (prim args)
    (cases primitiva prim

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

      ;; Primitiva XOR: verdadero si exactamente uno es verdadero.
      (xor-prim ()
        (exigir-cantidad args 2 'xor)
        (exigir-booleanos args 'xor)
        (not (equal? (car args) (cadr args))))

      ;; Implicación lógica: solo es falsa cuando p es verdadero y q falso.
      (implica-prim ()
        (exigir-cantidad args 2 'implica)
        (exigir-booleanos args 'implica)
        (or (not (car args)) (cadr args)))

      ;; Valor absoluto.
      (abs-prim ()
        (exigir-cantidad args 1 'abs)
        (exigir-numeros args 'abs)
        (abs (car args)))

      ;; Máximo común divisor de dos o más enteros.
      (mcd-prim ()
        (exigir-minimo args 2 'mcd)
        (exigir-enteros args 'mcd)
        (mcd-lista args))

      ;; Mínimo común múltiplo de dos o más enteros.
      (mcm-prim ()
        (exigir-minimo args 2 'mcm)
        (exigir-enteros args 'mcm)
        (mcm-lista args))

      ;; Promedio aritmético de uno o más números.
      (promedio-prim ()
        (exigir-minimo args 1 'promedio)
        (exigir-numeros args 'promedio)
        (/ (operar-primitiva args + 0)
           (length args)))

      ;; Comprueba si n está entre los límites, ambos incluidos.
      ;; También acepta los límites en orden inverso.
      (entre-prim ()
        (exigir-cantidad args 3 'entre)
        (exigir-numeros args 'entre)
        (let ([n (car args)]
              [a (cadr args)]
              [b (caddr args)])
          (and (<= (min a b) n)
               (<= n (max a b))))))))


(provide (all-defined-out))
