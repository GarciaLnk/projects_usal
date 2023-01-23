; Implementacion y optimizacion de un algoritmo en ensamblador DLX
; Alberto García Martín
; Iván Campos Alamillo

    .data
; Espacio de datos

; VARIABLES DE ENTRADA: NO MODIFICAR ORDEN (Se pueden modificar los valores)
; lista1: .float 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
; lista2: .float 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
; lista3: .float 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
; lista4: .float 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
; lista5: .float 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5

; lista1: .float 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; lista2: .float 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; lista3: .float 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; lista4: .float 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; lista5: .float 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

lista1: .float 12, 1,15, 1,15,13, 1,14, 1,14,14, 1,13, 1,13,15, 1,12, 1,12
lista2: .float 2,22,25,25, 2, 2,23,24,24, 2, 2,24,23,23, 2, 2,25,22,22, 2
lista3: .float 3, 3,32, 3, 3, 3, 3,33, 3, 3, 3, 3,34, 3, 3, 3, 3,35, 3, 3
lista4: .float 4,45,45,42, 4, 4,44,44,43, 4, 4,43,43,44, 4, 4,42,42,45, 4
lista5: .float 55, 5,55, 5,52,54, 5,54, 5,53,53, 5,53, 5,54,52, 5,52, 5,55

tamano: .word 20

; VARIABLES DE SALIDA: NO MODIFICAR ORDEN
; m11, m12, m13, m14
; m21, m22, m23, m24
; m31, m32, m33, m34
; m41, m42, m43, m44
M:  .float 0.0, 0.0, 0.0, 0.0
    .float 0.0, 0.0, 0.0, 0.0
    .float 0.0, 0.0, 0.0, 0.0
    .float 0.0, 0.0, 0.0, 0.0

checkM: .float 0.0

; Medias
a1: .float 0.0
a2: .float 0.0
a3: .float 0.0
a4: .float 0.0
a5: .float 0.0

checkA: .float 0.0
;;;;; FIN NO MODIFICAR ORDEN

    .text
; Espacio de codigo
    .global main

main:
    lw      r1,tamano   ; cargar tamano en r1
    addi    r2,r0,1     ; cargar 1 en r2
    seqi    r3,r1,0     ; cargar 1 en r3 si r1==0
    bnez    r3,fin      ; finalizar si tamano==0
    movi2fp f21,r1      ; mover tamano a un registro fp
    movi2fp f24,r2      ; mover 1 a un registro fp
    cvti2f  f21,f21     ; convertir tamano a float
    cvti2f  f24,f24     ; convertir 1 a float
    
    ;;
    ; CALCULO media a1
    addi    r2,r0,0     ; poner r2 a 0
    addi    r3,r0,0     ; poner r3 a 0
bucle1:
    seq     r4,r2,r1        ; comprobar si r2==tamano
    bnez    r4,finsuma1     ; saltar a divf si r2==tamano
    lf      f0,lista1(r3)   ; cargar valores lista1 en f0  
    addf    f20,f20,f0      ; sumar valores lista1 en f20
    addi    r2,r2,1         ; incrementar r2
    addi    r3,r3,4         ; incrementar r3
    j       bucle1          ; volver al inicio del bucle

finsuma1:
    divf    f26,f20,f21 ; dividir la suma entre el tamano = a1
    ;;

    ;;
    ; CALCULO media a2
    addi    r2,r0,0     ; poner r2 a 0
    addi    r3,r0,0     ; poner r3 a 0
    movf    f20,f31     ; poner f20 a 0
bucle2:
    seq     r4,r2,r1        ; comprobar si r2==tamano
    bnez    r4,finsuma2     ; saltar a divf si r2==tamano
    lf      f0,lista2(r3)   ; cargar valores lista2 en f0
    addf    f20,f20,f0      ; sumar valores lista2 en f20
    addi    r2,r2,1         ; incrementar r2
    addi    r3,r3,4         ; incrementar r3
    j       bucle2          ; volver al inicio del bucle

finsuma2:
    divf    f27,f20,f21 ; dividir la suma entre el tamano = a2
    ;;

    ;;
    ; CALCULO media a3
    addi    r2,r0,0     ; poner r2 a 0
    addi    r3,r0,0     ; poner r3 a 0
    movf    f20,f31     ; poner f20 a 0
bucle3:
    seq     r4,r2,r1        ; comprobar si r2==tamano
    bnez    r4,finsuma3     ; saltar a divf si r2==tamano
    lf      f0,lista3(r3)   ; cargar valores lista3 en f0
    addf    f20,f20,f0      ; sumar valores lista3 en f20
    addi    r2,r2,1         ; incrementar r2
    addi    r3,r3,4         ; incrementar r3
    j       bucle3          ; volver al inicio del bucle

finsuma3:
    divf    f28,f20,f21 ; dividir la suma entre el tamano = a3
    ;;

    ;;
    ; CALCULO media a4
    addi    r2,r0,0     ; poner r2 a 0
    addi    r3,r0,0     ; poner r3 a 0
    movf    f20,f31     ; poner f20 a 0
bucle4:
    seq     r4,r2,r1        ; comprobar si r2==tamano
    bnez    r4,finsuma4     ; saltar a divf si r2==tamano
    lf      f0,lista4(r3)   ; cargar valores lista4 en f0
    addf    f20,f20,f0      ; sumar valores lista4 en f20
    addi    r2,r2,1         ; incrementar r2
    addi    r3,r3,4         ; incrementar r3
    j       bucle4          ; volver al inicio del bucle

finsuma4:
    divf    f29,f20,f21 ; dividir la suma entre el tamano = a4
    ;;

    ;;
    ; CALCULO media a5
    addi    r2,r0,0     ; poner r2 a 0
    addi    r3,r0,0     ; poner r3 a 0
    movf    f20,f31     ; poner f20 a 0
bucle5:
    seq     r4,r2,r1        ; comprobar si r2==tamano
    bnez    r4,finsuma5     ; saltar a divf si r2==tamano
    lf      f0,lista5(r3)   ; cargar valores lista5 en f0
    addf    f20,f20,f0      ; sumar valores lista5 en f20
    addi    r2,r2,1         ; incrementar r2
    addi    r3,r3,4         ; incrementar r3
    j       bucle5          ; volver al inicio del bucle

finsuma5:
    divf    f30,f20,f21 ; dividir la suma entre el tamano = a5
    ;;

    ;;
    ; CALCULO M
    ; calculo multiplicador matriz = ((a2/a5)+(a4/a5))/((a1/a5)+(a3/a5))
    eqf     f30,f31     ; comprobar si a5==0
    bfpt    fin         ; finalizar si a5==0
    divf    f0,f26,f30  ; a1/a5
    divf    f1,f27,f30  ; a2/a5
    divf    f2,f28,f30  ; a3/a5
    divf    f3,f29,f30  ; a4/a5
    addf    f0,f0,f2    ; (a1/a5)+(a3/a5)
    addf    f1,f1,f3    ; (a2/a5)+(a4/a5)
    eqf     f0,f31      ; si denominador (a1/a5)+(a3/a5)==0
    bfpt    fin         ; finalizar si denominador==0
    divf    f22,f1,f0
    ; calculo matriz Vandermonde = (1 a1 a1^2 a1^3)
    ;                              (1 a2 a2^2 a2^3)
    ;                              (1 a3 a3^2 a3^3)
    ;                              (1 a4 a4^2 a4^3)
    multf   f2,f26,f26  ; a1^2
    multf   f6,f27,f27  ; a2^2
    multf   f10,f28,f28 ; a3^2
    multf   f14,f29,f29 ; a4^2
    multf   f3,f2,f26   ; a1^3
    multf   f7,f6,f27   ; a2^3
    multf   f11,f10,f28 ; a3^3
    multf   f15,f14,f29 ; a4^3
    ; calculo M = Vandermonde*multiplicador
    multf   f0,f24,f22
    multf   f1,f26,f22
    multf   f2,f2,f22
    multf   f3,f3,f22
    multf   f4,f24,f22
    multf   f5,f27,f22
    multf   f6,f6,f22
    multf   f7,f7,f22
    multf   f8,f24,f22
    multf   f9,f28,f22
    multf   f10,f10,f22
    multf   f11,f11,f22
    multf   f12,f24,f22
    multf   f13,f29,f22
    multf   f14,f14,f22
    multf   f15,f15,f22
    ;

    ;;
    ; CALCULO checkA = a1 * a2 * a3 * a4 * a5
    multf   f25,f26,f27
    multf   f25,f25,f28
    multf   f25,f25,f29
    multf   f25,f25,f30
    ;

    ;;
    ; CALCULO checkM = m11 + m12 + m13 + m14 + m21 + ... + m44
    addf    f23,f0,f1
    addf    f23,f23,f2
    addf    f23,f23,f3
    addf    f23,f23,f4
    addf    f23,f23,f5
    addf    f23,f23,f6
    addf    f23,f23,f7
    addf    f23,f23,f8
    addf    f23,f23,f9
    addf    f23,f23,f10
    addf    f23,f23,f11
    addf    f23,f23,f12
    addf    f23,f23,f13
    addf    f23,f23,f14
    addf    f23,f23,f15
    ;

    ;;
    ; ALMACENAR resultados en memoria
    sf      checkM,f23
    sf      checkA,f25
    sf      a1,f26
    sf      a2,f27
    sf      a3,f28
    sf      a4,f29
    sf      a5,f30
    sf      M,f0
    sf      M+4,f1
    sf      M+8,f2
    sf      M+12,f3
    sf      M+16,f4
    sf      M+20,f5
    sf      M+24,f6
    sf      M+28,f7
    sf      M+32,f8
    sf      M+36,f9
    sf      M+40,f10
    sf      M+44,f11
    sf      M+48,f12
    sf      M+52,f13
    sf      M+56,f14
    sf      M+60,f15
    ;

fin:
    ; FIN ejecucion
    trap    0
