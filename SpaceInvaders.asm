.model small
.stack 100h 

.data
;*********** ARREGLOS **********
arregloAliens1 DW 0000h, 1532h, 1542h, 1552h, 1562h, 1572h, 1582h, 1592h, 15A2h, 0000h ; Arreglo de aliens 1 (Primera fila)
arregloAliens2 DW 2322h, 2332h, 2342h, 2352h, 2362h, 2372h, 2382h, 2392h, 23A2h, 23B2h, 3122h, 3132h, 3142h, 3152h, 3162h, 3172h, 3182h, 3192h, 31A2h, 31B2h ; Arreglo de aliens 2 (Segunda y tercera fila)
arregloAliens3 DW 3F22h, 3F32h, 3F42h, 3F52h, 3F62h, 3F72h, 3F82h, 3F92h, 3FA2h, 3FB2h, 0000h, 4D32h, 4D42h, 4D52h, 4D62h, 4D72h, 4D82h, 4D92h, 4DA2h, 0000h ; Arreglo de aliens 3 (Cuarta y quinta fila)
arregloDisparos DW 12 DUP(0) ; Arreglo de disparos
arregloDisparosAliens DW 10 DUP(0) ; Arreglo de disparos de los aliens

;********* CONTROL X, Y ********
naveX DW 00A0h ; Posicion X inicial (Columna) de la nave
naveY DW 00BEh ; Posicion Y inicial (Fila) de la nave
controlarAliensX DB 0 ; Controlar la posicion X de los aliens (Para saber cuándo deben cambiar de dirección)
direccionMovimientoAliens DB 0 ; Direccion del movimiento de los aliens (0 = Derecha, 1 = Izquierda)
numeroRandom DB 0 ; Numero aleatorio para el disparo de los aliens

;******** VARIABLES AUX ********
naveLargo DW 0Ch ; Largo de la nave (Pixeles que tiene la nave de largo)
naveAncho DW 03h ; Ancho de la nave (Pixeles que tiene la nave de ancho)
tiempoAuxiliar DB 0 ; Tiempo anterior para las acciones (Comparar para ver si ya pasó cierto tiempo)
contadorMovimientoAliens DB 0 ; Contador para el movimiento de los aliens (Saber si ya deben moverse)
velocidadMovimientoAliens DB 30 ; Velocidad en la que los aliens deben moverse (Entre más bajo, más rápido, 1 es el mínimo) 40 p.d

;*********** PUNTOS ************
variableVictoria DB 0 ; Variable para saber si el jugador ganó (1 = Ganó, 0 = No ganó aún)
etiquetaPuntuacion DB "00", "$" ; Etiqueta para mostrar la puntuacion

.code
    ;***************** FUNCIONES (MACROS) ****************

    ; Macro para imprimir una cadena en pantalla
    ; ENTRADAS: texto = Cadena a imprimir
    ;           x = Fila donde se va a imprimir
    ;           y = Columna donde se va a imprimir
    ; SALIDAS: Imprime en la posicion x,y el texto recibido
    imprimirCadena MACRO texto, x, y
        mov AH, 02h
        mov BH, 00d
        mov DH, x
        mov DL, y
        int 10h

        mov AH, 09h
        lea DX, texto
        int 21h
    ENDM

    ; Macro para generar un número aleatorio entre 0 y un límite
    ; ENTRADAS: limite = Límite del número aleatorio
    ; SALIDAS: Genera un número aleatorio entre 0 y el límite y lo guarda en numeroRandom
    generarNumeroRandom MACRO limite
        MOV AH, 2Ch ; Obtener la hora actual del sistema para usar como semilla
        INT 21h ; Ejecutar la configuracion
        MOV AL, DH ; Pasar los segundos a AL
        
        XOR AH, AH ; AH = 0
        MOV BL, limite ; Mover a BL el límite del numero
        DIV BL ; Dividir AH / BL (Limite)
        MOV numeroRandom, AH ; Pasar residuo a numeroRandom
    ENDM

    ;generarNumeroRandomPar MACRO limite
        ;LOCAL bucleGenerarRandomP

        ;bucleGenerarRandomP:
        ;MOV AH, 2Ch ; Obtener la hora actual del sistema para usar como semilla
        ;INT 21h ; Ejecutar la configuracion
        ;MOV AL, DH ; Pasar los segundos a AL
        
        ;XOR AH, AH ; AH = 0
        ;MOV BL, limite ; Mover a BL el límite del numero
        ;DIV BL ; Dividir AH / BL (Limite)

        ;MOV BL, 2 ; Mover a BL el número 2
        ;MOV AL, AH ; Mover a AL el residuo
        ;DIV BL ; Dividir AL / 2
        ;CMP AL, 0 ; Comparar si el residuo es 0
        ;JNE bucleGenerarRandomP ; Si no es 0, volver a generar el número

        ;MOV numeroRandom, AH ; Pasar residuo a numeroRandom
    ;ENDM

    ; Macro para guardar la posicion de un disparo en el arreglo de disparos
    ; ENTRADAS: posicionDisparo = Posicion del disparo a guardar
    ; SALIDAS: No tiene
    guardarDisparo MACRO posicionDisparo
        LOCAL bucleGuardarDisparo, continuarGuardarDisparo, finGuardarDisparo
        MOV SI, 0
        bucleGuardarDisparo:
            CMP arregloDisparos[SI], 0 ; Comparar si la posicion actual del arreglo es 0
            JNE continuarGuardarDisparo ; Si no es 0, entonces continuar con el bucle
            MOV arregloDisparos[SI], posicionDisparo ; Guardar la posicion del disparo en el arreglo
            JMP finGuardarDisparo ; Salir del bucle
            continuarGuardarDisparo:
            ADD SI, 2 ; Incrementar en 2 el indice del arreglo
            CMP SI, 12 ; Comparar si el indice es menor a 10
            JNE bucleGuardarDisparo ; Si es menor, entonces continuar con el bucle
        finGuardarDisparo:
    ENDM

    ; Macro para guardar la posicion de un disparo en el arreglo de disparos de aliens
    ; ENTRADAS: posicionDisparo = Posicion del disparo a guardar
    ; SALIDAS: No tiene
    guardarDisparoAlien MACRO posicionDisparo
        LOCAL bucleGuardarDisparo, continuarGuardarDisparo, finGuardarDisparo
        MOV SI, 0
        bucleGuardarDisparo:
            CMP arregloDisparosAliens[SI], 0 ; Comparar si la posicion actual del arreglo es 0
            JNE continuarGuardarDisparo ; Si no es 0, entonces continuar con el bucle
            MOV arregloDisparosAliens[SI], posicionDisparo ; Guardar la posicion del disparo en el arreglo
            JMP finGuardarDisparo ; Salir del bucle
            continuarGuardarDisparo:
            ADD SI, 2 ; Incrementar en 2 el indice del arreglo
            CMP SI, 10 ; Comparar si el indice es 10
            JNE bucleGuardarDisparo ; Si no es 10, entonces sigue el bucle
        finGuardarDisparo:
    ENDM

    ; Macro para mover los aliens de un arreglo según la dirección del movimiento
    ; ENTRADAS: arregloAliensMover = Arreglo de aliens a mover, cantidadAliensMover = Cantidad de aliens en el arreglo
    ; SALIDAS: Mueve los aliens del arreglo según la dirección del movimiento
    moverAliens MACRO arregloAliensMover, cantidadAliensMover
        LOCAL bucleMoverAliens, moverAliensIzquierda, seguirBucleMoverAliens, salirMoverAliens

        MOV SI, 0
        bucleMoverAliens:
            CMP SI, cantidadAliensMover ; Comparar si la posicion actual del arreglo es la cantidad de aliens
            JE salirMoverAliens ; Si es la cantidad de aliens, salir del bucle
            MOV BX, arregloAliensMover[SI] ; Mover a BX la posicion actual del alien

            CMP BX, 0 ; Si el alien está muerto
            JE seguirBucleMoverAliens

            CMP direccionMovimientoAliens, 0
            JNE moverAliensIzquierda
            ADD BL, 5 ; Sumar 2 a la columna (Mover a la derecha 2 pixeles)
            MOV arregloAliensMover[SI], BX ; Guardar la nueva posicion del alien en el arreglo
            JMP seguirBucleMoverAliens ; Continuar con el siguiente alien

            moverAliensIzquierda:
            SUB BL, 5 ; Restar 2 a la columna (Mover a la izquierda 2 pixeles)
            MOV arregloAliensMover[SI], BX ; Guardar la nueva posicion del alien en el arreglo

        seguirBucleMoverAliens:
            ADD SI, 2 ; Sumar 2 al indice del arreglo (Siguiente alien)
            JMP bucleMoverAliens

        salirMoverAliens:
    ENDM

    ; Macro para bajar un pixel a todos los aliens de un arreglo
    ; ENTRADAS: arregloAliensBajar = Arreglo de aliens a bajar, cantidadAliensBajar = Cantidad de aliens en el arreglo
    ; SALIDAS: Baja un pixel a todos los aliens del arreglo
    bajarAliens MACRO arregloAliensBajar, cantidadAliensBajar
        LOCAL bucleBajarAliens, seguirBucleBajarAliens, salirBajarAliens

        MOV SI, 0
        bucleBajarAliens:
            CMP SI, cantidadAliensBajar ; Comparar si la posicion actual del arreglo es la cantidad de aliens
            JE salirBajarAliens ; Si es la cantidad de aliens, salir del bucle
            MOV BX, arregloAliensBajar[SI] ; Mover a BX la posicion actual del alien

            CMP BX, 0 ; Si el alien está muerto
            JE seguirBucleBajarAliens ; Si está muerto, continuar con el siguiente alien

            ADD BH, 4 ; Sumar 2 a la fila (Mover hacia abajo 2 pixeles)
            MOV arregloAliensBajar[SI], BX ; Guardar la nueva posicion del alien en el arreglo

        seguirBucleBajarAliens:
            ADD SI, 2 ; Sumar 2 al indice del arreglo (Siguiente alien)
            JMP bucleBajarAliens
        
        salirBajarAliens:
    ENDM

    ; Macro para mostrar los aliens en pantalla
    ; ENTRADAS: arregloAliensMostrar = Arreglo de aliens a mostrar, cantidadAliensMostrar = Cantidad de aliens en el arreglo
    ; SALIDAS: Muestra los aliens de un arreglo en pantalla
    mostrarAliens MACRO arregloAliensMostrar, cantidadAliensMostrar
        LOCAL bucleMostrarAliens, seguirBucleMostrarAliens, finalizarMostrarAliens

        MOV SI, 0
        bucleMostrarAliens:
            CMP SI, cantidadAliensMostrar ; Comparar si la posicion actual del arreglo es la cantidad de aliens
            JE finalizarMostrarAliens ; Si es la cantidad de aliens, entonces salir del bucle
            MOV BX, arregloAliensMostrar[SI] ; Mover a BX la posicion actual del alien

            CMP BX, 0 ; Si el alien está muerto
            JE seguirBucleMostrarAliens

            MOV DL, BH ; Mover a DX la fila (Y)
            XOR DH, DH
            MOV CL, BL ; Mover a CX la columna (X)
            XOR CH, CH

            dibujarAlien1 ; Llamar al macro para dibujar el alien 1

        seguirBucleMostrarAliens:
            ADD SI, 2 ; Sumar 2 al indice del arreglo (Siguiente alien)
            JMP bucleMostrarAliens

        finalizarMostrarAliens:
    ENDM

    ; Macro para verificar las colisiones de las balas con los aliens
    ; ENTRADAS: arregloAliensColisiones = Arreglo de aliens a verificar, cantidadAliensColisiones = Cantidad de aliens en el arreglo
    ; SALIDAS: Verifica las colisiones de las balas con los aliens y elimina los que colisionan
    colisionesBalasConAliens MACRO arregloAliensColisiones, cantidadAliensColisiones
        LOCAL bucleVerificarColisiones, seguirBucleVerificarColisiones, bucleVerificarColisionesAliens, seguirBucleVerificarColisionesAliens
        LOCAL ejecutarResta, salirVerificarColisiones, sumarCincoPuntos, sumarDosPuntos, corregirPuntos, aplicarAjuste

        MOV SI, 0
        bucleVerificarColisiones:
            CMP SI, 12 ; Comparar si la posicion actual del arreglo es 12
            JE salirVerificarColisiones ; Si es 12, entonces salir del bucle
            MOV BX, arregloDisparos[SI] ; Mover a BX la posicion actual del disparo

            CMP BX, 0 ; Comparar si la posicion actual del disparo es 0
            JE seguirBucleVerificarColisiones ; Si es 0, entonces salir del bucle

            MOV DI, 0
            bucleVerificarColisionesAliens:
                CMP DI, cantidadAliensColisiones ; Comparar si la posicion actual del arreglo es 20
                JE seguirBucleVerificarColisiones ; Si es 20, entonces salir del bucle de los Aliens

                MOV BX, arregloDisparos[SI] ; Mover a BX la posicion actual del disparo
                MOV AX, arregloAliensColisiones[DI] ; Mover a AX la posicion actual del alien

                CMP AX, 0 ; Si el alien está muerto
                JE seguirBucleVerificarColisionesAliens ; Si está muerto, continuar con el siguiente alien

                CMP BH, AH ; Comparar si la fila (Y) del disparo es igual a la del alien
                JA seguirBucleVerificarColisionesAliens ; Si es mayor, continuar con el bucle

                SUB AH, BH ; Restar la fila del alien con la del disparo
                CMP AH, 6 ; Comparar si la resta anterior es menor o igual a 6 (Hitbox vertical del alien)
                JA seguirBucleVerificarColisionesAliens ; Si es mayor, entonces seguir con el siguiente Alien

                CMP AL, BL ; Comparar si la columna (X) del disparo es igual a la del alien
                JAE ejecutarResta ; Si es mayor o igual, entonces restar la columna del alien con la del disparo directamente
                XCHG AL, BL ; De lo contrario, intercambiar los valores de AL y BL antes de la resta

                ejecutarResta:
                    SUB AL, BL ; Restar la columna mayor - la columna menor
                
                CMP AL, 4 ; Comparar si la resta anterior es menor o igual a 4 (Hitbox horizontal del alien)
                JA seguirBucleVerificarColisionesAliens ; Si es mayor, entonces seguir con el siguiente Alien

                MOV arregloDisparos[SI], 0 ; Eliminar disparo
                MOV arregloAliensColisiones[DI], 0 ; Eliminar alien

                ; SUMA DE PUNTOS AL JUGADOR
                MOV AH, etiquetaPuntuacion[0] ; Mover a AH el primer caracter de la puntuacion
                MOV AL, etiquetaPuntuacion[1] ; Mover a AL el segundo caracter de la puntuacion

                SUB AH, 30h ; Restar 30h a AH (Convertir de ASCII a número)
                SUB AL, 30h ; Restar 30h a AL (Convertir de ASCII a número)

                MOV CL, cantidadAliensColisiones ; Mover a AL la cantidad de aliens
                CMP CL, 20 ; Comparar si la cantidad de aliens es 20
                JNE sumarDosPuntos ; Si no es 20, sumar 2 puntos

                ADD AL, 3 ; Si es 20, sumar 3 puntos
                CMP AL, 10 ; Comparar si la puntuacion es mayor o igual a 10
                JAE corregirPuntos ; Si es mayor o igual a 10, sumar 5 puntos
                ADD AH, 30h ; Sumar 30h a AH (Convertir de número a ASCII)
                ADD AL, 30h ; Sumar 30h a AL (Convertir de número a ASCII)
                MOV etiquetaPuntuacion[0], AH ; Mover a la etiqueta el primer caracter de la puntuacion
                MOV etiquetaPuntuacion[1], AL ; Mover a la etiqueta el segundo caracter de la puntuacion
                JMP seguirBucleVerificarColisiones ; Continuar con el siguiente alien

                sumarDosPuntos:
                    ADD AL, 2 ; Sumar 2 puntos
                    CMP AL, 10 ; Comparar si la puntuacion es mayor o igual a 10
                    JAE corregirPuntos ; Si es mayor o igual a 10, sumar 5 puntos
                    ADD AH, 30h ; Sumar 30h a AH (Convertir de número a ASCII)
                    ADD AL, 30h ; Sumar 30h a AL (Convertir de número a ASCII)
                    MOV etiquetaPuntuacion[0], AH ; Mover a la etiqueta el primer caracter de la puntuacion
                    MOV etiquetaPuntuacion[1], AL ; Mover a la etiqueta el segundo caracter de la puntuacion
                    JMP seguirBucleVerificarColisiones ; Continuar con el siguiente alien

                corregirPuntos:
                    SUB AL, 10 ; Restar 10 a AL
                    ADD AH, 1 ; Sumar 1 a AH

                    CMP AH, 10 ; Comparar si la decena es mayor o igual a 10
                    JB aplicarAjuste ; Si no es mayor o igual a 10, aplicar ajuste
                    INC variableVictoria ; Si es mayor o igual a 10, entonces el jugador ganó
                    MOV etiquetaPuntuacion[0], '!' ; Mover a la etiqueta el primer caracter de la puntuacion
                    MOV etiquetaPuntuacion[1], '!' ; Mover a la etiqueta el segundo caracter de la puntuacion
                    JMP salirVerificarColisiones ; Salir de la verificacion de colisiones

                    aplicarAjuste:
                    ADD AH, 30h ; Sumar 30h a AH (Convertir de número a ASCII)
                    ADD AL, 30h ; Sumar 30h a AL (Convertir de número a ASCII)
                    MOV etiquetaPuntuacion[0], AH ; Mover a la etiqueta el primer caracter de la puntuacion
                    MOV etiquetaPuntuacion[1], AL ; Mover a la etiqueta el segundo caracter de la puntuacion
                    JMP seguirBucleVerificarColisiones ; Continuar con el siguiente alien

                ; SEGUIR CON EL BUCLE DE VERIFICAR COLISIONES
                seguirBucleVerificarColisionesAliens:
                    ADD DI, 2 ; Sumar 2 al indice del arreglo de aliens
                    JMP bucleVerificarColisionesAliens ; Volver al inicio del bucle de los aliens

            seguirBucleVerificarColisiones:
                ADD SI, 2 ; Sumar 2 al indice del arreglo
                JMP bucleVerificarColisiones ; Volver al inicio del bucle
        salirVerificarColisiones:
    ENDM

    ; Macro para dibujar el alien de la primera fila
    ; ENTRADAS: No tiene
    ; SALIDAS: Imprime en pantalla el alien de la primera fila según DX y CX
    dibujarAlien1 MACRO
        MOV AH, 0Ch ; Configurar para escribir un pixel
        MOV AL, 0Fh ; Blanco para el color del pixel
        MOV BH, 00h ; Numero de pagina (0 es la actual)
        INT 10h ; Dibujar pixel

        INC DX ; Incrementar DX (Una fila abajo)
        INT 10h ; Dibujar pixel

        DEC CX ; Decrementar CX (Una columna atrás)
        INT 10h ; Dibujar pixel

        ADD CX, 2 ; Sumar 2 a CX (Dos columnas adelante)
        INT 10h ; Dibujar pixel

        INC DX ; Incrementar DX (Una fila abajo)
        INT 10h ; Dibujar pixel

        INC CX ; Incrementar CX (Una columna adelante)
        INT 10h ; Dibujar pixel

        SUB CX, 2 ; Restar 2 a CX (Dos columnas atrás)
        INT 10h ; Dibujar pixel

        DEC CX ; Decrementar CX (Una columna atrás)
        INT 10h

        DEC CX ; Decrementar CX (Una columna atrás)
        INT 10h

        INC DX ; Incrementar DX (Una fila abajo)
        INT 10h ; Dibujar pixel

        DEC CX ; Decrementar CX (Una columna atrás)
        INT 10h

        ADD CX, 3 ; Sumar 2 a CX (Dos columnas adelante)
        INT 10h ; Dibujar pixel

        ADD CX, 2 ; Sumar 2 a CX (Dos columnas adelante)
        INT 10h ; Dibujar pixel

        INC CX ; Incrementar CX (Una columna adelante)
        INT 10h ; Dibujar pixel

        INC DX ; Incrementar DX (Una fila abajo)
        INT 10h ; Dibujar pixel

        DEC CX ; Decrementar CX (Una columna atrás)
        INT 10h

        DEC CX ; Decrementar CX (Una columna atrás)
        INT 10h

        DEC CX ; Decrementar CX (Una columna atrás)
        INT 10h

        DEC CX ; Decrementar CX (Una columna atrás)
        INT 10h

        DEC CX ; Decrementar CX (Una columna atrás)
        INT 10h

        DEC CX ; Decrementar CX (Una columna atrás)
        INT 10h

        INC DX ; Incrementar DX (Una fila abajo)
        INC CX ; Incrementar CX (Una columna adelante)
        INC CX ; Incrementar CX (Una columna adelante)
        INT 10h ; Dibujar pixel

        INC CX ; Incrementar CX (Una columna adelante)
        INC CX ; Incrementar CX (Una columna adelante)
        INT 10h ; Dibujar pixel

        INC DX ; Incrementar DX (Una fila abajo)
        INC CX ; Incrementar CX (Una columna adelante)
        INT 10h ; Dibujar pixel

        SUB CX, 4 ; Restar 2 a CX (Dos columnas atrás)
        INT 10h
    ENDM

    ;*************** FIN FUNCIONES (MACROS) **************

    ; PROCEDIMIENTO PRINCIPAL
    main PROC FAR

        ;*************** ASIGNACION DE SEGMENTOS ***************

        ASSUME CS:@CODE, DS:@DATA, SS:@STACK ; Asignar segmentos
        PUSH DS ; Guardar el segmento de datos en la pila
        XOR AX, AX ; Limpiar AX
        PUSH AX ; Guardar el valor de AX en la pila
        MOV AX, @DATA ; Cargar el segmento de datos en AX
        MOV DS, AX ; Cargar el segmento de datos en DS
        POP AX ; Sacar el primer elemento de la pila y guardarlo en AX
        POP AX ; Sacar el segundo elemento de la pila y guardarlo en AX

        ;*********** FIN DE ASIGNACION DE SEGMENTOS ***********

        ;*************** CONFIGURACION DE VIDEO ***************

        CALL limpiarPantalla ; Limpiar la pantalla (En negro)

        ;************ FIN DE CONFIGURACION DE VIDEO ***********

        ;******************* CICLO DE JUEGO *******************
        revisarTiempo:
            MOV AH, 2Ch ; Tomar la hora del sistema
            INT 21h ; DH = Segundos / DL = 1/100 segundos

            CMP DL, tiempoAuxiliar ; Comparar el tiempo actual con el anterior
            JE revisarTiempo ; Si son iguales, revisar otra vez

            MOV tiempoAuxiliar, DL ; Actualizar tiempo

            ; Verificar si se deben mover los aliens
            MOV AH, velocidadMovimientoAliens ; Mover el tiempo en que se deben mover los aliens a AH
            CMP contadorMovimientoAliens, AH ; Comparar si ya se deben mover los aliens
            JNE noMoverAliens ; Si aún no llega a 40 el contador, no mover los aliens
            CALL llamarMoverAliens ; Mover los aliens
            ;CALL dispararAlien ; Hacer que un alien dispare
            MOV contadorMovimientoAliens, 0 ; Resetear el contador de movimiento de aliens

            noMoverAliens:
            INC contadorMovimientoAliens

            ; Demás acciones del juego
            CALL accionarNave ; Recibir la accion para la nave
            CALL limpiarPantalla ; Limpiar la pantalla (En negro)
            CALL dibujarMarco ; Dibujar el marco de juego
            CALL dibujarNave ; Dibujar la nave
            CALL mostrarDisparos ; Mostrar los disparos guardados
            CALL llamarMostrarAliens ; Mostrar todos los aliens
            CALL verificarColisiones ; Verificar las colisiones de bala
            ;CALL mostrarDisparosAliens
            imprimirCadena etiquetaPuntuacion, 1, 1 ; Llamar al macro para imprimir la puntuacion

            JMP revisarTiempo
        RET

        ;***************** FIN CICLO DE JUEGO *****************

        ;****************** LIMPIAR PANTALLA ******************

        ; Procedimiento para limpiar la pantalla y configurarla nuevamente
        ; ENTRADAS: No recibe
        ; SALIDAS: Configura la pantalla de nuevo y la pone en negro
        limpiarPantalla PROC NEAR
            MOV AH, 00h ; Poner la configuracion en modo de video
            MOV AL, 0Dh ; 320x200 256 colores
            INT 10h ; Ejecutar la configuracion

            MOV AH, 0Bh ; Configurar para paleta de colores
            MOV BH, 00h ; Para el color de fondo
            MOV BL, 00h ; Negro para el color de fondo
            INT 10h ; Ejecutar la configuracion
            RET ; Retornar procedimiento
        limpiarPantalla ENDP

        ;**************** FIN LIMPIAR PANTALLA ****************

        ;******************** DIBUJAR MARCO *******************

        ; Procedimiento para dibujar un marco divisor en la zona de juego
        ; ENTRADAS: No recibe
        ; SALIDAS: Imprime en la pantalla el marco correspondiente
        dibujarMarco PROC NEAR
            MOV AH, 0Ch ; Configurar para escribir un pixel
            MOV AL, 0Fh ; Blanco para el color del pixel
            MOV BH, 00h ; Numero de pagina (0 es la actual)

            MOV CX, 270
            MOV DX, 196
            bucleMarcoDerecho:
                CMP DX, 12
                JE finDibujarMarco
                INT 10h ; Dibujar pixel
                DEC DX ; Decrementar DX (Fila anterior)
                JMP bucleMarcoDerecho
            
            finDibujarMarco:
            RET ; Retornar procedimiento

        dibujarMarco ENDP

        ;****************** FIN DIBUJAR MARCO *****************

        ;******************** ACCIONAR NAVE *******************

        ; Procedimiento para recibir una accion del usuario y mover o disparar la nave
        ; ENTRADAS: Lee la entrada del teclado
        ; SALIDAS: Si hay una tecla presionada y es una de movimiento o disparo, lo ejecuta
        accionarNave PROC NEAR
            ; Ver si hay una tecla presionada, de lo contrario, salir del procedimiento

            MOV AH, 01h ; Configurar para leer si hay una tecla presionada
            INT 16h
            JZ salirAccionarNave ; Si no hay una tecla presionada, entonces salir del movimiento de nave

            ; Ver cuál tecla está presionada (Al == caracter en ASCII)

            MOV AH, 0 ; Configurar para leer la tecla presionada
            INT 16h

            ; Si toca 'D' o 'd', entonces ir a la derecha

            CMP AL, 44h ; 44h == 'D'
            JE moverDerecha

            CMP AL, 64h ; 64h == 'd'
            JE moverDerecha

            ; Si toca 'A' o 'a', entonces ir a la izquierda

            CMP AL, 41h ; 41h == 'A'
            JE moverIzquierda

            CMP AL, 61h ; 61h == 'a'
            JE moverIzquierda

            ; Si toca 'Espacio', entonces disparar

            CMP AL, 20h ; 20h == 'Espacio'
            JE disparar

            JNE salirAccionarNave ; Si no toca ninguna de las teclas, entonces salir del movimiento de nave

            moverDerecha:
                CMP naveX, 248 ; 248 es el maximo de la columna (Para que no se salga y quede margen)
                JAE salirAccionarNave ; Si es mayor o igual a 248, entonces salir del movimiento de nave

                ADD naveX, 3 ; Sumar 3 a la columna (Mover a la derecha 3 pixeles)
                JMP salirAccionarNave
            
            moverIzquierda:
                CMP naveX, 28 ; 28 es el minimo de la columna (Para que no se salga y quede margen)
                JBE salirAccionarNave ; Si es menor o igual a 60, entonces salir del movimiento de nave

                SUB naveX, 3 ; Restar 3 a la columna (Mover a la izquierda 3 pixeles)
                JMP salirAccionarNave
            
            disparar:
                MOV CX, naveX ; CX = Columna (X)
                MOV DX, naveY ; DX = Fila (Y)
                SUB DX, 2 ; Restar 2 a la fila (Dos filas más arriba)
                ADD CX, 6 ; Sumar 4 a la columna (Mover a la derecha 4 pixeles)

                ; Guardar la posicion del disparo en el arreglo
                MOV BH, DL ; Mover a BH la fila (Y)
                MOV BL, CL ; Mover a BL la columna (X)

                guardarDisparo BX ; Llamar al macro para guardar el disparo

                JMP salirAccionarNave

            salirAccionarNave:
            RET ; Retornar procedimiento
        accionarNave ENDP

        ;****************** FIN ACCIONAR NAVE *****************

        ;******************* DIBUJAR NAVE *********************

        ; Procedimiento para dibujar la nave e imprimirla en pantalla
        ; ENTRADAS: Lee la posición (x,y) de la nave
        ; SALIDAS: Imprime en pantalla la nave dibujada
        dibujarNave PROC NEAR
            MOV CX, naveX ; CX = Columna (X)
            MOV DX, naveY ; DX = Fila (Y)

            dibujarNaveHorizontal:
                CMP DX, naveY ; Comparar DX (Fila actual) con naveY (Primera fila)
                JNE continuarDibujoHorizontal ; Si no son iguales, continúa con el dibujo
                CMP CX, naveX ; Comparar CX (Columna actual) con naveX (Primera columna)
                JE continuarSinDibujoHorizontal ; Si son iguales, no dibujarlo
                MOV AX, CX ; Mover a AX la columna actual CX
                SUB AX, naveX ; CX - naveX (Posicion X de la nave)
                CMP AX, naveLargo ; Comparar para ver si la resta anterior es igual al largo de la nave
                JE continuarSinDibujoHorizontal ; Si es igual, no dibujarlo

                continuarDibujoHorizontal:
                MOV AH, 0Ch ; Configurar para escribir un pixel
                MOV AL, 05h ; Morado para el color del pixel
                MOV BH, 00h ; Numero de pagina (0 es la actual)

                INT 10h ; Dibujar pixel
                continuarSinDibujoHorizontal:
                INC CX ; Incrementar CX (columna)

                MOV AX, CX ; Mueve a AX la CX (columna)
                SUB AX, naveX ; CX - naveX (Posicion X de la nave)
                CMP AX, naveLargo ; Comparar para ver si la resta anterior es mayor al largo de la nave
                JBE dibujarNaveHorizontal ; Si no es mayor, entonces dibuja otro pixel

            MOV CX, naveX ; Restablecer la columna en la posicion inicial (X)
            INC DX ; Incrementar DX (siguiente fila)
            MOV AX, DX ; Mueve a AX la DX (fila)
            SUB AX, naveY ; DX - naveY (Posicion Y de la nave)
            CMP AX, naveAncho ; Comparar para ver si la resta anterior es mayor al ancho de la nave
            JBE dibujarNaveHorizontal ; Si no es mayor, entonces dibuja otra linea de pixeles
            
            ; Dibujar la pistola de la nave:

            MOV CX, naveX ; CX = Columna (X)
            MOV DX, naveY ; DX = Fila (Y)
            DEC DX ; Decrementar DX (Una fila más arriba)
            ADD CX, 5 ; Sumar 4 a la columna (Mover a la derecha 4 pixeles)

            dibujarNavePistola:
                MOV AH, 0Ch ; Configurar para escribir un pixel
                MOV AL, 05h ; Morado para el color del pixel
                MOV BH, 00h ; Numero de pagina (0 es la actual)

                INT 10h ; Dibujar pixel
                INC CX ; Incrementar CX (columna)

                MOV AX, CX ; Mueve a AX la CX (columna)
                SUB AX, naveX ; CX - naveX (Posicion X de la nave)
                CMP AX, 07h ; Comparar para ver si la resta anterior es mayor a 8
                JBE dibujarNavePistola ; Si no es mayor, entonces dibuja otro pixel
            
            ; Dibujar el último pixel de la pistola
            MOV CX, naveX ; CX = Columna (X)
            MOV DX, naveY ; DX = Fila (Y)
            SUB DX, 2 ; Restar 2 a la fila (Dos filas más arriba)
            ADD CX, 6 ; Sumar 4 a la columna (Mover a la derecha 4 pixeles)
            
            MOV AH, 0Ch ; Configurar para escribir un pixel
            MOV AL, 05h ; Morado para el color del pixel
            MOV BH, 00h ; Numero de pagina (0 es la actual)
            INT 10h ; Dibujar pixel

            RET ; Retornar procedimiento
        dibujarNave ENDP

        ;**************** FIN DE DIBUJAR NAVE *****************

        ;***************** MOSTRAR DISPAROS *******************
        
        ; Procedimiento para imprimir todos los disparos que están en el arreglo
        ; ENTRADAS: No Recibe
        ; SALIDAS: Imprime en pantalla una secuencia de disparos y deja lista la siguiente
        mostrarDisparos PROC NEAR
            MOV SI, 0 ; Inicializar el indice del arreglo en 0
            bucleMostrarDisparos:
                CMP SI, 12 ; Comparar si la posicion actual del arreglo es 12
                JE finMostrarDisparos ; Si es 12, entonces salir del bucle
                MOV BX, arregloDisparos[SI] ; Mover a BX la posicion actual del disparo

                CMP BX, 0 ; Comparar si la posicion actual del disparo es 0
                JE seguirBucleDisparos ; Si es 0, entonces continuar con el bucle

                CMP BH, 5 ; Comparar si la fila (Y) es 5
                JBE terminarDisparo ; Si es 5, entonces terminar el disparo y restablecer el arreglo

                MOV DL, BH ; Mover a DX la fila (Y)
                XOR DH, DH
                MOV CL, BL ; Mover a CX la columna (X)
                XOR CH, CH

                SUB BH, 5
                MOV arregloDisparos[SI], BX ; Guardar la nueva posicion del disparo en el arreglo

                MOV AH, 0Ch ; Configurar para escribir un pixel
                MOV AL, 05h ; Morado para el color del pixel
                MOV BH, 00h ; Numero de pagina (0 es la actual)
                INT 10h ; Dibujar pixel

                INC DX ; Incrementar la fila (Mover hacia abajo 1 pixel)
                INT 10h ; Dibujar pixel

                INC DX ; Incrementar la fila (Mover hacia abajo 1 pixel)
                INT 10h ; Dibujar pixel

                JMP seguirBucleDisparos ; Volver al inicio del bucle

                terminarDisparo:
                MOV arregloDisparos[SI], 0 ; Restablecer la posicion del disparo en el arreglo

                seguirBucleDisparos:
                ADD SI, 2 ; Sumar 2 al indice del arreglo
                JMP bucleMostrarDisparos ; Volver al inicio del bucle
            finMostrarDisparos:
                RET ; Retornar procedimiento
        mostrarDisparos ENDP

        ;*************** FIN MOSTRAR DISPAROS *****************

        ;************* MOSTRAR DISPAROS ALIENS ****************
        
        ; Procedimiento para imprimir todos los disparos que están en el arreglo
        ; ENTRADAS: No Recibe
        ; SALIDAS: Imprime en pantalla una secuencia de disparos y deja lista la siguiente
        ;mostrarDisparosAliens PROC NEAR
        ;    MOV SI, 0 ; Inicializar el indice del arreglo en 0
        ;    bucleMostrarDisparosAliens:
        ;       CMP SI, 10 ; Comparar si la posicion actual del arreglo es 10
        ;        JE finMostrarDisparosAliens ; Si es 12, entonces salir del bucle
        ;        MOV BX, arregloDisparosAliens[SI] ; Mover a BX la posicion actual del disparo

        ;        CMP BX, 0 ; Comparar si la posicion actual del disparo es 0
        ;        JE seguirBucleDisparosAliens ; Si es 0, entonces continuar con el bucle

        ;        CMP BH, 5 ; Comparar si la fila (Y) es 5
        ;        JBE terminarDisparoAliens ; Si es 5, entonces terminar el disparo y restablecer el arreglo

        ;        MOV DL, BH ; Mover a DX la fila (Y)
        ;        XOR DH, DH
        ;        MOV CL, BL ; Mover a CX la columna (X)
        ;        XOR CH, CH

        ;        ADD BH, 3
        ;        MOV arregloDisparosAliens[SI], BX ; Guardar la nueva posicion del disparo en el arreglo

        ;        MOV AH, 0Ch ; Configurar para escribir un pixel
        ;        MOV AL, 0Fh ; Morado para el color del pixel
        ;        MOV BH, 00h ; Numero de pagina (0 es la actual)
        ;        INT 10h ; Dibujar pixel

        ;        INC DX ; Incrementar la fila (Mover hacia abajo 1 pixel)
        ;        INT 10h ; Dibujar pixel

        ;        INC DX ; Incrementar la fila (Mover hacia abajo 1 pixel)
        ;        INT 10h ; Dibujar pixel

        ;        JMP seguirBucleDisparosAliens ; Volver al inicio del bucle

        ;        terminarDisparoAliens:
        ;        MOV arregloDisparosAliens[SI], 0 ; Restablecer la posicion del disparo en el arreglo

        ;        seguirBucleDisparosAliens:
        ;        ADD SI, 2 ; Sumar 2 al indice del arreglo
        ;        JMP bucleMostrarDisparosAliens ; Volver al inicio del bucle
        ;    finMostrarDisparosAliens:
        ;        RET ; Retornar procedimiento
        ;mostrarDisparosAliens ENDP

        ;*********** FIN MOSTRAR DISPAROS ALIENS **************

        ;****************** MOSTRAR ALIENS ********************

        ; Procedimiento para imprimir todos los aliens que estén vivos
        ; ENTRADAS: No Recibe
        ; SALIDAS: Imprime en pantalla todos los aliens vivos
        llamarMostrarAliens PROC NEAR
            mostrarAliens arregloAliens1, 20 ; Mostrar los aliens de la primera fila
            mostrarAliens arregloAliens2, 40 ; Mostrar los aliens de la segunda y tercera fila
            mostrarAliens arregloAliens3, 40 ; Mostrar los aliens de la cuarta y quinta fila

                RET ; Retornar procedimiento
        llamarMostrarAliens ENDP

        ;**************** FIN MOSTRAR ALIENS ******************

        ;*************** VERIFICAR COLISIONES *****************

        ; Procedimiento para verificar si un disparo colisiona con un alien
        ; ENTRADAS: No Recibe
        ; SALIDAS: Verifica si un disparo colisiona con un alien y lo elimina
        verificarColisiones PROC NEAR
            colisionesBalasConAliens arregloAliens1, 20 ; Verificar colisiones con los aliens de la primera fila
            colisionesBalasConAliens arregloAliens2, 40 ; Verificar colisiones con los aliens de la segunda y tercera fila
            colisionesBalasConAliens arregloAliens3, 40 ; Verificar colisiones con los aliens de la cuarta y quinta fila

            RET ; Retornar procedimiento
        verificarColisiones ENDP

        ;************* FIN VERIFICAR COLISIONES ***************

        ;****************** DISPARAR ALIEN ********************

        ; Procedimiento para disparar un alien aleatorio
        ; ENTRADAS: No Recibe
        ; SALIDAS: Dispara un alien aleatorio
        ;dispararAlien PROC NEAR
        ;    inicioDispararAlien:
        ;    generarNumeroRandom 3 ; Generar un número aleatorio entre 0 y 2
        ;    MOV AL, numeroRandom ; Mover a AL el número aleatorio
        ;    CMP AL, 0 ; Comparar si el número aleatorio es 0
        ;    JE esCero
        ;    CMP AL, 1 ; Comparar si el número aleatorio es 1
        ;    JE esUno
        ;    JMP esDos ; Si no es 0 ni 1, entonces es 2

            ; Si es cero:
        ;    esCero:
        ;        generarNumeroRandomPar 19 ; Generar un número aleatorio entre 0 y 18
        ;        XOR AH, AH ; Limpiar AH
        ;        MOV AL, numeroRandom ; Mover a AL el número aleatorio
                
        ;        MOV SI, AX ; Mover a SI el número aleatorio
        ;        MOV BX, arregloAliens1[SI] ; Mover a BX la posicion del alien
        ;        CMP BX, 0 ; Comparar si el alien está muerto
        ;        JE inicioDispararAlien ; Si está muerto, volver a empezar

        ;        JMP enviarDisparoAlien ; Si no está muerto, entonces disparar

            ; Si es uno:
        ;    esUno:
        ;        generarNumeroRandomPar 39 ; Generar un número aleatorio entre 0 y 38
        ;        XOR AH, AH ; Limpiar AH
        ;        MOV AL, numeroRandom ; Mover a AL el número aleatorio

        ;        MOV SI, AX ; Mover a SI el número aleatorio
        ;        MOV BX, arregloAliens2[SI] ; Mover a BX la posicion del alien
        ;        CMP BX, 0 ; Comparar si el alien está muerto
        ;        JE inicioDispararAlien ; Si está muerto, volver a empezar

        ;        JMP enviarDisparoAlien ; Si no está muerto, entonces disparar

            ; Si es dos:
        ;    esDos:
        ;        generarNumeroRandomPar 39 ; Generar un número aleatorio entre 0 y 38
        ;        XOR AH, AH ; Limpiar AH
        ;        MOV AL, numeroRandom ; Mover a AL el número aleatorio

        ;        MOV SI, AX ; Mover a SI el número aleatorio
        ;        MOV BX, arregloAliens3[SI] ; Mover a BX la posicion del alien
        ;        CMP BX, 0 ; Comparar si el alien está muerto
        ;        JE inicioDispararAlien ; Si está muerto, volver a empezar

        ;        JMP enviarDisparoAlien ; Si no está muerto, entonces disparar

        ;    enviarDisparoAlien:
                ; BH = Fila (Y) / BL = Columna (X)
        ;        ADD DX, 4 ; Sumar 4 a la fila (Cuatro filas más abajo)
        ;        guardarDisparoAlien BX ; Llamar al macro para guardar el disparo

        ;dispararAlien ENDP

        ;**************** FIN DISPARAR ALIEN ******************

        ;******************* MOVER ALIENS *********************

        ; Procedimiento para mover todos los aliens que estén vivos
        ; ENTRADAS: No Recibe
        ; SALIDAS: Mueve el x,y de todos los aliens vivos
        llamarMoverAliens PROC NEAR
            CMP controlarAliensX, 15
            JNE seguirMoverAliens

            ; Si está en algún límite, entonces mover a todos los aliens hacia abajo y cambiar la dirección
            bajarAliens arregloAliens1, 20
            bajarAliens arregloAliens2, 40
            bajarAliens arregloAliens3, 40

            XOR direccionMovimientoAliens, 1 ; Cambiar la dirección de los aliens
            MOV controlarAliensX, 0 ; Resetear el controlador de aliens
            JMP salirLlamarMoverAliens

            ; Si no está en algún límite, entonces mover a todos los aliens hacia la dirección actual
            seguirMoverAliens:
                moverAliens arregloAliens1, 20
                moverAliens arregloAliens2, 40
                moverAliens arregloAliens3, 40
            
            salirLlamarMoverAliens:
                INC controlarAliensX ; Incrementar el controlador de aliens
                RET ; Retornar procedimiento
        llamarMoverAliens ENDP

        ;**************** FIN MOVER ALIENS ********************

    main ENDP

END