        	.area PROG (ABS)

         	; definicion de constantes
pantalla 	.equ 	0xFF00
fin     	.equ 	0xFF01
teclado		.equ	0xFF02

        	.org 	0x100
        	.globl 	programa

limpiarPantalla:  .asciz "\33[2J"

menu:     .ascii  " CONECTA 4\n\n"
          .ascii  "   1) Jugar\n"
          .ascii  "   2) Instrucciones\n"
          .ascii  "   s) Salir\n\n"
          .ascii  "Seleccione opcion: "
          .byte   0

errorMenu:  .ascii "\nERROR: la opcion introducida es incorrecta"
            .byte  0

instrucciones:  .ascii "El objetivo de Conecta 4 es alinear cuatro fichas\n"
                .ascii "sobre un tablero formado por seis filas y siete\n"
                .ascii "columnas. Cada jugador dispone de 21 fichas de\n"
                .ascii "un color (por lo general, rojas o amarillas). Por\n"
                .ascii "turnos, los jugadores deben introducir una ficha en\n"
                .ascii "la columna que prefieran (siempre que no este\n"
                .ascii "completa) y esta caera a la posicion mas baja.\n"
                .ascii "Gana la partida el primero que consiga alinear\n"
                .ascii "cuatro fichas consecutivas de un mismo color en\n"
                .ascii "horizontal, vertical o diagonal. Si todas las\n"
                .ascii "columnas estan llenas pero nadie ha hecho una fila\n"
                .ascii "valida, hay empate.\n"
                .byte  0

volverMenu:     .ascii "\nPulse cualquier tecla para volver al menu..."
                .byte   0

tablero1: .ascii  "    CONECTA 4    \n"
          .ascii  "\n"
          .ascii  "* "
          .byte   0

tablero2: .ascii  "*\n"
          .ascii  "* * * * * * * * *\n"
          .ascii  "* 1 2 3 4 5 6 7 *\n"
          .ascii  "\n"
          .ascii  "JUGADOR "
          .byte   0

teclaNoVal: .ascii  "\nTECLA NO VALIDA (1-7)\n"
            .ascii  "<pulsa tecla>\n"
            .byte   0

columLlena: .ascii  "\nCOLUMNA LLENA\n"
            .ascii  "<pulsa tecla>\n"
            .byte   0

tableroLleno: .ascii  "\nTABLERO LLENO, EMPATE\n"
              .ascii  "<pulsa tecla>\n"
              .byte   0

jugadorGanador: .ascii  "\nHA GANADO EL JUGADOR "
                .byte   0

matriz:   .ascii  "0123456"
          .ascii  "7890123"
          .ascii  "4567890"
          .ascii  "1234567"
          .ascii  "8901234"
          .ascii  "5678901"
          .byte   0

numIguales:   .word 0
turnoActual:  .word 0

programa:
  lds	  #0xFF00	; inicializamos la pila
  lbsr  iniciar_tablero
  leax  limpiarPantalla,pcr
  lbsr	imprime_cadena
  leax	menu,pcr
  lbsr	imprime_cadena
  lda   teclado
  sta   pantalla
  ldb   teclado
  cmpa  #'1
  lbeq  turno1
  cmpa  #'2
  lbeq  mostrarInstrucciones
  cmpa  #'s
  lbeq  acabar
  leax  errorMenu,pcr
  lbsr  imprime_cadena
  leax  volverMenu,pcr
  lbsr  imprime_cadena
  lda   teclado
  bra   programa

turno1:
  sta   turnoActual
  lbsr  juego
turno1_bucle:
  ldb   a,x
  cmpb  #32
  bne   resta1
  ldb   #'O
  stb   a,x
  lbsr  comprob
  lda   #2
  bra   turno2
turno2:
  sta   turnoActual
  lbsr  juego
turno2_bucle:
  ldb   a,x
  cmpb  #32
  bne   resta2
  ldb   #'X
  stb   a,x
  lbsr  comprob
  lbsr  compLleno
  lda   #1
  bra   turno1
resta1:
  suba  #7
  bmi   errorColumna
  bra   turno1_bucle
resta2:
  suba  #7
  bmi   errorColumna
  bra   turno2_bucle

juego:
  lbsr  imprime_tablero
  lbsr  imprime_turno
  lda   teclado
  sta   pantalla
  ldb   teclado
  cmpa  #'s
  lbeq  acabar    ;acabar el programa al introducir s
  cmpa  #'1
  blo   errorTecla
  cmpa  #'7
  bhi   errorTecla
  suba  #'1
  ldx   #matriz
  ldb   a,x
  cmpb  #32
  bne   errorColumna
  adda  #35
  rts

errorTecla:
  leax  teclaNoVal,pcr
  lbsr  imprime_cadena
  ldb   teclado
  bra   juego
errorColumna:
  leax  columLlena,pcr
  lbsr  imprime_cadena
  ldb   teclado
  bra  juego

compLleno:
  pshs	a
  pshs  b
  ldx   #matriz
  clra
comprobarTabla:
  cmpa  #7
  beq   imprimirErrorLleno
  ldb   a,x
  inca
  cmpb  #32
  bne   comprobarTabla
  bra   errorLleno_ret
imprimirErrorLleno:
  leax  tableroLleno,pcr
  lbsr  imprime_cadena
  ldb   teclado
  lbra   programa
errorLleno_ret:
  puls  b
  puls  a, pc

comprob:
  pshs  a
  pshs  b
comprobHoriz:
  lda   #38
comprobHoriz_bucle:
  lbsr  resNumIguales
  ldb   a,x
  cmpb  #32
  beq   comprobVerti
  stb   ,y
horizIzquierda:
  pshs  a
  pshs  b
horizIzquierda_bucle:
  suba  #11
  ldb   a,x
  cmpb  ,y
  bne   horizIzqFin
  lbsr  compNumIguales
  bra   horizIzquierda_bucle
horizIzqFin:
  puls  b
  puls  a
horizDerecha:
  pshs  a
  pshs  b
horizDerecha_bucle:
  adda  #1
  ldb   a,x
  cmpb  ,y
  bne   horizDerFin
  lbsr  compNumIguales
  bra   horizDerecha_bucle
horizDerFin:
  puls  b
  puls  a
  suba  #7
  bra   comprobHoriz_bucle
comprobVerti:
  lda   #14
comprobVerti_bucle:
  lbsr  resNumIguales
  cmpa  #21
  beq   comprobDiago1
  ldb   a,x
  adda  #1
  cmpb  #32
  beq   comprobVerti_bucle
  suba  #1
  stb   ,y
vertiArriba:
  pshs  a
  pshs  b
vertiArriba_bucle:
  suba  #7
  bmi   vertiArrFin
  ldb   a,x
  cmpb  ,y
  bne   vertiArrFin
  lbsr  compNumIguales
  bra   vertiArriba_bucle
vertiArrFin:
  puls  b
  puls  a
vertiAbajo:
  pshs  a
  pshs  b
vertiAbajo_bucle:
  adda  #7
  ldb   a,x
  cmpb  ,y
  bne   vertiAbFin
  lbsr  compNumIguales
  bra   vertiAbajo_bucle
vertiAbFin:
  puls  b
  puls  a
  adda  #1
  bra   comprobVerti_bucle
comprobDiago1:
  lda   #14
comprobDiago1_bucle:
  lbsr   resNumIguales
  cmpa  #20
  beq   comprobDiago2
  ldb   a,x
  adda  #1
  cmpb  #32
  beq   comprobDiago1_bucle
  suba  #1
  stb   ,y
diagoArribaIzquierda:
  pshs  a
  pshs  b
diagoArribaIzquierda_bucle:
  suba  #8
  bmi   diagoArrIzqFin
  cmpa  #6
  beq   diagoArrIzqFin
  ldb   a,x
  cmpb  ,y
  bne   diagoArrIzqFin
  lbsr  compNumIguales
  bra   diagoArribaIzquierda_bucle
diagoArrIzqFin:
  puls  b
  puls  a
diagoAbajoDerecha:
  pshs  a
  pshs  b
diagoAbajoDerecha_bucle:
  adda  #8
  cmpa  #42
  bpl   diagoAbDerFin
  cmpa  #35
  beq   diagoAbDerFin
  ldb   a,x
  cmpb  ,y
  bne   diagoAbDerFin
  bsr   compNumIguales
  bra   diagoAbajoDerecha_bucle
diagoAbDerFin:
  puls  b
  puls  a
  adda  #1
  bra   comprobDiago1_bucle
comprobDiago2:
  lda   #15
comprobDiago2_bucle:
  lbsr   resNumIguales
  cmpa  #21
  beq   comprob_ret
  ldb   a,x
  adda  #1
  cmpb  #32
  beq   comprobDiago2_bucle
  suba  #1
  stb   ,y
diagoArribaDerecha:
  pshs  a
  pshs  b
diagoArribaDerecha_bucle:
  suba  #6
  bmi   diagoArrDerFin
  cmpa  #14
  beq   diagoArrDerFin
  cmpa  #7
  beq   diagoArrDerFin
  cmpa  #0
  beq   diagoArrDerFin
  ldb   a,x
  cmpb  ,y
  bne   diagoArrDerFin
  bsr   compNumIguales
  bra   diagoArribaDerecha_bucle
diagoArrDerFin:
  puls  b
  puls  a
diagoAbajoIzquierda:
  pshs  a
  pshs  b
diagoAbajoIzquierda_bucle:
  adda  #6
  cmpa  #41
  bpl   diagoAbIzqFin
  cmpa  #34
  beq   diagoAbIzqFin
  cmpa  #27
  beq   diagoAbIzqFin
  ldb   a,x
  cmpb  ,y
  bne   diagoAbIzqFin
  bsr   compNumIguales
  bra   diagoAbajoIzquierda_bucle
diagoAbIzqFin:
  puls  b
  puls  a
  adda  #1
  bra   comprobDiago2_bucle
comprob_ret:
  puls  b
  puls  a, pc

compNumIguales:
  pshs  a
  lda   numIguales
  inca
  cmpa  #3
  beq   ganador
  sta   numIguales
  puls  a, pc
resNumIguales:
  pshs  a
  lda   #0
  sta   numIguales
  puls  a, pc
ganador:
  lbsr  imprime_tablero
  lda   turnoActual
  lbsr  imprime_turno
  leax  jugadorGanador,pcr
  lbsr	imprime_cadena
  lda   turnoActual
  lbsr  imprime_turno
  leax  volverMenu,pcr
  lbsr  imprime_cadena
  ldb   teclado
  lbra  programa

mostrarInstrucciones:
  leax  limpiarPantalla,pcr
  lbsr	imprime_cadena
  leax  instrucciones,pcr
  lbsr  imprime_cadena
  leax  volverMenu,pcr
  lbsr  imprime_cadena
  lda   teclado
  lbra  programa

iniciar_tablero:
  pshs  a
  pshs  b
  leax  matriz,pcr
  lda   #32
  clrb
bucle_iniciar_tablero:
  cmpb  #42
  beq   ret_iniciar_tablero
  sta   b,x
  incb
  bra   bucle_iniciar_tablero
ret_iniciar_tablero:
  puls  b
  puls	a, pc

imprime_tablero:
  leax  limpiarPantalla,pcr
  lbsr	imprime_cadena	
  leax  tablero1,pcr
  lbsr	imprime_cadena
  pshs	a
  pshs  b
  leax  matriz,pcr
  lda   #0
  ldb   #0
imprime_matriz:
  pshs  a
  pshs  b
  ldb   #0
  puls  a
bucle_imprime_matriz:
  cmpb  #7
  beq   sgte2
  pshs  a
  lda   a,x
  sta   pantalla
  lda   #32
  sta 	pantalla
  puls  a
  incb
  inca
  bra 	bucle_imprime_matriz
sgte2:
  pshs  a
  puls  b
  puls  a
  cmpa  #5
  beq   ret_imprime_tablero
  pshs  a
  lda   #'*
  sta   pantalla
  lda   #'\n
  sta   pantalla
  lda   #'*
  sta   pantalla
  lda   #32
  sta   pantalla
  puls  a
  inca
  bra   imprime_matriz
ret_imprime_tablero:
  leax  tablero2,pcr
  lbsr	imprime_cadena
  puls	b
  puls  a, pc

imprime_turno:
  cmpa  #2
  beq   imprime_turno2
  bra   imprime_turno1
imprime_turno1:
  lda   #'1
  sta   pantalla
  lda   #32
  sta   pantalla
  lda   #'(
  sta   pantalla
  lda   #'O
  sta   pantalla
  lda   #')
  sta   pantalla
  lda   #':
  sta   pantalla
  lda   #32
  sta   pantalla
  rts
imprime_turno2:
  lda   #'2
  sta   pantalla
  lda   #32
  sta   pantalla
  lda   #'(
  sta   pantalla
  lda   #'X
  sta   pantalla
  lda   #')
  sta   pantalla
  lda   #':
  sta   pantalla
  lda   #32
  sta   pantalla
  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; imprime_cadena                                                   ;
;     saca por la pantalla la cadena acabada en '\0 apuntada por X ;
;                                                                  ;
;   Entrada: X-direccion de comienzo de la cadena                  ;
;   Salida:  ninguna                                               ;
;   Registros afectados: X, CC.                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imprime_cadena:
  pshs	a
sgte:
  lda   ,x+
  beq   ret_imprime_cadena
  sta 	pantalla
  bra 	sgte
ret_imprime_cadena:
  puls	a, pc


acabar:
  lda   #'\n
  sta	  pantalla
  clra
  sta   fin

  .org    0xFFFE	; vector de RESET
  .word   programa