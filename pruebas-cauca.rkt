#lang eopl
;Autores: Andres Felipe Quiceno gil Codigo:2477362
;Yonier Alejandro Vega Rojas Codigo:2477056
;Jhon Fabricio Hurtado Marin Codigo: 2459472
;Juan Esteban Aguirre Castañeda Codigo:2459676

;; Taller 2 — El intérprete de Cauca.
;; Batería de pruebas con rackunit. Llega escrita en el fork y no se
;; modifica: las pruebas del grupo se agregan después, en suites nuevas
;; que se suman a la cuenta de fallidas del final.
;;
;; Requiere solamente la fachada, nunca un módulo de src/ por separado.
;;
;; Se ejecuta con:  racket pruebas-cauca.rkt

(require rackunit)
(require rackunit/text-ui)
(require (only-in racket/base exn:fail?))
(require "interprete-cauca.rkt")

;; corre : string -> valor
(define corre (lambda (texto) (interpretar texto)))

(define base
  (test-suite
   "Parte 1: interprete base"
   (test-case "literales y variables del ambiente inicial"
              (check-equal? (corre "42") 42)
              (check-equal? (corre "-7") -7)
              (check-equal? (corre "3.5") 3.5)
              (check-equal? (corre "n") 10)
              (check-equal? (corre "r") 5))
   (test-case "booleanos"
              (check-equal? (corre "true") #t)
              (check-equal? (corre "false") #f))
   (test-case "primitivas aritmeticas n-arias"
              (check-equal? (corre "+(1, 2, 3)") 6)
              (check-equal? (corre "-(10, 3, 2)") 5)
              (check-equal? (corre "*(2, 3, 4)") 24)
              (check-equal? (corre "/(100, 5, 2)") 10))
   (test-case "primitivas unarias"
              (check-equal? (corre "add1(n)") 11)
              (check-equal? (corre "sub1(n)") 9)
              (check-equal? (corre "not(true)") #f))
   (test-case "primitivas relacionales"
              (check-equal? (corre ">(n, m)") #t)
              (check-equal? (corre ">=(m, m)") #t)
              (check-equal? (corre "<(q, r)") #t)
              (check-equal? (corre "<=(r, q)") #f)
              (check-equal? (corre "==(n, 10)") #t))
   (test-case "primitivas booleanas binarias"
              (check-equal? (corre "and(true, false)") #f)
              (check-equal? (corre "or(true, false)") #t))
   (test-case "condicional"
              (check-equal? (corre "if >(n, m) then n else m end") 10)
              (check-equal? (corre "if <(n, m) then n else m end") 3))
   (test-case "ligaduras locales"
              (check-equal? (corre "let x = 2 y = 3 in *(x, y) end") 6)
              (check-equal? (corre "let x = 1 in let x = 2 in x end end") 2)
              (check-equal? (corre "let x = 1 in +(x, n) end") 11))
   (test-case "el ejemplo del area del rectangulo"
              (check-equal? (corre "// el area de un rectangulo, con el condicional que valida los lados
let base = 8
    altura = 5
in
  if and(>(base, 0), >(altura, 0))
  then *(base, altura)
  else 0
  end
end") 40))
   (test-case "la condicion del if debe ser booleana"
              (check-exn exn:fail? (lambda () (corre "if n then 1 else 2 end"))))
   (test-case "una variable no ligada es un error"
              (check-exn exn:fail? (lambda () (corre "z"))))
   (test-case "los comentarios se ignoran"
              (check-equal? (corre "// esto no cuenta
7") 7))))

(define primitivas-nuevas
  (test-suite
   "Parte 2: primitivas nuevas"
   (test-case "abs"
              (check-equal? (corre "abs(-7)") 7)
              (check-equal? (corre "abs(7)") 7)
              (check-equal? (corre "abs(-3.5)") 3.5))
   (test-case "mcd"
              (check-equal? (corre "mcd(12, 18)") 6)
              (check-equal? (corre "mcd(7, 13)") 1)
              (check-equal? (corre "mcd(12, 18, 24)") 6))
   (test-case "mcm"
              (check-equal? (corre "mcm(4, 6)") 12)
              (check-equal? (corre "mcm(3, 5)") 15)
              (check-equal? (corre "mcm(2, 3, 4)") 12))
   (test-case "promedio"
              (check-equal? (corre "promedio(1, 2, 3, 4)") 5/2)
              (check-equal? (corre "promedio(10)") 10)
              (check-equal? (corre "promedio(n, m)") 13/2))
   (test-case "xor"
              (check-equal? (corre "xor(true, false)") #t)
              (check-equal? (corre "xor(true, true)") #f)
              (check-equal? (corre "xor(false, false)") #f))
   (test-case "implica"
              (check-equal? (corre "implica(true, false)") #f)
              (check-equal? (corre "implica(false, false)") #t)
              (check-equal? (corre "implica(true, true)") #t))
   (test-case "entre"
              (check-equal? (corre "entre(5, 1, 10)") #t)
              (check-equal? (corre "entre(1, 1, 10)") #t)
              (check-equal? (corre "entre(11, 1, 10)") #f))
   (test-case "las primitivas verifican el tipo de sus argumentos"
              (check-exn exn:fail? (lambda () (corre "mcd(1.5, 2)")))
              (check-exn exn:fail? (lambda () (corre "xor(1, true)")))
              (check-exn exn:fail? (lambda () (corre "abs(true)")))
              (check-exn exn:fail? (lambda () (corre "entre(1, 2)"))))))

(define procedimientos
  (test-suite
   "Parte 3: procedimientos y clausuras"
   (test-case "procedimiento de un parametro"
              (check-equal? (corre "let escalar = proc (v) *(v, 2) end
                                    in apply escalar (21) end") 42))
   (test-case "procedimiento sin parametros"
              (check-equal? (corre "let f = proc () 7 end in apply f () end") 7))
   (test-case "procedimiento de varios parametros"
              (check-equal? (corre "let f = proc (a, b, c) +(a, b, c) end
                                    in apply f (1, 2, 3) end") 6))
   (test-case "un procedimiento recibe otro como argumento"
              (check-equal? (corre "let aplicardos = proc (f, x) apply f (apply f (x)) end
                                        doble = proc (v) *(v, 2) end
                                    in apply aplicardos (doble, 5) end") 20))
   (test-case "un procedimiento retorna otro procedimiento"
              ;; el resultado de una aplicacion se liga antes de volver a
              ;; aplicarlo: <expresion> no puede empezar con parentesis
              (check-equal? (corre "let sumador = proc (a) proc (b) +(a, b) end end
                                    in let suma3 = apply sumador (3)
                                       in apply suma3 (4) end
                                    end") 7))
   (test-case "el cuerpo se evalua en el ambiente de la definicion"
              (check-equal? (corre "let factor = 10
in
  let escalar = proc (v) *(v, factor) end
  in
    let factor = 1000
    in
      apply escalar (5)
    end
  end
end") 50))
   (test-case "aplicar algo que no es procedimiento es un error"
              (check-exn exn:fail? (lambda () (corre "apply 5 (1)"))))
   (test-case "la cantidad de argumentos debe coincidir"
              (check-exn exn:fail?
                         (lambda () (corre "let f = proc (a, b) +(a, b) end
                                            in apply f (1) end"))))))

(define recursion-y-case
  (test-suite
   "Parte 4: recursion y seleccion por valor"
   (test-case "el ejemplo de potencia"
              (check-equal? (corre "letrec
  potencia (base, exp) = if ==(exp, 0)
                         then 1
                         else *(base, apply potencia (base, sub1(exp)))
                         end
in
  apply potencia (2, 10)
end") 1024))
   (test-case "recursion simple"
              (check-equal? (corre "letrec
  factorial (n) = if ==(n, 0) then 1 else *(n, apply factorial (sub1(n))) end
in apply factorial (5) end") 120))
   (test-case "recursion mutua en el mismo letrec"
              (check-equal? (corre "letrec
  par? (n) = if ==(n, 0) then true else apply impar? (sub1(n)) end
  impar? (n) = if ==(n, 0) then false else apply par? (sub1(n)) end
in apply par? (10) end") #t)
              (check-equal? (corre "letrec
  par? (n) = if ==(n, 0) then true else apply impar? (sub1(n)) end
  impar? (n) = if ==(n, 0) then false else apply par? (sub1(n)) end
in apply impar? (7) end") #t))
   (test-case "letrec con un procedimiento pasado como argumento"
              (check-equal? (corre "letrec
  aplicarn (f, x, veces) = if ==(veces, 0)
                           then x
                           else apply f (apply aplicarn (f, x, sub1(veces)))
                           end
in let doble = proc (v) *(v, 2) end
   in apply aplicarn (doble, 1, 5) end
end") 32))
   (test-case "el ejemplo de case"
              (check-equal? (corre "let dia = 3
in
  case dia
    of 1 => 100
    of 3 => 300
    of 7 => 700
    otherwise => 0
  end
end") 300))
   (test-case "case con la rama otherwise activa"
              (check-equal? (corre "let dia = 5
in case dia of 1 => 100 of 3 => 300 otherwise => 0 end end") 0))
   (test-case "case evalua la expresion de control una sola vez"
              (check-equal? (corre "case +(1, 2) of 2 => 20 of 3 => 30 otherwise => 0 end") 30))
   (test-case "el control de case debe ser numero"
              (check-exn exn:fail?
                         (lambda () (corre "case true of 1 => 1 otherwise => 0 end"))))))

;; ------------------------------------------------------------------
;; Suites del grupo
;; ------------------------------------------------------------------
 
(define scanner-pruebas
  (test-suite
   "Scanner"
   (test-case "identificador"
              (check-equal? (scanner "x") '((identificador x 1)))
              (check-equal? (scanner "par?") '((identificador par? 1)))
              (check-equal? (scanner "a_1") '((identificador a_1 1))))
   (test-case "numeros enteros y flotantes, positivos y negativos"
              (check-equal? (scanner "42") '((numero 42 1)))
              (check-equal? (scanner "-7") '((numero -7 1)))
              (check-equal? (scanner "3.5") '((numero 3.5 1)))
              (check-equal? (scanner "-3.5") '((numero -3.5 1))))
   (test-case "los comentarios y los espacios se ignoran"
              (check-equal? (scanner "// nada
7") '((numero 7 2)))
              (check-equal? (scanner "   x   ") '((identificador x 1))))
   (test-case "el guion abre un numero negativo"
              (check-equal? (scanner "aplicar-3")
                            '((identificador aplicar 1) (numero -3 1))))
   (test-case "una expresion completa produce la cantidad esperada de tokens"
              (check-equal? (length (scanner "let x = 1 in +(x, 2) end")) 12))))
 
(define parser-pruebas
  (test-suite
   "Parser"
   (test-case "literales y variables"
              (check-equal? (parser "42") (a-program (lit-exp 42)))
              (check-equal? (parser "x") (a-program (var-exp 'x)))
              (check-equal? (parser "true") (a-program (true-exp)))
              (check-equal? (parser "false") (a-program (false-exp))))
   (test-case "primitiva"
              (check-equal? (parser "+(1, 2)")
                            (a-program (prim-exp (sum-prim)
                                                 (list (lit-exp 1) (lit-exp 2))))))
   (test-case "condicional"
              (check-equal? (parser "if true then 1 else 2 end")
                            (a-program (if-exp (true-exp) (lit-exp 1) (lit-exp 2)))))
   (test-case "let"
              (check-equal? (parser "let x = 1 in x end")
                            (a-program (let-exp '(x) (list (lit-exp 1)) (var-exp 'x)))))
   (test-case "proc y apply"
              (check-equal? (parser "proc (a) a end")
                            (a-program (proc-exp '(a) (var-exp 'a))))
              (check-equal? (parser "apply f (1, 2)")
                            (a-program (app-exp (var-exp 'f)
                                                (list (lit-exp 1) (lit-exp 2))))))
   (test-case "letrec y case"
              (check-equal? (parser "letrec f (k) = k in apply f (1) end")
                            (a-program (letrec-exp '(f) '((k)) (list (var-exp 'k))
                                                   (app-exp (var-exp 'f) (list (lit-exp 1))))))
              (check-equal? (parser "case 1 of 1 => 2 otherwise => 3 end")
                            (a-program (case-exp (lit-exp 1) '(1) (list (lit-exp 2)) (lit-exp 3))))
              )
   (test-case "una aplicacion no puede ser el operador de otra"
              (check-exn exn:fail? (lambda () (parser "apply (apply f (3)) (4)"))))))
 
(define errores-pruebas
  (test-suite
   "Errores y casos limite"
   (test-case "el operador de apply debe ser un procedimiento"
              (check-exn exn:fail? (lambda () (corre "apply true (1)")))
              (check-exn exn:fail? (lambda () (corre "apply n ()"))))
   (test-case "tipos incorrectos en primitivas"
              (check-exn exn:fail? (lambda () (corre "+(true, 1)")))
              (check-exn exn:fail? (lambda () (corre "not(1)")))
              (check-exn exn:fail? (lambda () (corre "and(1, true)")))
              (check-exn exn:fail? (lambda () (corre "promedio(true, 2)")))
              (check-exn exn:fail? (lambda () (corre "mcm(2.5, 5)")))
              (check-exn exn:fail? (lambda () (corre "implica(true, 1)"))))
   (test-case "cantidad de argumentos en primitivas"
              (check-exn exn:fail? (lambda () (corre "add1(1, 2)")))
              (check-exn exn:fail? (lambda () (corre "mcd(12)")))
              (check-exn exn:fail? (lambda () (corre "entre(1, 2)"))))
   (test-case "entre respeta el orden de los limites"
              (check-equal? (corre "entre(5, 1, 10)") #t)
              (check-equal? (corre "entre(5, 10, 1)") #f))
   (test-case "case compara por valor numerico"
              (check-equal? (corre "case 3.0 of 3 => 1 otherwise => 0 end") 1))
   (test-case "una clausura recuerda su ambiente de definicion"
              (check-equal? (corre "let a = 2
in let f = proc (x) *(x, a) end
   in let a = 100 in apply f (3) end end
end") 6))))
 
(define informes-pruebas
  (test-suite
   "Programas de los informes"
   (test-case "programa del AST (5.1)"
              (check-equal? (corre "let umbral = promedio(n, m, p)
in
  letrec
    contar (k) = if <=(k, umbral)
                 then apply contar (add1(k))
                 else k
                 end
  in
    case apply contar (1)
      of 7 => abs(-(umbral, 7))
      otherwise => mcd(n, m)
    end
  end
end") 1/3))
   (test-case "programa de la traza (5.2)"
              (check-equal? (corre "let desplazar = proc (x, d) +(x, d) end
in
  letrec
    acumular (i, total) = if >(i, m)
                          then total
                          else apply acumular
                                 (add1(i), apply desplazar (total, i))
                          end
  in
    apply acumular (1, q)
  end
end") 8))
   (test-case "let no basta para la recursion (6.2)"
              (check-exn exn:fail?
                         (lambda ()
                           (corre "let fact = proc (n) if ==(n, 0) then 1 else *(n, apply fact (sub1(n))) end end
in apply fact (5) end"))))
   (test-case "potencia con exp = 0 y exp = 1"
              (check-equal? (corre "letrec potencia (base, exp) = if ==(exp, 0) then 1
else *(base, apply potencia (base, sub1(exp))) end
in apply potencia (7, 0) end") 1)
              (check-equal? (corre "letrec potencia (base, exp) = if ==(exp, 0) then 1
else *(base, apply potencia (base, sub1(exp))) end
in apply potencia (7, 1) end") 7))
   (test-case "case sin ramas of usa otherwise"
              (check-equal? (corre "case 4 otherwise => 9 end") 9))))
 
;; Las suites que agregue el grupo se declaran arriba y se suman aquí.
 
(define fallidas
  (+ (run-tests base)
     (run-tests primitivas-nuevas)
     (run-tests procedimientos)
     (run-tests recursion-y-case)
     (run-tests scanner-pruebas)
     (run-tests parser-pruebas)
     (run-tests errores-pruebas)
     (run-tests informes-pruebas)))
 
(eopl:printf "~%==========================================~%")
(eopl:printf "  pruebas fallidas en total: ~s~%" fallidas)
(eopl:printf "==========================================~%")
