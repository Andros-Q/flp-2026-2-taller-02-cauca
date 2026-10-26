
#lang eopl
;Autores: Andres Felipe Quiceno gil Codigo:2477362
;Yonier Alejandro Vega Rojas Codigo:2477056
;Jhon Fabricio Hurtado Marin Codigo: 2459472
;Juan Esteban Aguirre Castañeda Codigo:2459676

;; Taller 2 — El intérprete de Cauca.
;; El recorrido de la sintaxis abstracta y la aplicación de
;; procedimientos. Requiere sintaxis.rkt, valores.rkt, ambiente.rkt y
;; primitivas.rkt.
;;
;; apply-procedure vive aquí y no en valores.rkt porque llama a
;; evaluar-expresion.

(require "sintaxis.rkt")
(require "valores.rkt")
(require "ambiente.rkt")
(require "primitivas.rkt")

;; apply-procedure : procval x lista de valores -> valor
;; Verifica que la cantidad de argumentos coincida con la de parámetros
;; y evalúa el cuerpo en el ambiente de la clausura extendido con las
;; ligaduras de los parámetros, no en el ambiente de la llamada.
(define apply-procedure
  (lambda (proc args)
    (cases procval proc
      (cerradura (ids body env-claustura)
        (if (= (length ids) (length args))
            (evaluar-expresion
             body
             (ambiente-extendido ids args env-claustura))
            (eopl:error
             'apply-procedure
             "Cantidad incorrecta de argumentos. Esperados: ~s; recibidos: ~s"
             (length ids)
             (length args)))))
    ))

;; evaluar-programa : programa -> valor
;; Punto de entrada: evalúa la expresión del programa en el ambiente
;; inicial.
(define evaluar-programa
  (lambda (pgm)
    (cases programa pgm ;;extrae la expresion que se a ingresado
      (a-program (expresion);;Se evalua esa expresion con el ambiente inicial
        (evaluar-expresion expresion (ambiente-inicial))))
    ));;se crea el ambiente inicial con sus variables ya asignadas

;; evaluar-rands : lista de expresiones x ambiente -> lista de valores
;; Evalúa las expresiones de izquierda a derecha en el mismo ambiente.
(define evaluar-rands
  (lambda (rands env)
    (if (null? rands);;Comprobar si la lista de expresiones esta vacia
        '() ;;devuelve lista vacia
        (cons
         (evaluar-expresion (car rands) env);;evaluar-expresion obtiene el valor 
         (evaluar-rands (cdr rands) env)));;y se agrega ala lista de resultados y se realiza el recorrido de las expresiones del rand
    ))
;; evaluar-caso : valor x lista de numeros x lista de expresiones
;;                x expresion x ambiente -> valor
;; Busca la primera alternativa de case que coincida con el valor.
;; Si ninguna coincide, evalúa la alternativa otherwise.
(define evaluar-caso
  (lambda (valor valores cuerpos alternativa-por-defecto env)
    (cond
      [(null? valores)
       (evaluar-expresion alternativa-por-defecto env)]
      [(equal? valor (car valores))
       (evaluar-expresion (car cuerpos) env)]
      [else
       (evaluar-caso
        valor
        (cdr valores)
        (cdr cuerpos)
        alternativa-por-defecto
        env)])))

;; evaluar-expresion : expresion x ambiente -> valor
;; Recorre el árbol de sintaxis abstracta con cases y evalúa cada
;; variante según la semántica del enunciado. El if verifica que la
;; condición sea booleana; el case evalúa su expresión de control una
;; sola vez.

(define evaluar-expresion
  (lambda (exp env)
    (cases expresion exp
            ;; lit-exp: devuelve el numero.
      (lit-exp (num)
        num)
            ;; var-exp(variable): busca su valor en el ambiente.
      (var-exp (id)
        (apply-env env id)
       )
           ;; booleanos.
      (true-exp ()
                #t)  
      (false-exp ()
                 #f) 
           ;; prim-exp(primitivas): evalua los argumentos dados y aplica la operacion respectiva.
      (prim-exp (prim rands)
        (let ((valores-evaluados
               (evaluar-rands rands env)))
          (evaluar-primitiva prim valores-evaluados))
        )

      ;; condicionales  
      (if-exp (test true-exp false-exp)
        (let ((value-condicion
               (evaluar-expresion test env)))
          (if (boolean? value-condicion)
              (if value-condicion
                  (evaluar-expresion true-exp env)
                  (evaluar-expresion false-exp env))
              (eopl:error 'evaluar-expresion
                          "lo siento la condicion debe ser booleana: ~s"
                          value-condicion)))
        )
 
      (let-exp (ids rands body);; let-exp se encarga de evaluar los valores en el ambiente original
        (let ((values          ;; y posteriormente evalua el cuerpo en el ambiente extendido.
               (evaluar-rands rands env)))
               (evaluar-expresion
                body
              (ambiente-extendido ids values env)))
        )
     
     ;;Procedimientos y creacion de clausuras
      (proc-exp (ids body)
        (cerradura ids body env))

      ;;Aplicacion de procedimientos
      (apply-exp (rator rands)
        (let ((proc (evaluar-expresion rator env))
              (args (evaluar-rands rands env)))
          (apply-procedure proc args)))

      ;;Recursion mediante letrec
      ;;Los nombres de los procedimientos quedan disponibles dentro
      ;;de sus propios cuerpos y pueden referenciarse entre sí.
      (letrec-exp (proc-names idss bodies body)
        (evaluar-expresion
         body
         (ambiente-recursivo
          proc-names
          idss
          bodies
          env)))

      ;;Seleccion mediante case
      ;;La expresion de control se evalua una sola vez.
      ;;Las alternativas se comparan en orden y, si ninguna coincide,
      ;;se evalua la expresion otherwise.
      (case-exp (exp-control valores cuerpos alternativa-por-defecto)
        (let ((valor-control (evaluar-expresion exp-control env)))
          (if (number? valor-control)
              (evaluar-caso
               valor-control
               valores
               cuerpos
               alternativa-por-defecto
               env)
              (eopl:error
               'evaluar-expresion
               "La expresion de control de case debe producir un numero"))))

    )))    
     
    

      
(provide (all-defined-out))
