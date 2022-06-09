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

; cargar el numero de filas de M para simplifcar su calculo y el de checkM
numFilas:   .float 4
; cargar 1/20 para poder retrasar la carga del tamano real y calcular antes las medias en el caso de que tamano=20
maxTam:  .float 0.05

    .text
; Espacio de codigo
    .global main

main:
    lw      r1,tamano       ; cargar tamano en r1
    lf      f0,lista1
    seqi    r6,r1,20        ; cargar 1 en r6 si tamano==20

    ;;
    ; CALCULO media a1
    ; cargar y sumar valores lista1
    lf      f1,lista1+4
    beqz    r6,checktam     ; salta a checktam si tamano != 20
    lf      f21,maxTam      ; carga 1/20=0.05
    lf      f2,lista1+8
    lf      f3,lista1+12
    lf      f4,lista1+16
    lf      f5,lista1+20
    addf    f20,f0,f1
    lf      f1,lista1+24
    addf    f20,f20,f2
    lf      f2,lista1+28
    addf    f20,f20,f3
    lf      f3,lista1+32
    addf    f20,f20,f4
    lf      f4,lista1+36
    addf    f20,f20,f5
    lf      f0,lista1+40
    addf    f20,f20,f1
    lf      f1,lista1+44
    addf    f20,f20,f2
    lf      f2,lista1+48
    addf    f20,f20,f3
    lf      f3,lista1+52
    addf    f20,f20,f4
    lf      f4,lista1+56
    addf    f20,f20,f0
    lf      f0,lista1+60
    addf    f20,f20,f1
    lf      f1,lista1+64
    addf    f20,f20,f2
    lf      f2,lista1+68
    addf    f20,f20,f3
    lf      f3,lista1+72
    addf    f20,f20,f4
    lf      f4,lista1+76
    addf    f20,f20,f0
    lf      f0,lista2       ; empezar a cargar lista2
    addf    f20,f20,f1
    lf      f1,lista2+4     ; lista2
    addf    f20,f20,f2
    lf      f2,lista2+8
    addf    f20,f20,f3
    lf      f3,lista2+12
    addf    f20,f20,f4
    lf      f4,lista2+16 
    multf   f26,f20,f21     ; a1 = sum(lista1) * 0.05
    ;;

    ;;
    ; CALCULO media a2
    ; cargar y sumar valores lista2
    lf      f5,lista2+20
    addf    f20,f0,f1
    lf      f1,lista2+24
    addf    f20,f20,f2
    addf    f20,f20,f3
    lf      f2,lista2+28
    addf    f20,f20,f4
    lf      f3,lista2+32
    addf    f20,f20,f5
    lf      f4,lista2+36
    addf    f20,f20,f1
    lf      f0,lista2+40
    addf    f20,f20,f2
    lf      f1,lista2+44
    addf    f20,f20,f3
    lf      f2,lista2+48
    addf    f20,f20,f4
    lf      f3,lista2+52
    addf    f20,f20,f0
    lf      f4,lista2+56
    addf    f20,f20,f1
    lf      f0,lista2+60
    addf    f20,f20,f2
    lf      f1,lista2+64
    addf    f20,f20,f3
    lf      f2,lista2+68
    addf    f20,f20,f4
    lf      f3,lista2+72
    addf    f20,f20,f0
    lf      f4,lista2+76
    addf    f20,f20,f1
    lf      f0,lista3       ; empezar a cargar lista3
    addf    f20,f20,f2
    lf      f1,lista3+4     ; lista3
    addf    f20,f20,f3
    lf      f2,lista3+8
    addf    f20,f20,f4
    lf      f3,lista3+12
    multf   f27,f20,f21     ; a2 = sum(lista2) * 0.05
    ;;

    ;;
    ; CALCULO media a3
    ; cargar y sumar valores lista3
    lf      f4,lista3+16    
    addf    f20,f0,f1
    lf      f0,lista3+20
    addf    f20,f20,f2
    multf   f16,f26,f27     ; empezar a calcular checkA: (a1*a2)
    addf    f20,f20,f3
    lf      f1,lista3+24    
    addf    f20,f20,f4
    lf      f2,lista3+28
    addf    f20,f20,f0
    addf    f20,f20,f1
    lf      f3,lista3+32
    addf    f20,f20,f2
    lf      f4,lista3+36
    addf    f20,f20,f3
    lf      f0,lista3+40
    addf    f20,f20,f4
    lf      f1,lista3+44
    addf    f20,f20,f0
    lf      f2,lista3+48
    addf    f20,f20,f1
    lf      f3,lista3+52
    addf    f20,f20,f2
    lf      f4,lista3+56
    addf    f20,f20,f3
    lf      f0,lista3+60
    addf    f20,f20,f4
    lf      f1,lista3+64
    addf    f20,f20,f0
    lf      f2,lista3+68
    addf    f20,f20,f1
    lf      f3,lista3+72
    addf    f20,f20,f2
    lf      f4,lista3+76
    addf    f20,f20,f3
    lf      f0,lista4       ; empezar a cargar lista4
    addf    f20,f20,f4
    lf      f1,lista4+4     ; lista4
    multf   f28,f20,f21     ; a3 = sum(lista3) * 0.05
    ;;

    ;;
    ; CALCULO media a4
    ; cargar y sumar valores lista4
    lf      f2,lista4+8
    addf    f20,f0,f1
    lf      f3,lista4+12
    addf    f20,f20,f2
    multf   f17,f16,f28     ; parte checkA: (a12*a3)
    lf      f4,lista4+16    
    lf      f0,lista4+20
    addf    f14,f26,f28     ; empezar a calcular multiplicador: denominador = (a1+a3)
    lf      f1,lista4+24
    addf    f20,f20,f3
    eqf     f14,f31         ; comprobar si denominador==0
    addf    f20,f20,f4
    bfpt    fin             ; finalizar si denominador==0
    addf    f20,f20,f0
    lf      f2,lista4+28
    addf    f20,f20,f1
    lf      f3,lista4+32
    addf    f20,f20,f2
    lf      f4,lista4+36
    addf    f20,f20,f3
    lf      f0,lista4+40
    addf    f20,f20,f4
    lf      f1,lista4+44
    addf    f20,f20,f0
    lf      f2,lista4+48
    addf    f20,f20,f1
    lf      f3,lista4+52
    addf    f20,f20,f2
    lf      f4,lista4+56
    addf    f20,f20,f3
    lf      f0,lista4+60
    addf    f20,f20,f4
    lf      f1,lista4+64
    addf    f20,f20,f0
    lf      f2,lista4+68
    addf    f20,f20,f1
    lf      f3,lista4+72
    addf    f20,f20,f2
    lf      f4,lista4+76
    addf    f20,f20,f3
    lf      f0,lista5       ; empezar a cargar lista5
    addf    f20,f20,f4
    lf      f1,lista5+4     ; lista5
    multf   f29,f20,f21     ; a4 = sum(lista4) * 0.05
    ;;

    ;;
    ; CALCULO media a5
    ; cargar y sumar valores lista5
    lf      f2,lista5+8
    addf    f20,f0,f1
    lf      f0,lista5+12
    addf    f20,f20,f2
    multf   f16,f17,f29     ; parte checkA: (a123*a4)
    addf    f15,f27,f29     ; parte multiplicador: (a2+a4)
    lf      f1,lista5+16
    ; simplificacion multiplicador matriz = ((a2/a5)+(a4/a5))/((a1/a5)+(a3/a5)) => (a2+a4)/(a1+a3)
    divf    f22,f15,f14     ; multiplicador = (a2+a4)/(a1+a3)
    addf    f20,f20,f0
    lf      f2,lista5+20
    addf    f20,f20,f1
    lf      f0,lista5+24
    addf    f20,f20,f2
    lf      f1,lista5+28
    addf    f20,f20,f0
    lf      f2,lista5+32
    addf    f20,f20,f1
    lf      f0,lista5+36
    addf    f20,f20,f2
    lf      f1,lista5+40
    addf    f20,f20,f0
    lf      f2,lista5+44
    addf    f20,f20,f1
    lf      f0,lista5+48
    addf    f20,f20,f2
    lf      f1,lista5+52
    multf   f10,f29,f22     ; m42 = a4 * multi
    addf    f20,f20,f0
    lf      f2,lista5+56
    addf    f20,f20,f1
    multf   f7,f28,f22      ; m32 = a3 * multi
    lf      f0,lista5+60
    addf    f20,f20,f2
    lf      f1,lista5+64
    multf   f4,f27,f22      ; m22 = a2 * multi
    addf    f20,f20,f0
    lf      f2,lista5+68
    addf    f20,f20,f1
    multf   f11,f29,f10     ; m43 = a4 * m42
    lf      f0,lista5+72
    addf    f20,f20,f2
    lf      f2,lista5+76
    multf   f1,f26,f22      ; m12 = a1 * multi
    addf    f20,f20,f0
    lf      f24,numFilas    ; cargar numFilas en f24
    multf   f8,f28,f7       ; m33 = a3 * m32
    addf    f20,f20,f2
    sf      a1,f26          ; almacena a1 en memoria
    multf   f30,f20,f21     ; a5 = sum(lista5) * 0.05
    ;;

    addf    f23,f10,f7      ; inicio calculo checkM = m42 + m32
    sf      a2,f27          ; almacena a2 en memoria
    multf   f5,f27,f4       ; m23 = a2 * m22
    eqf     f30,f31         ; comprobar si a5==0
    addf    f23,f23,f4      ; checkM + m22
    bfpt    fin             ; finalizar si a5==0

    ; checkA = a1 * a2 * a3 * a4 * a5
    multf   f25,f16,f30     ; checkA (a1234*a5)
    sf      a3,f28          ; almacena a3 en memoria
    addf    f23,f23,f1      ; checkM + m12
    sf      a4,f29          ; almacena a4 en memoria
    multf   f2,f26,f1       ; m13 = a1 * m12
    sf      a5,f30          ; almacena a5 en memoria
    sf      checkA,f25      ; almacena checkA en memoria
    sf      M,f22           ; almacena m11
    addf    f23,f23,f11     ; checkM + m43
    multf   f12,f29,f11     ; m44 = a4 * m43
    sf      M+16,f22        ; almacena m21
    sf      M+32,f22        ; almacena m31
    sf      M+48,f22        ; almacena m41
    addf    f23,f23,f8      ; checkM + m33
    multf   f9,f28,f8       ; m34 = a3 * m33
    sf      M+52,f10        ; almacena m42
    sf      M+36,f7         ; almacena m32
    sf      M+20,f4         ; almacena m22
    addf    f23,f23,f5      ; checkM + m23
    multf   f6,f27,f5       ; m24 = a2 * m23
    sf      M+4,f1          ; almacena m12
    sf      M+56,f11        ; almacena m43
    sf      M+40,f8         ; almacena m33
    addf    f23,f23,f2      ; checkM + m13
    multf   f3,f26,f2       ; m14 = a1 * m13
    sf      M+24,f5         ; almacena m23
    addf    f23,f23,f12     ; checkM + m44
    sf      M+8,f2          ; almacena m13
    addf    f23,f23,f9      ; checkM + m34
    multf   f20,f22,f24     ; (m11 + m21 + m31 + m41) = multiplicador * numFilas (4)
    addf    f23,f23,f6      ; checkM + m24
    sf      M+60,f12        ; almacena m44
    addf    f23,f23,f3      ; checkM + m14
    sf      M+44,f9         ; almacena m34
    addf    f23,f23,f20     ; checkM + (m11 + m21 + m31 + m41)
    sf      M+28,f6         ; almacena m24 (2 Stall)
    sf      M+12,f3         ; almacena m14
    ; CALCULO checkM = m11 + m12 + m13 + m14 + m21 + ... + m44
    sf      checkM,f23      ; almacena checkM en memoria

fin:
    ; FIN ejecucion
    trap    0

    ;; CALCULO medias para tamano != 20
checktam:
    seqi    r2,r1,0         ; cargar 1 en r2 si r1==0
    movi2fp f21,r1          ; mover tamano a un registro fp
    bnez    r2,fin          ; finalizar si tamano==0
    seqi    r3,r1,5         ; cargar 1 en r3 si r1==5
    seqi    r4,r1,10        ; cargar 1 en r4 si r1==10
    cvti2f  f21,f21         ; convertir tamano a float
    bnez    r3,tam5         ; salta si tamano==5
    bnez    r4,tam10        ; salta si tamano==10

;tam15:
    ;;
    ; CALCULO media a1
    ; cargar y sumar valores lista1
    lf      f2,lista1+8
    addf    f20,f0,f1
    lf      f0,lista1+12
    addf    f20,f20,f2
    lf      f1,lista1+16
    addf    f20,f20,f0
    lf      f2,lista1+20
    addf    f20,f20,f1
    lf      f0,lista1+24
    addf    f20,f20,f2
    lf      f1,lista1+28
    addf    f20,f20,f0
    lf      f2,lista1+32
    addf    f20,f20,f1
    lf      f0,lista1+36
    addf    f20,f20,f2
    lf      f1,lista1+40
    addf    f20,f20,f0
    lf      f2,lista1+44
    addf    f20,f20,f1
    lf      f0,lista1+48
    addf    f20,f20,f2
    lf      f1,lista1+52
    addf    f20,f20,f0
    lf      f2,lista1+56
    addf    f20,f20,f1
    lf      f0,lista2       ; empezar a cargar lista2
    addf    f20,f20,f2
    lf      f1,lista2+4     ; lista2
    divf    f26,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    ;;
    ; CALCULO media a2
    ; cargar y sumar valores lista2
    lf      f2,lista2+8
    addf    f20,f0,f1
    lf      f0,lista2+12
    addf    f20,f20,f2
    lf      f1,lista2+16 
    addf    f20,f20,f0
    lf      f2,lista2+20
    addf    f20,f20,f1
    lf      f0,lista2+24
    addf    f20,f20,f2
    lf      f1,lista2+28
    addf    f20,f20,f0
    lf      f2,lista2+32
    addf    f20,f20,f1
    lf      f0,lista2+36
    addf    f20,f20,f2
    lf      f1,lista2+40
    addf    f20,f20,f0
    lf      f2,lista2+44
    addf    f20,f20,f1
    lf      f0,lista2+48
    addf    f20,f20,f2
    lf      f1,lista2+52
    addf    f20,f20,f0
    lf      f2,lista2+56
    addf    f20,f20,f1
    lf      f0,lista3       ; empezar a cargar lista3
    addf    f20,f20,f2
    lf      f1,lista3+4     ; lista3
    divf    f27,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    ;;
    ; CALCULO media a3
    ; cargar y sumar valores lista3
    lf      f2,lista3+8
    addf    f20,f0,f1
    lf      f0,lista3+12
    addf    f20,f20,f2
    lf      f1,lista3+16    
    addf    f20,f20,f0
    lf      f2,lista3+20
    addf    f20,f20,f1
    lf      f0,lista3+24    
    addf    f20,f20,f2
    lf      f1,lista3+28
    addf    f20,f20,f0
    lf      f2,lista3+32
    addf    f20,f20,f1
    lf      f0,lista3+36
    addf    f20,f20,f2
    lf      f1,lista3+40
    addf    f20,f20,f0
    multf   f16,f26,f27     ; empezar a calcular checkA: (a1*a2)
    lf      f2,lista3+44
    addf    f20,f20,f1
    lf      f0,lista3+48
    addf    f20,f20,f2
    lf      f1,lista3+52
    addf    f20,f20,f0
    lf      f2,lista3+56
    addf    f20,f20,f1
    lf      f0,lista4       ; empezar a cargar lista4
    addf    f20,f20,f2
    lf      f1,lista4+4     ; lista4
    divf    f28,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    ;;
    ; CALCULO media a4
    ; cargar y sumar valores lista4
    lf      f2,lista4+8
    addf    f20,f0,f1
    lf      f0,lista4+12
    addf    f20,f20,f2
    lf      f1,lista4+16    
    addf    f20,f20,f0
    lf      f2,lista4+20
    addf    f20,f20,f1
    lf      f0,lista4+24
    addf    f20,f20,f2
    lf      f1,lista4+28
    addf    f20,f20,f0
    lf      f2,lista4+32
    addf    f20,f20,f1
    lf      f0,lista4+36
    addf    f20,f20,f2
    lf      f1,lista4+40
    addf    f20,f20,f0
    lf      f2,lista4+44
    addf    f14,f26,f28     ; empezar a calcular multiplicador: denominador = (a1+a3)
    multf   f17,f16,f28     ; parte checkA: (a12*a3)
    eqf     f14,f31         ; comprobar si denominador==0
    addf    f20,f20,f1
    bfpt    fin             ; finalizar si denominador==0
    lf      f0,lista4+48
    addf    f20,f20,f2
    lf      f1,lista4+52
    addf    f20,f20,f0
    lf      f2,lista4+56
    addf    f20,f20,f1
    lf      f0,lista5       ; empezar a cargar lista5
    addf    f20,f20,f2
    lf      f1,lista5+4     ; lista5
    divf    f29,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    ;;
    ; CALCULO media a5
    ; cargar y sumar valores lista5
    lf      f2,lista5+8
    addf    f20,f0,f1
    lf      f0,lista5+12
    addf    f20,f20,f2
    lf      f1,lista5+16
    addf    f20,f20,f0
    lf      f2,lista5+20
    addf    f20,f20,f1
    lf      f0,lista5+24
    addf    f20,f20,f2
    lf      f1,lista5+28
    addf    f20,f20,f0
    lf      f2,lista5+32
    addf    f20,f20,f1
    lf      f0,lista5+36
    addf    f20,f20,f2
    lf      f1,lista5+40
    addf    f20,f20,f0
    lf      f2,lista5+44
    addf    f15,f27,f29     ; parte multiplicador: (a2+a4)
    multf   f16,f17,f29     ; parte checkA: (a123*a4)
    ; simplificacion multiplicador matriz = ((a2/a5)+(a4/a5))/((a1/a5)+(a3/a5)) => (a2+a4)/(a1+a3)
    divf    f22,f15,f14     ; multiplicador = (a2+a4)/(a1+a3)
    addf    f20,f20,f1
    lf      f0,lista5+48
    addf    f20,f20,f2
    lf      f1,lista5+52
    addf    f20,f20,f0
    lf      f2,lista5+56
    addf    f20,f20,f1
    lf      f24,numFilas    ; cargar numFilas en f24
    addf    f20,f20,f2
    sf      a1,f26          ; almacena a1 en memoria
    divf    f30,f20,f21     ; a1 = sum(lista1) / tamano
    multf   f10,f29,f22     ; m42 = a4 * multi
    multf   f7,f28,f22      ; m32 = a3 * multi
    multf   f4,f27,f22      ; m22 = a2 * multi
    multf   f11,f29,f10     ; m43 = a4 * m42
    multf   f1,f26,f22      ; m12 = a1 * multi
    multf   f8,f28,f7       ; m33 = a3 * m32
    ;;

    addf    f23,f10,f7      ; inicio calculo checkM = m42 + m32
    sf      a2,f27          ; almacena a2 en memoria
    multf   f5,f27,f4       ; m23 = a2 * m22
    eqf     f30,f31         ; comprobar si a5==0
    addf    f23,f23,f4      ; checkM + m22
    bfpt    fin             ; finalizar si a5==0

    ; checkA = a1 * a2 * a3 * a4 * a5
    multf   f25,f16,f30     ; checkA (a1234*a5)
    sf      a3,f28          ; almacena a3 en memoria
    addf    f23,f23,f1      ; checkM + m12
    sf      a4,f29          ; almacena a4 en memoria
    multf   f2,f26,f1       ; m13 = a1 * m12
    sf      a5,f30          ; almacena a5 en memoria
    sf      checkA,f25      ; almacena checkA en memoria
    sf      M,f22           ; almacena m11
    addf    f23,f23,f11     ; checkM + m43
    multf   f12,f29,f11     ; m44 = a4 * m43
    sf      M+16,f22        ; almacena m21
    sf      M+32,f22        ; almacena m31
    sf      M+48,f22        ; almacena m41
    addf    f23,f23,f8      ; checkM + m33
    multf   f9,f28,f8       ; m34 = a3 * m33
    sf      M+52,f10        ; almacena m42
    sf      M+36,f7         ; almacena m32
    sf      M+20,f4         ; almacena m22
    addf    f23,f23,f5      ; checkM + m23
    multf   f6,f27,f5       ; m24 = a2 * m23
    sf      M+4,f1          ; almacena m12
    sf      M+56,f11        ; almacena m43
    sf      M+40,f8         ; almacena m33
    addf    f23,f23,f2      ; checkM + m13
    multf   f3,f26,f2       ; m14 = a1 * m13
    sf      M+24,f5         ; almacena m23
    addf    f23,f23,f12     ; checkM + m44
    sf      M+8,f2          ; almacena m13
    addf    f23,f23,f9      ; checkM + m34
    multf   f20,f22,f24     ; (m11 + m21 + m31 + m41) = multiplicador * numFilas (4)
    addf    f23,f23,f6      ; checkM + m24
    sf      M+60,f12        ; almacena m44
    addf    f23,f23,f3      ; checkM + m14
    sf      M+44,f9         ; almacena m34
    addf    f23,f23,f20     ; checkM + (m11 + m21 + m31 + m41)
    sf      M+28,f6         ; almacena m24 (2 Stall)
    sf      M+12,f3         ; almacena m14
    ; CALCULO checkM = m11 + m12 + m13 + m14 + m21 + ... + m44
    sf      checkM,f23      ; almacena checkM en memoria
    ; FIN ejecucion
    trap    0

tam10:
    ;;
    ; CALCULO media a1
    ; cargar y sumar valores lista1
    lf      f2,lista1+8
    addf    f20,f0,f1
    lf      f0,lista1+12
    addf    f20,f20,f2
    lf      f1,lista1+16
    addf    f20,f20,f0
    lf      f2,lista1+20
    addf    f20,f20,f1
    lf      f0,lista1+24
    addf    f20,f20,f2
    lf      f1,lista1+28
    addf    f20,f20,f0
    lf      f2,lista1+32
    addf    f20,f20,f1
    lf      f0,lista1+36
    addf    f20,f20,f2
    lf      f2,lista2       ; empezar a cargar lista2
    addf    f20,f20,f0
    lf      f0,lista2+4     ; lista2
    divf    f26,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    ;;
    ; CALCULO media a2
    ; cargar y sumar valores lista2
    lf      f1,lista2+8
    addf    f20,f2,f0
    lf      f2,lista2+12
    addf    f20,f20,f1
    lf      f0,lista2+16 
    addf    f20,f20,f2
    lf      f1,lista2+20
    addf    f20,f20,f0
    lf      f2,lista2+24
    addf    f20,f20,f1
    lf      f0,lista2+28
    addf    f20,f20,f2
    lf      f1,lista2+32
    addf    f20,f20,f0
    lf      f2,lista2+36
    addf    f20,f20,f1
    lf      f0,lista3       ; empezar a cargar lista3
    addf    f20,f20,f2
    lf      f1,lista3+4     ; lista3
    divf    f27,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    ;;
    ; CALCULO media a3
    ; cargar y sumar valores lista3
    lf      f2,lista3+8
    addf    f20,f0,f1
    lf      f0,lista3+12
    addf    f20,f20,f2
    lf      f1,lista3+16    
    addf    f20,f20,f0
    lf      f2,lista3+20
    addf    f20,f20,f1
    lf      f0,lista3+24    
    addf    f20,f20,f2
    lf      f1,lista3+28
    addf    f20,f20,f0
    lf      f2,lista3+32
    addf    f20,f20,f1
    lf      f0,lista3+36
    addf    f20,f20,f2
    lf      f1,lista4       ; empezar a cargar lista4
    addf    f20,f20,f0
    multf   f16,f26,f27     ; empezar a calcular checkA: (a1*a2)
    lf      f2,lista4+4     ; lista4
    divf    f28,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    ;;
    ; CALCULO media a4
    ; cargar y sumar valores lista4
    lf      f0,lista4+8
    addf    f20,f1,f2
    lf      f1,lista4+12
    addf    f20,f20,f0
    lf      f2,lista4+16    
    addf    f20,f20,f1
    lf      f3,lista4+20
    addf    f20,f20,f2
    lf      f0,lista4+24
    addf    f20,f20,f3
    lf      f1,lista4+28
    addf    f20,f20,f0
    lf      f2,lista4+32
    addf    f20,f20,f1
    lf      f0,lista4+36
    addf    f20,f20,f2
    lf      f1,lista5       ; empezar a cargar lista5
    addf    f20,f20,f0
    multf   f17,f16,f28     ; parte checkA: (a12*a3)
    addf    f14,f26,f28     ; empezar a calcular multiplicador: denominador = (a1+a3)
    lf      f2,lista5+4     ; lista5
    eqf     f14,f31         ; comprobar si denominador==0
    divf    f29,f20,f21     ; a1 = sum(lista1) / tamano
    bfpt    fin             ; finalizar si denominador==0
    ;;

    ;;
    ; CALCULO media a5
    ; cargar y sumar valores lista5
    lf      f0,lista5+8
    addf    f20,f1,f2
    lf      f1,lista5+12
    addf    f20,f20,f0
    lf      f2,lista5+16
    addf    f20,f20,f1
    lf      f0,lista5+20
    addf    f20,f20,f2
    lf      f1,lista5+24
    addf    f20,f20,f0
    lf      f2,lista5+28
    addf    f20,f20,f1
    lf      f0,lista5+32
    addf    f20,f20,f2
    lf      f1,lista5+36
    addf    f20,f20,f0
    lf      f24,numFilas    ; cargar numFilas en f24
    addf    f20,f20,f1
    multf   f16,f17,f29     ; parte checkA: (a123*a4)
    addf    f15,f27,f29     ; parte multiplicador: (a2+a4)
    ; simplificacion multiplicador matriz = ((a2/a5)+(a4/a5))/((a1/a5)+(a3/a5)) => (a2+a4)/(a1+a3)
    sf      a1,f26          ; almacena a1 en memoria
    divf    f22,f15,f14     ; multiplicador = (a2+a4)/(a1+a3)
    divf    f30,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    multf   f10,f29,f22     ; m42 = a4 * multi
    multf   f7,f28,f22      ; m32 = a3 * multi
    multf   f4,f27,f22      ; m22 = a2 * multi
    multf   f11,f29,f10     ; m43 = a4 * m42
    multf   f1,f26,f22      ; m12 = a1 * multi
    multf   f8,f28,f7       ; m33 = a3 * m32
    addf    f23,f10,f7      ; inicio calculo checkM = m42 + m32
    sf      a2,f27          ; almacena a2 en memoria
    multf   f5,f27,f4       ; m23 = a2 * m22
    eqf     f30,f31         ; comprobar si a5==0
    addf    f23,f23,f4      ; checkM + m22
    bfpt    fin             ; finalizar si a5==0

    ; checkA = a1 * a2 * a3 * a4 * a5
    multf   f25,f16,f30     ; checkA (a1234*a5)
    sf      a3,f28          ; almacena a3 en memoria
    addf    f23,f23,f1      ; checkM + m12
    sf      a4,f29          ; almacena a4 en memoria
    multf   f2,f26,f1       ; m13 = a1 * m12
    sf      a5,f30          ; almacena a5 en memoria
    sf      checkA,f25      ; almacena checkA en memoria
    sf      M,f22           ; almacena m11
    addf    f23,f23,f11     ; checkM + m43
    multf   f12,f29,f11     ; m44 = a4 * m43
    sf      M+16,f22        ; almacena m21
    sf      M+32,f22        ; almacena m31
    sf      M+48,f22        ; almacena m41
    addf    f23,f23,f8      ; checkM + m33
    multf   f9,f28,f8       ; m34 = a3 * m33
    sf      M+52,f10        ; almacena m42
    sf      M+36,f7         ; almacena m32
    sf      M+20,f4         ; almacena m22
    addf    f23,f23,f5      ; checkM + m23
    multf   f6,f27,f5       ; m24 = a2 * m23
    sf      M+4,f1          ; almacena m12
    sf      M+56,f11        ; almacena m43
    sf      M+40,f8         ; almacena m33
    addf    f23,f23,f2      ; checkM + m13
    multf   f3,f26,f2       ; m14 = a1 * m13
    sf      M+24,f5         ; almacena m23
    addf    f23,f23,f12     ; checkM + m44
    sf      M+8,f2          ; almacena m13
    addf    f23,f23,f9      ; checkM + m34
    multf   f20,f22,f24     ; (m11 + m21 + m31 + m41) = multiplicador * numFilas (4)
    addf    f23,f23,f6      ; checkM + m24
    sf      M+60,f12        ; almacena m44
    addf    f23,f23,f3      ; checkM + m14
    sf      M+44,f9         ; almacena m34
    addf    f23,f23,f20     ; checkM + (m11 + m21 + m31 + m41)
    sf      M+28,f6         ; almacena m24 (2 Stall)
    sf      M+12,f3         ; almacena m14
    ; CALCULO checkM = m11 + m12 + m13 + m14 + m21 + ... + m44
    sf      checkM,f23      ; almacena checkM en memoria
    ; FIN ejecucion
    trap    0

tam5:
    ;;
    ; CALCULO media a1
    ; cargar y sumar valores lista1
    lf      f2,lista1+8
    addf    f20,f0,f1
    lf      f0,lista1+12
    addf    f20,f20,f2
    lf      f1,lista1+16
    addf    f20,f20,f0
    lf      f2,lista2       ; empezar a cargar lista2
    addf    f20,f20,f1
    lf      f0,lista2+4     ; lista2
    divf    f26,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    ;;
    ; CALCULO media a2
    ; cargar y sumar valores lista2
    lf      f1,lista2+8
    addf    f20,f2,f0
    lf      f2,lista2+12
    addf    f20,f20,f1
    lf      f0,lista2+16 
    addf    f20,f20,f2
    lf      f1,lista3       ; empezar a cargar lista3
    addf    f20,f20,f0
    lf      f2,lista3+4     ; lista3
    divf    f27,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    ;;
    ; CALCULO media a3
    ; cargar y sumar valores lista3
    lf      f0,lista3+8
    addf    f20,f1,f2
    lf      f1,lista3+12
    addf    f20,f20,f0
    lf      f2,lista3+16    
    addf    f20,f20,f1
    lf      f0,lista4       ; empezar a cargar lista4
    addf    f20,f20,f2
    lf      f1,lista4+4     ; lista4
    divf    f28,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    ;;
    ; CALCULO media a4
    ; cargar y sumar valores lista4
    lf      f2,lista4+8
    addf    f20,f0,f1
    multf   f16,f26,f27     ; empezar a calcular checkA: (a1*a2)
    lf      f0,lista4+12
    addf    f20,f20,f2
    lf      f1,lista4+16    
    addf    f20,f20,f0
    lf      f2,lista5       ; empezar a cargar lista5
    addf    f20,f20,f1
    lf      f0,lista5+4     ; lista5
    divf    f29,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    ;;
    ; CALCULO media a5
    ; cargar y sumar valores lista5
    multf   f17,f16,f28     ; parte checkA: (a12*a3)
    addf    f14,f26,f28     ; empezar a calcular multiplicador: denominador = (a1+a3)
    lf      f1,lista5+8
    eqf     f14,f31         ; comprobar si denominador==0
    addf    f20,f2,f0
    bfpt    fin             ; finalizar si denominador==0
    lf      f2,lista5+12
    addf    f20,f20,f1
    lf      f0,lista5+16
    addf    f15,f27,f29     ; parte multiplicador: (a2+a4)
    ; simplificacion multiplicador matriz = ((a2/a5)+(a4/a5))/((a1/a5)+(a3/a5)) => (a2+a4)/(a1+a3)
    multf   f16,f17,f29     ; parte checkA: (a123*a4)
    divf    f22,f15,f14     ; multiplicador = (a2+a4)/(a1+a3)
    addf    f20,f20,f2
    lf      f24,numFilas    ; cargar numFilas en f24
    addf    f20,f20,f0
    sf      a1,f26          ; almacena a1 en memoria
    divf    f30,f20,f21     ; a1 = sum(lista1) / tamano
    ;;

    multf   f10,f29,f22     ; m42 = a4 * multi
    multf   f7,f28,f22      ; m32 = a3 * multi
    multf   f4,f27,f22      ; m22 = a2 * multi
    multf   f11,f29,f10     ; m43 = a4 * m42
    multf   f1,f26,f22      ; m12 = a1 * multi
    multf   f8,f28,f7       ; m33 = a3 * m32
    addf    f23,f10,f7      ; inicio calculo checkM = m42 + m32
    sf      a2,f27          ; almacena a2 en memoria
    multf   f5,f27,f4       ; m23 = a2 * m22
    eqf     f30,f31         ; comprobar si a5==0
    addf    f23,f23,f4      ; checkM + m22
    bfpt    fin             ; finalizar si a5==0

    ; checkA = a1 * a2 * a3 * a4 * a5
    multf   f25,f16,f30 ; checkA (a1234*a5)
    sf      a3,f28      ; almacena a3 en memoria
    addf    f23,f23,f1  ; checkM + m12
    sf      a4,f29      ; almacena a4 en memoria
    multf   f2,f26,f1   ; m13 = a1 * m12
    sf      a5,f30      ; almacena a5 en memoria
    sf      checkA,f25  ; almacena checkA en memoria
    sf      M,f22       ; almacena m11
    addf    f23,f23,f11 ; checkM + m43
    multf   f12,f29,f11 ; m44 = a4 * m43
    sf      M+16,f22    ; almacena m21
    sf      M+32,f22    ; almacena m31
    sf      M+48,f22    ; almacena m41
    addf    f23,f23,f8  ; checkM + m33
    multf   f9,f28,f8   ; m34 = a3 * m33
    sf      M+52,f10    ; almacena m42
    sf      M+36,f7     ; almacena m32
    sf      M+20,f4     ; almacena m22
    addf    f23,f23,f5  ; checkM + m23
    multf   f6,f27,f5   ; m24 = a2 * m23
    sf      M+4,f1      ; almacena m12
    sf      M+56,f11    ; almacena m43
    sf      M+40,f8     ; almacena m33
    addf    f23,f23,f2  ; checkM + m13
    multf   f3,f26,f2   ; m14 = a1 * m13
    sf      M+24,f5     ; almacena m23
    addf    f23,f23,f12 ; checkM + m44
    sf      M+8,f2      ; almacena m13
    addf    f23,f23,f9  ; checkM + m34
    multf   f20,f22,f24 ; (m11 + m21 + m31 + m41) = multiplicador * numFilas (4)
    addf    f23,f23,f6  ; checkM + m24
    sf      M+60,f12    ; almacena m44
    addf    f23,f23,f3  ; checkM + m14
    sf      M+44,f9     ; almacena m34
    addf    f23,f23,f20 ; checkM + (m11 + m21 + m31 + m41)
    sf      M+28,f6     ; almacena m24 (2 Stall)
    sf      M+12,f3     ; almacena m14
    ; CALCULO checkM = m11 + m12 + m13 + m14 + m21 + ... + m44
    sf      checkM,f23  ; almacena checkM en memoria
    ; FIN ejecucion
    trap    0
