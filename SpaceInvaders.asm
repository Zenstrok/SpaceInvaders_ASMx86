.model small
.stack 100h
INCLUDE macros.asm

.data
;*********** ARREGLOS **********
arregloAliens1 DW 0000h, 1532h, 1542h, 1552h, 1562h, 1572h, 1582h, 1592h, 15A2h, 0000h ; Arreglo de aliens 1 (Primera fila)
arregloAliens2 DW 2322h, 2332h, 2342h, 2352h, 2362h, 2372h, 2382h, 2392h, 23A2h, 23B2h, 3122h, 3132h, 3142h, 3152h, 3162h, 3172h, 3182h, 3192h, 31A2h, 31B2h ; Arreglo de aliens 2 (Segunda y tercera fila)
arregloAliens3 DW 3F22h, 3F32h, 3F42h, 3F52h, 3F62h, 3F72h, 3F82h, 3F92h, 3FA2h, 3FB2h, 0000h, 4D32h, 4D42h, 4D52h, 4D62h, 4D72h, 4D82h, 4D92h, 4DA2h, 0000h ; Arreglo de aliens 3 (Cuarta y quinta fila)
arregloDisparos DW 4 DUP(0) ; Arreglo de disparos
arregloDisparosAliens DW 6 DUP(0) ; Arreglo de disparos de los aliens

;********* CONTROL X, Y ********
naveX DW 00A0h ; Posicion X inicial (Columna) de la nave
naveY DW 00BEh ; Posicion Y inicial (Fila) de la nave
controlarAliensX DB 0 ; Controlar la posicion X de los aliens (Para saber cuándo deben cambiar de dirección)
direccionMovimientoAliens DB 0 ; Direccion del movimiento de los aliens (0 = Derecha, 1 = Izquierda)
numeroRandom DB 0 ; Numero aleatorio para el disparo de los aliens

;******** VARIABLES AUX ********
etiquetaVidas DB 03h, 03h, 03h, "$" ; Etiqueta para mostrar las vidas de la nave
tiempoAuxiliar DB 0 ; Tiempo anterior para las acciones (Comparar para ver si ya pasó cierto tiempo)
contadorMovimientoAliens DB 0 ; Contador para el movimiento de los aliens (Saber si ya deben moverse)
contadorVelocidadAliens DB 0 ; Contador para la velocidad de los aliens (Saber si debe acelerarse su movimiento)
velocidadMovimientoAliens DB 19 ; Velocidad en la que los aliens deben moverse (Entre más bajo, más rápido, 1 es el mínimo) 39 p.d

;*********** PUNTOS ************
variableVictoria DB 0 ; Variable para saber si el jugador ganó (1 = Ganó, 0 = No ganó aún, 2 = Perdió)
etiquetaPuntuacion DB "00", "$" ; Etiqueta para mostrar la puntuacion
mensajeVictoria DB "VICTORIA!", "$" ; Mensaje de victoria
mensajeDerrota DB "DERROTA!", "$" ; Mensaje de derrota

.code
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
            JNE noMoverAliens ; Si el contador aún no llega al limite, no mover los aliens

            ; Si se deben mover los aliens:
            CALL llamarMoverAliens ; Mover los aliens
            CALL dispararAlien ; Hacer que un alien dispare
            MOV contadorMovimientoAliens, 0 ; Resetear el contador de movimiento de aliens

            CMP contadorVelocidadAliens, 10 ; Comparar si ya se debe acelerar el movimiento de los aliens (Si el contador llega a 10)
            JNE noIncrementarVelocidadAliens ; Si no se debe acelerar, no hacer nada

            CMP velocidadMovimientoAliens, 1 ; Comparar si la velocidad de movimiento de los aliens es 1
            JE noMoverAliens ; Si es 1, no acelerar el movimiento de los aliens

            ;Si se deben acelerar los aliens:
            SUB velocidadMovimientoAliens, 2 ; Decrementar la velocidad de movimiento de los aliens
            MOV contadorVelocidadAliens, 0 ; Resetear el contador de velocidad de los aliens
            noIncrementarVelocidadAliens:
                INC contadorVelocidadAliens ; Incrementar el contador de velocidad de los aliens
                
            noMoverAliens:
                INC contadorMovimientoAliens ; Incrementar el contador de movimiento de los aliens

            ; Demás acciones del juego
            CALL verificarPartida ; Ver si ya se ganó o perdió
            CALL accionarNave ; Recibir la accion para la nave
            CALL limpiarPantalla ; Limpiar la pantalla (En negro)
            CALL dibujarMarco ; Dibujar el marco de juego
            CALL dibujarNave ; Dibujar la nave
            CALL mostrarDisparos ; Mostrar los disparos guardados
            CALL llamarMostrarAliens ; Mostrar todos los aliens
            CALL verificarColisiones ; Verificar las colisiones de bala
            CALL mostrarDisparosAliens ; Mostrar los disparos de los aliens
            imprimirCadena etiquetaPuntuacion, 1, 1 ; Llamar al macro para imprimir la puntuacion
            imprimirCadena etiquetaVidas, 1, 30 ; Llamar al macro para imprimir las vidas

            JMP revisarTiempo ; Volver a otro ciclo
        RET

        ;***************** FIN CICLO DE JUEGO *****************

        ;****************** LIMPIAR PANTALLA ******************

        ; Procedimiento para limpiar la pantalla y configurarla nuevamente
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

        verificarPartida PROC NEAR
            CMP variableVictoria, 1 ; Si ganó
            JE imprimirVictoria ; Imprimir mensaje de victoria
            CMP variableVictoria, 2 ; Si perdió
            JE imprimirDerrota ; Imprimir mensaje de derrota
            JNE finalizarVerificacion ; Si no ha ganado ni perdido, continuar con el juego

            imprimirVictoria:
                imprimirCadena mensajeVictoria, 10, 10 ; Imprimir mensaje de victoria
                JMP finalizarPrograma ; Salir del programa
            
            imprimirDerrota:
                imprimirCadena mensajeDerrota, 10, 10 ; Imprimir mensaje de derrota
                JMP finalizarPrograma ; Salir del programa

            finalizarVerificacion:
                RET ; Retornar procedimiento
        verificarPartida ENDP

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
        ; SALIDAS: Imprime en pantalla la nave dibujada (Va a ser 13x5)
        dibujarNave PROC NEAR
            MOV CX, naveX ; CX = Columna (X)
            MOV DX, naveY ; DX = Fila (Y)
            MOV AH, 0Ch ; Configurar para escribir un pixel
            MOV AL, 05h ; Morado para el color del pixel
            MOV BH, 00h ; Numero de pagina (0 es la actual)
            INT 10h ; Dibujar pixel
            
            INC DX ; Incrementar DX (Una fila abajo)
            DEC CX ; Decrementar CX (Una columna atrás)

            segundaFila:
                INT 10h ; Dibujar pixel
                MOV BX, naveX ; Mover a BX la columna (X)
                INC BX ; Incrementar BX (Una columna adelante)
                CMP CX, BX ; Comparar si la columna actual es igual a la columna de la nave sumada
                INC CX ; Incrementar CX (Una columna adelante)
                JBE segundaFila ; Si es menor o igual, entonces continuar con la segunda fila

            INC DX ; Incrementar DX (Una fila abajo)
            ADD CX, 3 ; Sumar 3 a CX (3 columnas adelante)

            terceraFila:
                INT 10h ; Dibujar pixel
                MOV BX, naveX ; Mover a BX la columna (X)
                SUB BX, 4 ; Restar 4 a BX (4 columnas atrás)
                CMP CX, BX ; Comparar si la columna actual es igual a la columna de la nave restada
                DEC CX ; Decrementar CX (Una columna atrás)
                JAE terceraFila ; Si es mayor o igual, entonces continuar con las otras filas

            INC DX ; Incrementar DX (Una fila abajo)
            JMP otrasFilas

            antesOtrasFilas:
                INC DX ; Incrementar DX (Una fila abajo)
                SUB CX, 13 ; Restar 13 a CX (13 columnas atrás)
            otrasFilas:
                INT 10h ; Dibujar pixel
                MOV BX, naveX ; Mover a BX la columna (X)
                ADD BX, 6 ; Sumar 6 a BX (6 columnas adelante)
                CMP CX, BX ; Comparar si la columna actual es igual a la columna de la nave sumada
                INC CX ; Incrementar CX (Una columna adelante)
                JBE otrasFilas ; Si es menor o igual, entonces continuar con las otras filas

                MOV BX, naveY ; Mover a BX la fila (Y)
                ADD BX, 3 ; Sumar 5 a BX (5 filas abajo)
                CMP DX, BX ; Comparar si la fila actual es igual a la fila de la nave sumada
                JBE antesOtrasFilas ; Si es menor o igual, entonces continuar con las otras filas

            RET ; Retornar procedimiento
        dibujarNave ENDP

        ;**************** FIN DE DIBUJAR NAVE *****************

        ;***************** MOSTRAR DISPAROS *******************
        
        ; Procedimiento para imprimir todos los disparos que están en el arreglo
        ; SALIDAS: Imprime en pantalla una secuencia de disparos y deja lista la siguiente
        mostrarDisparos PROC NEAR
            MOV SI, 0 ; Inicializar el indice del arreglo en 0
            bucleMostrarDisparos:
                CMP SI, 4 ; Comparar si la posicion actual del arreglo es 4
                JE finMostrarDisparos ; Si es 4, entonces salir del bucle
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
        ; SALIDAS: Imprime en pantalla una secuencia de disparos y deja lista la siguiente
        mostrarDisparosAliens PROC NEAR
            MOV SI, 0 ; Inicializar el indice del arreglo en 0
            bucleMostrarDisparosAliens:
                CMP SI, 6 ; Comparar si la posicion actual del arreglo es 6
                JE finMostrarDisparosAliens ; Si es 6, entonces salir del bucle
                MOV BX, arregloDisparosAliens[SI] ; Mover a BX la posicion actual del disparo

                CMP BX, 0 ; Comparar si la posicion actual del disparo es 0
                JE seguirBucleDisparosAliens ; Si es 0, entonces continuar con el bucle

                CMP BH, 00C6h ; Comparar si la fila (Y) es 00C6h (Límite inferior de la pantalla)
                JAE terminarDisparoAliens ; Si es 5, entonces terminar el disparo y restablecer el arreglo

                MOV DL, BH ; Mover a DX la fila (Y)
                XOR DH, DH
                MOV CL, BL ; Mover a CX la columna (X)
                XOR CH, CH

                ADD BH, 3
                MOV arregloDisparosAliens[SI], BX ; Guardar la nueva posicion del disparo en el arreglo

                MOV AH, 0Ch ; Configurar para escribir un pixel
                MOV AL, 0Fh ; Morado para el color del pixel
                MOV BH, 00h ; Numero de pagina (0 es la actual)
                INT 10h ; Dibujar pixel

                INC DX ; Incrementar la fila (Mover hacia abajo 1 pixel)
                INT 10h ; Dibujar pixel
                INC DX ; Incrementar la fila (Mover hacia abajo 1 pixel)
                INT 10h ; Dibujar pixel

                JMP seguirBucleDisparosAliens ; Volver al inicio del bucle

                terminarDisparoAliens:
                    MOV arregloDisparosAliens[SI], 0 ; Restablecer la posicion del disparo en el arreglo

                seguirBucleDisparosAliens:
                    ADD SI, 2 ; Sumar 2 al indice del arreglo
                    JMP bucleMostrarDisparosAliens ; Volver al inicio del bucle
            finMostrarDisparosAliens:
                RET ; Retornar procedimiento
        mostrarDisparosAliens ENDP

        ;*********** FIN MOSTRAR DISPAROS ALIENS **************

        ;****************** MOSTRAR ALIENS ********************

        ; Procedimiento para imprimir todos los aliens que estén vivos
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
        ; SALIDAS: Verifica si un disparo colisiona con un alien y lo elimina
        verificarColisiones PROC NEAR
            colisionesBalasConAliens arregloAliens1, 20 ; Verificar colisiones con los aliens de la primera fila
            colisionesBalasConAliens arregloAliens2, 40 ; Verificar colisiones con los aliens de la segunda y tercera fila
            colisionesBalasConAliens arregloAliens3, 40 ; Verificar colisiones con los aliens de la cuarta y quinta fila
            colisionesBalasConNave ; Verificar colisiones con la nave
            RET ; Retornar procedimiento
        verificarColisiones ENDP

        ;************* FIN VERIFICAR COLISIONES ***************

        ;****************** DISPARAR ALIEN ********************

        ; Procedimiento para disparar un alien aleatorio
        ; SALIDAS: Dispara un alien aleatorio
        dispararAlien PROC NEAR
            inicioDispararAlien:
            generarNumeroRandom 3 ; Generar un número aleatorio entre 0 y 2
            MOV AL, numeroRandom ; Mover a AL el número aleatorio
            CMP AL, 0 ; Comparar si el número aleatorio es 0
            JE esCero
            CMP AL, 1 ; Comparar si el número aleatorio es 1
            JE esUno
            JMP esDos ; Si no es 0 ni 1, entonces es 2

            ; Si es cero:
            esCero:
                generarNumeroRandom 10 ; Generar un número aleatorio entre 0 y 9
                MOV AH, numeroRandom ; Mover a AH el número aleatorio
                MOV AL, 2 ; Mover a AL el número 2
                MUL AH ; Multiplicar el número aleatorio por 2

                XOR AH, AH ; Limpiar AH
                
                MOV SI, AX ; Mover a SI el número aleatorio
                MOV BX, arregloAliens1[SI] ; Mover a BX la posicion del alien
                CMP BX, 0 ; Comparar si el alien está muerto
                JE salirDispararAlien ; Si está muerto, volver a empezar

                JMP enviarDisparoAlien ; Si no está muerto, entonces disparar

            ; Si es uno:
            esUno:
                generarNumeroRandom 20 ; Generar un número aleatorio entre 0 y 19
                MOV AH, numeroRandom ; Mover a AH el número aleatorio
                MOV AL, 2 ; Mover a AL el número 2
                MUL AH ; Multiplicar el número aleatorio por 2
                XOR AH, AH ; Limpiar AH

                MOV SI, AX ; Mover a SI el número aleatorio
                MOV BX, arregloAliens2[SI] ; Mover a BX la posicion del alien
                CMP BX, 0 ; Comparar si el alien está muerto
                JE salirDispararAlien ; Si está muerto, volver a empezar

                JMP enviarDisparoAlien ; Si no está muerto, entonces disparar

            ; Si es dos:
            esDos:
                generarNumeroRandom 20 ; Generar un número aleatorio entre 0 y 19
                MOV AH, numeroRandom ; Mover a AH el número aleatorio
                MOV AL, 2 ; Mover a AL el número 2
                MUL AH ; Multiplicar el número aleatorio por 2

                XOR AH, AH ; Limpiar AH

                MOV SI, AX ; Mover a SI el número aleatorio
                MOV BX, arregloAliens3[SI] ; Mover a BX la posicion del alien
                CMP BX, 0 ; Comparar si el alien está muerto
                JE salirDispararAlien ; Si está muerto, volver a empezar

                JMP enviarDisparoAlien ; Si no está muerto, entonces disparar

            enviarDisparoAlien:
                ; BH = Fila (Y) / BL = Columna (X)
                ADD DX, 4 ; Sumar 4 a la fila (Cuatro filas más abajo)
                guardarDisparoAlien BX ; Llamar al macro para guardar el disparo

            salirDispararAlien:
                RET ; Retornar procedimiento
        dispararAlien ENDP

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

        finalizarPrograma:
            MOV AH, 4Ch ; Salir del programa
            INT 21h ; Ejecutar la configuracion
    main ENDP
END