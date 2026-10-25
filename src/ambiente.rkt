#lang eopl
;Autores: Andres Felipe Quiceno gil Codigo:2477362
;Yonier Alejandro Vega Rojas Codigo:2477056
;Jhon Fabricio Hurtado Marin Codigo: 2459472
;Juan Esteban Aguirre Castañeda Codigo:2459676

;; Taller 2 — El intérprete de Cauca.
;; El TAD ambiente, la búsqueda de ligaduras y el ambiente inicial.
;; Requiere sintaxis.rkt y valores.rkt.
;;
;; Aquí se declara con define-datatype el tipo ambiente, con tres
;; variantes:
;;
;;   ambiente-vacio()
;;   ambiente-extendido(ids, valores, env)
;;     ids      (list-of symbol?)
;;     valores  list?
;;     env      ambiente?
;;   ambiente-recursivo(proc-names, idss, bodies, env)
;;     proc-names  (list-of symbol?)   los nombres declarados en el letrec
;;     idss        list?               la lista de parámetros de cada uno
;;     bodies      (list-of expresion?) los cuerpos, guardados sin evaluar
;;     env         ambiente?
;;
;; La variante recursiva no construye clausuras: las arma apply-env en el
;; momento de la búsqueda, y el ambiente que les entrega es el propio
;; ambiente-recursivo (EOPL, sección 3.4, figura 3.9).

(require "sintaxis.rkt")
(require "valores.rkt")
;;Creacion de datatype de ambiente con su variante de ambiente extendido y su otra de recursivo
(define-datatype ambiente ambiente?
  (ambiente-vacio)
  (ambiente-extendido  (ids (list-of symbol?));;ids
                       (valores list?)
                       (env ambiente?)
                     
   )
  (ambiente-recursivo
           (proc-names (list-of symbol?))
           (idss list?)
           (bodies (list-of expresion?))
           (env ambiente?))
  )


;; apply-env : ambiente x symbol -> valor
;; Busca el identificador en el ambiente, respetando el shadowing de las
;; ligaduras más recientes, y levanta eopl:error si no está ligado.
(define apply-env
  (lambda (env id)      ;;Crearle Funcion auxiliar que recorra la lista de simbolos y de valores para encontrar sus correspondientes
   (cases ambiente env
    (ambiente-vacio () (eopl:error 'apply-env "No se
encontro el identificador "))
    (ambiente-extendido (ids valores env-old)
         (letrec(
         [buscar-listasId
            (lambda (ids valores id)
                (cond
       [(null? ids) (apply-env env-old id)]
       [(eq? (car ids) id) (car valores)];;Si encontro el id correspondiente devuelve su valor 
      [else  ;;Parte recursiva donde se mueven ambas listas al tiempo
       (buscar-listasId (cdr ids) (cdr valores) id)]
         ))]
       ) ;;Llamo la funcion auxiliar recursiva metida en el letrec
         (buscar-listasId ids valores id)
       )
   )
           
   (ambiente-recursivo (proc-names idss bodies env-old2)
                       
    (letrec(
      [buscar-proc-recursivo
       (lambda (proc-names idss bodies env-old2 env-currently id)
          (cond
            [(null? proc-names) (apply-env env-old2 id)]
            [(eq? (car proc-names) id)
               (cerradura (car idss) ;;Cerradura contiene el id , su cuerpo y el ambiente al que pertenece
                          (car bodies) env-currently)]
            [else (buscar-proc-recursivo ;;Recorre al mismo tiempo los proc-names,sus identificadores y la lista de cuerpo por cada proc
               (cdr proc-names) (cdr idss) (cdr bodies)
               env-old2 env-currently id )]
           ) 
       )       
      ]);;Aqui va lo del llamado a la funcion aux dentro del letrec
        (buscar-proc-recursivo proc-names idss bodies env-old2 env id)
      )                  
    )
 )))


;; ambiente-inicial : -> ambiente
;; El ambiente con que arranca todo programa:
;; n = 10, m = 3, p = 7, q = 2, r = 5.
(define ambiente-inicial
  (lambda ()
     (ambiente-extendido '(n m p q r) '(10 3 7 2 5)
                         (ambiente-vacio)))
   )
    ;;(eopl:error 'ambiente-inicial "Sin implementar")))

;;Pruebas del datatype Ambiente
(define e-inicial (ambiente-inicial))
(apply-env e-inicial 'q) ; output: 2

(provide (all-defined-out))
