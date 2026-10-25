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
        [(null? args) #t];;Si recorrio toda la lista y en efecto son numeros devuelve true
        [(number? (car args));;Recorre lista si se cumple la condicion de que son numeros
         (exigir-numeros (cdr args) quien)]
        [else (eopl:error 'exigir-numeros ;;Si no se cumple ningun caso siginifica que no todos los argumentos son numeros
           "Todos los argumentos deben ser numeros")]
      )
    ))

;; exigir-enteros : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son enteros; si no, levanta error.
(define exigir-enteros
  (lambda (args quien)
    (cond
        [(null? args) #t];;Si recorrio toda la lista y en efecto son numeros devuelve true
        [(integer? (car args));;Recorre lista si se cumple la condicion de que son enteros(integer)
         (exigir-enteros (cdr args) quien)]
        [else (eopl:error 'exigir-enteros ;;Si no se cumple ningun caso siginifica que no todos los argumentos son enteros
           " Todos los argumentos deben ser enteros")]
      )
    ))

;; exigir-booleanos : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son booleanos; si no, levanta error.
(define exigir-booleanos
  (lambda (args quien)
    (cond
        [(null? args) #t];;Si recorrio toda la lista y en efecto son booleanos devuelve true
        [(boolean? (car args));;Recorre lista si se cumple la condicion de que son booleanos
         (exigir-booleanos (cdr args) quien)]
        [else (eopl:error 'exigir-booleanos ;;Si no se cumple ningun caso siginifica que no todos los argumentos son booleanos
           " Todos los argumentos deben ser booleanos")]
      )
    ))

;; exigir-cantidad : lista x int x symbol -> boolean
;; Retorna #t si llegaron exactamente n argumentos; si no, levanta error.
(define exigir-cantidad
  (lambda (args n quien)
    (cond
        [(= (length args) n) #t];;Valida que en efecto la cantidad de argumentos sea igual al n establecido
        [else (eopl:error 'exigir-cantidad
                    "Se esperaban ~s argumentos, pero llegaron ~s"
                    n
                    (length args))]
      )
    ))

;; exigir-minimo : lista x int x symbol -> boolean
;; Retorna #t si llegaron al menos n argumentos; si no, levanta error.
(define exigir-minimo
  (lambda (args n quien)
    (cond
        [(>= (length args) n) #t];;Valida que en efecto la cantidad de argumentos sea maypr o igual al n establecido
        [else (eopl:error 'exigir-minimo
                    "Se esperaban al menos ~s argumentos, pero llegaron ~s"
                    n
                    (length args))]
      )
    ))

;; operar-primitiva : Lista(Valor) x Operación x ValorIdentidad -> Número
;; Fold-right auxiliar para evaluar primitivas y poder lograr que funcione la operacion.
(define operar-primitiva
  (lambda (vals operador term)
    (cond    ;;Si la lista de valores es vacia devuelve el termino. puede ser por ej: 0
      [(null? vals) term]
      [else(operador (car vals) ;;operador valor ;se ejecuta recursion para sumar o multiplicar valores del resto de lista dependiendo del caso
            (operar-primitiva (cdr vals)
                              operador term))]
      )
    ))


;; evaluar-primitiva : primitiva x lista de valores -> valor
;; Verifica la cantidad y el tipo de los argumentos y aplica la
;; primitiva. Se resuelve con cases sobre el datatype primitiva.
(define evaluar-primitiva  ;;Re ajustar validaciones
                         ;;Y crear funciones aux para validar
  (lambda (prim args)
    (cases primitiva prim
      (sum-prim ()
         (exigir-minimo args 1 '+)
         (exigir-numeros args '+)      
         (operar-primitiva args + 0)
       )
          

      (minus-prim ()
        (exigir-minimo args 1 '-)
        (exigir-numeros args '-)         
        (- (car args)
            (operar-primitiva (cdr args) + 0))
       )
      
      (mult-prim ()
         (exigir-minimo args 1 '*)
         (exigir-numeros args '*)       
        (* (car args)
         (operar-primitiva (cdr args) * 1))
       )  
      
      (div-prim ()
          (exigir-minimo args 1 '/)
          (exigir-numeros args '/)      
        (/ (car args)
                   (operar-primitiva (cdr args) * 1))
       )   
      
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
          (not (car args) ))

      (and-prim ()
          (exigir-cantidad args 2 'and)
          (exigir-booleanos args 'and)
         (and (car args) (cadr args)))
      
      (or-prim ()
           (exigir-cantidad args 2 'or)
           (exigir-booleanos args 'or)    
          (or (car args) (cadr args)))
      )))

   
(provide (all-defined-out))
