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
   
  (scanner "123")=> ((numero 123 1)) numero entero
  (scanner "-25")=> ((numero -25 1)) numero entero negativo
  (scanner "3.14")=> ((numero 3.14 1)) numero flotante
  (scanner "variable_1")=> ((identificador variable_1 1)) identificador con _ ,letters y digitos
  (scanner "// comentario 
   42")=> ((numero 42 2))  Comentario y espacio

  Parser
    (parser "...")    =>

(parser "25")=> #(struct:a-program #(struct:lit-exp 25))  un literal numérico

(parser "true") => #(struct:a-program #(struct:true-exp))  un literal booleano

(parser "+(3, 5)") => #(struct:a-program
  #(struct:prim-exp
    #(struct:sum-prim)
    (#(struct:lit-exp 3) #(struct:lit-exp 5))))  una expresión primitiva con 2 argumentos

(parser "if >(8, 3) then 10 else 20 end") =>
 #(struct:a-program
  #(struct:if-exp
    #(struct:prim-exp
      #(struct:mayor-prim)
      (#(struct:lit-exp 8) #(struct:lit-exp 3)))
    #(struct:lit-exp 10)
    #(struct:lit-exp 20))) una expresión condicional que compara 2 argumentos

(parser "let x = 5 in *(x, 2) end") =>
#(struct:a-program
  #(struct:let-exp
    (x)
    (#(struct:lit-exp 5))
    #(struct:prim-exp
      #(struct:mult-prim)
      (#(struct:var-exp x) #(struct:lit-exp 2))))) una expresión let con variable y su operación respectiva

  Ejecución del lenguaje base
    (interpretar "...")   =>

 1 *aritmetica basica
  (interpretar "
  let x = 10
      y = 3
  in
    +( -(x, y), *(2, y))
  end
")     => output: 13

 2*division ,incremento y decremento
 (interpretar "
  +( /(12, 3), +(add1(4), sub1(6)))
  ")    => Output : 14

 3 *comparaciones con == , <, >, >=, <=
  (interpretar "
  and(>(5, 2),
      and(>=(5, 5),
          and(<(2, 5),
              and(<=(5, 5), ==(4, 4)))))
")      => Output: #t

 4 *Operaciones con booleanos
  (interpretar "
  and(not(false), or(true, false))
")   => Output: #t

 5 * Condicionales
  (interpretar "
  if >(10, 5)
  then 100
  else 200
  end
")      =>Output: 100

 6 *Calculo costo al hacer una compra
  (interpretar "let precio = 120
    cantidad = 3
    envio = 15
in
  if and(>(precio, 0), >(cantidad, 0))
  then +( *(precio, cantidad), envio)
  else 0
  end
end")    => Output: 375

 7 *comprueba si un número es positivo y menor que un límite
  (interpretar "let numero = 8
    limite = 20
   in
     if and(>(numero, 0), <(numero, limite))
     then true
     else false
     end
  end")    => Output: #t

 8 * calcular el precio final de un producto teniendo en cuenta el impuesto
  (interpretar "let precio = 100
    impuesto = 19
   in
      if and(>=(precio, 0), >=(impuesto, 0))
      then +(precio, /(*(precio, impuesto), 100))
      else -1
      end
   end")         =>Output: 119

 9 * descuento de una compra
  (interpretar "let precio = 40
    cantidad = 4
    descuento = 20
  in
     if and(>(precio, 0), >(cantidad, 0))
     then
       if >=(*(precio, cantidad), 100)
       then -(*(precio, cantidad), descuento)
       else *(precio, cantidad)
       end
     else 0
     end
  end")  =>Output: 140

 10 *calculo acerca del pago de horas trabajadas
  (interpretar "let horas = 45
    tarifa = 10000
in
  if and(>=(horas, 0), >(tarifa, 0))
  then
    if >(horas, 40)
    then
      +( *(40, tarifa),
         *( -(horas, 40), *(tarifa, 1.5)))
    else *(horas, tarifa)
    end
  else 0
  end
end")     => Output: 475000.0
  
(*)Casos de error:

 1* condicional if con un numero
  
  (interpretar "let base = 8
    altura = 5
in
  if base
  then *(base, altura)
  else 0
  end
end")  => Output:evaluar-expresion: lo siento la condicion debe ser booleana: 8

 2* variable no definida
   (interpretar "let base = 8
    in
       +(base, altura)
    end")    => Output: apply-env: No se
                         encontro el identificador
 
 3* operacion aritmetica con un booleano
    (interpretar "let precio = 100
    valido = true
    in
       +(precio, valido)
    end")   => Output:  exigir-numeros: Todos los argumentos deben ser numeros en +
  
  4* comparación entre tipos incompatibles
    (interpretar "let edad = 20
           autorizado = false
      in
        >(edad, autorizado)
      end")   => Output: exigir-numeros: Todos los argumentos deben ser numeros en >
  
  5* operador booleano con un número
    (interpretar "let valor = 10
      in
        not(valor)
      end")   => Output:exigir-booleanos:  Todos los argumentos deben ser booleanos en not
  
  6* error si se divide entre 0
  (interpretar "let precio = 100
    cantidad = 0
    in
         /(precio, cantidad)
   end")    => Output: division by zero

  
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
*Ejemplo de contraste
 (interpretar "let factor = 10
in
let escalar = proc (v) *(v, factor) end
in
let factor = 1000
in
apply escalar (5)
end
end 
end")        => Output: 50
 
 *procedimientos de cero

  (interpretar "
  let constante = proc () 4020 end
  in
    apply constante ()
  end
")            => Output: 4020

  *procedimientos de 1 parametro
  (interpretar "
  let duplicar = proc (n) *(n, 2) end
  in
    apply duplicar (7)
  end
")       => Output: 14

  *procedimiento de varios parámetros

  (interpretar "
  let sumar = proc (a, b, c) +(+(a, b), c) end
  in
    apply sumar (10, 20, 30)
  end
")        => Output: 60

  *procedimiento que recibe otro procedimiento como argumento

   (interpretar "
  let duplicar = proc (n) *(n, 2) end
  in
    let aplicar = proc (f, x) apply f (x) end
    in
      apply aplicar (duplicar, 5)
    end
  end
")          =>Output: 10

 * procedimiento que retorna otro procedimiento

  (interpretar "
  let crear_sumador = proc (x)
    proc (y) +(x, y) end
  end
  in
    let sumar_cinco = apply crear_sumador (5)
    in
      apply sumar_cinco (3)
    end
  end
")         => Output: 8

  *Caso de error 1: aplicar un valor que no es un procedimiento

   (interpretar "
    apply 5 ()
   ")    => Output: cases: not a procval: 5  

  *Caso de error 2: cantidad incorrecta de argumentos

  (interpretar "
  let sumar = proc (a, b) +(a, b) end
  in
    apply sumar (10)
  end
")   => Output: apply-procedure: Cantidad incorrecta de argumentos. Esperados: 2; recibidos: 1
  
  
  Recursión y case
    (interpretar "...")   =>
   (*)Ejemplos Recursion letrec:

  * Un procedimiento recursivo simple
  
  (interpretar "
   letrec
      factorial (n) =
       if ==(n, 0)
       then 1
       else *(n, apply factorial (-(n, 1)))
       end
   in
     apply factorial (5)
   end
")       =>Output: 120

  * Un procedimiento recursivo con dos parametros
   (interpretar "letrec
        sumar (n, acumulado) =
            if ==(n, 0)
            then acumulado
            else apply sumar (sub1(n), +(acumulado, n))
            end
    in
      apply sumar (5, 0)
    end
")                        =>Output: 15

  * Un procedimiento recursivo con dos procedimientos
   mutuamente recursivos declarados en el mismo letrec
   
   (interpretar "
  letrec
    es_par(n) =
      if ==(n, 0)
      then true
      else apply es_impar (-(n, 1))
      end

    es_impar(n) =
      
      if ==(n, 0)
      then false
      else apply es_par (-(n, 1))
      end
  in
    apply es_par (6)
  end
")       => Output: #t

   *Un procedimiento recursivo que combine letrec con un procedimiento
   pasado como argumento
   
   (interpretar "
  letrec
    duplicar(n) =
      *(n, 2)

    aplicar_nVeces(f, n) =
      if ==(n, 0)
      then 1
      else *(apply f (n),
             apply aplicar_nVeces (f, -(n, 1)))
      end
  in
    apply aplicar_nVeces (duplicar, 3)
  end
")                          =>Output: 48


   (*) Ejemplos cases:

  * Primer ejemplo con cases
   (interpretar "
  let nota = 3
  in
    case nota
      of 1 => 10
      of 2 => 20
      of 3 => 30
      otherwise => 0
    end
  end
")     => Output: 30

*Segundo ejemplo con cases y recursion
(interpretar "
  letrec
    sumar(n) =
      case n
        of 0 => 0
        of 1 => 1
        otherwise => +(n, apply sumar (-(n, 1)))
      end
  in
    apply sumar (4)
  end
")        => Output: 10

*Tercer ejemplo con otherwise activo
(interpretar "
  let opcion= 6
  in
    case opcion
      of 1 => 200
      of 2 => 300
      of 3 => 400
      of 4 => 500
      of 5 => 600
      otherwise => 0
    end
  end
")       => Output: 0

|#
