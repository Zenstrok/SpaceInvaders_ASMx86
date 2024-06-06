.model small
.stack 100h

.data
;*********** ARREGLOS **********
arregloAliens1 DW 1522h, 1532h, 1542h, 1552h, 1562h, 1572h, 1582h, 1592h, 15A2h, 15B2h ; Arreglo de aliens 1 (Primera fila)
arregloAliens2 DW 2322h, 2332h, 2342h, 2352h, 2362h, 2372h, 2382h, 2392h, 23A2h, 23B2h, 3122h, 3132h, 3142h, 3152h, 3162h, 3172h, 3182h, 3192h, 31A2h, 31B2h ; Arreglo de aliens 2 (Segunda y tercera fila)
arregloAliens3 DW 3F22h, 3F32h, 3F42h, 3F52h, 3F62h, 3F72h, 3F82h, 3F92h, 3FA2h, 3FB2h, 4D22h, 4D32h, 4D42h, 4D52h, 4D62h, 4D72h, 4D82h, 4D92h, 4DA2h, 4DB2h ; Arreglo de aliens 3 (Cuarta y quinta fila)
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
velocidadMovimientoAliens DB 31 ; Velocidad en la que los aliens deben moverse (Entre más bajo, más rápido, 1 es el mínimo) 31 p.d

;*********** PUNTOS ************
variableVictoria DB 0 ; Variable para saber si el jugador ganó (1 = Ganó, 0 = No ganó aún, 2 = Perdió)
etiquetaPuntuacion DB "00", "$" ; Etiqueta para mostrar la puntuacion
mensajeVictoria DB "HAS GANADO!", "$" ; Mensaje de victoria
mensajeDerrota DB "HAS PERDIDO!", "$" ; Mensaje de derrota
mensajeDespedida DB "GRACIAS POR JUGAR", "$" ; Mensaje de despedida

;****** OPCIONES DE JUEGO ******
tituloJuego DB "SPACE INVADERS", "$"
opcionIniciar DB "(Y) JUGAR", "$"
opcionSalir DB "(N) SALIR", "$" 
opcionVolverAJugar DB "(Y) VOLVER A JUGAR", "$"

.code
;***************** FUNCIONES (MACROS) ****************

    ; Macro para imprimir una cadena en pantalla
    ; ENTRADAS: texto = Cadena a imprimir, x = Fila donde se va a imprimir, y = Columna donde se va a imprimir
    ; SALIDAS: Imprime en la posicion x,y el texto recibido
    imprimirCadena MACRO texto, x, y
        MOV AH, 02h
        MOV DH, x
        MOV DL, y
        INT 10h

        MOV AH, 09h
        LEA DX, texto
        INT 21h
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

    ; Macro para guardar la posicion de un disparo en el arreglo de disparos
    ; ENTRADAS: posicionDisparo = Posicion del disparo a guardar
    ; SALIDAS: Guarda la posicion del disparo en el arreglo de disparos
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
            CMP SI, 4 ; Comparar si el indice es menor a 4
            JNE bucleGuardarDisparo ; Si es menor, entonces continuar con el bucle
        finGuardarDisparo:
    ENDM

    ; Macro para guardar la posicion de un disparo en el arreglo de disparos de aliens
    ; ENTRADAS: posicionDisparo = Posicion del disparo a guardar
    ; SALIDAS: Guarda la posicion del disparo en el arreglo de disparos de aliens
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
            CMP SI, 6 ; Comparar si el indice es 6
            JNE bucleGuardarDisparo ; Si no es 6, entonces sigue el bucle
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

            CMP BH, 0096h ; Comparar si la fila del alien es igual a 00A6h (Limite inferior para los aliens)
            JNA seguirBucleBajarAliens ; Si no es el limite, continuar con el siguiente alien
            MOV variableVictoria, 2 ; Si llega al limite, entonces el jugador perdió

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
        LOCAL ejecutarResta, salirVerificarColisiones, sumarCincoPuntos, corregirPuntos, aplicarAjuste

        MOV SI, 0
        bucleVerificarColisiones:
            CMP SI, 4 ; Comparar si la posicion actual del arreglo es 4
            JE salirVerificarColisiones ; Si es 4, entonces salir del bucle
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
                JB seguirBucleVerificarColisionesAliens ; Si es menor, continuar con el bucle

                SUB BH, AH ; Restar la fila del disparo - la fila del alien
                CMP BH, 6 ; Comparar si la resta anterior es menor o igual a 6 (Hitbox vertical del alien)
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

    ; Macro para verificar las colisiones de las balas de los aliens con la nave
    ; SALIDAS: Verifica las colisiones de las balas de los aliens con la nave y elimina la nave si colisiona
    colisionesBalasConNave MACRO
        LOCAL bucleVerificarColisionesAliens, seguirBucleVerificarColisionesAliens, salirVerificarColisionesAliens, ejecutarResta
        MOV SI, 0
        bucleVerificarColisionesAliens:
            CMP SI, 6 ; Comparar si la posicion actual del arreglo es 6
            JE salirVerificarColisionesAliens ; Si es 6, entonces salir del bucle
            MOV BX, arregloDisparosAliens[SI] ; Mover a BX la posicion actual del disparo

            CMP BX, 0 ; Comparar si la posicion actual del disparo es 0
            JE seguirBucleVerificarColisionesAliens ; Si es 0, entonces seguir con el siguiente disparo

            MOV CX, naveX ; Mover a CX la columna (X) de la nave
            MOV AL, CL ; Mover a AL la columna (X) del disparo
            MOV CX, naveY ; Mover a CX la fila (Y) de la nave
            MOV AH, CL ; Mover a AH la fila (Y) del disparo

            ADD AH, 4 ; Sumar 4 a la Y de la nave
            CMP BH, AH ; Comparar si la fila (Y) de la bala es igual a la de la nave + 4
            JA seguirBucleVerificarColisionesAliens ; Si es mayor, continuar con el bucle

            SUB AH, BH ; Restar (la fila de la nave + 4) - la fila del disparo
            CMP AH, 4 ; Comparar si la resta anterior es menor o igual a 4 (Hitbox vertical de la nave)
            JA seguirBucleVerificarColisionesAliens ; Si es mayor, continuar con el bucle

            CMP AL, BL ; Comparar si la columna (X) del disparo es igual a la de la bala
            JAE ejecutarResta ; Si es mayor o igual, entonces restar la columna de la bala con la de la nave directamente
            XCHG AL, BL ; De lo contrario, intercambiar los valores de AL y BL antes de la resta

            ejecutarResta:
                SUB AL, BL ; Restar la columna mayor - la columna menor
            
            CMP AL, 6 ; Comparar si la resta anterior es menor o igual a 6 (Hitbox horizontal de la nave)
            JA seguirBucleVerificarColisionesAliens ; Si es mayor, entonces seguir con el siguiente disparo

            MOV arregloDisparosAliens[SI], 0 ; Eliminar disparo de alien

            MOV AL, etiquetaVidas[2] ; Mover a AL el tercer caracter de las vidas
            CMP AL, 03h ; Comparar si las vidas son 3
            JNE siguienteVida1 ; Si no es 3, entonces seguir con la siguiente vida

            MOV etiquetaVidas[2], 20h ; Poner un espacio en blanco en la tercera vida
            JMP salirVerificarColisionesAliens

            siguienteVida1:
                MOV AL, etiquetaVidas[1] ; Mover a AL el segundo caracter de las vidas
                CMP AL, 03h ; Comparar si las vidas son 3
                JNE siguienteVida2 ; Si no es 3, entonces seguir con la siguiente vida

                MOV etiquetaVidas[1], 20h ; Poner un espacio en blanco en la segunda vida
                JMP salirVerificarColisionesAliens

            siguienteVida2:
                MOV etiquetaVidas[0], 20h ; Poner un espacio en blanco en la primera vida
                MOV variableVictoria, 2 ; Si ya era la última vida, entonces el jugador perdió
                JMP salirVerificarColisionesAliens ; Salir de la verificacion de colisiones

            seguirBucleVerificarColisionesAliens:
                ADD SI, 2 ; Sumar 2 al indice del arreglo
                JMP bucleVerificarColisionesAliens ; Volver al inicio del bucle
        salirVerificarColisionesAliens:
    ENDM

    ; Macro para dibujar el alien de la primera fila
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

    ; Macro para reiniciar un arreglo de aliens
    ; ENTRADAS: arregloReiniciar = Arreglo a reiniciar, primerElemento = Primer valor del arreglo, cantidadReiniciar = Cantidad de aliens en el arreglo
    ; SALIDAS: Reinicia un arreglo de aliens
    reiniciarArregloAliens MACRO arregloReiniciar, primerElemento, cantidadReiniciar
        LOCAL bucleReiniciar, salirReiniciar, bajarFila, seguirBucleReiniciar
        MOV SI, 0
        MOV AX, primerElemento
        bucleReiniciar:
            CMP SI, cantidadReiniciar ; Comparar si la posicion actual del arreglo es la cantidad de aliens
            JE salirReiniciar ; Si es la cantidad de aliens, salir del bucle
            CMP SI, 20 ; Comparar si la posicion actual del arreglo es 20
            JE bajarFila ; Si es 20, entonces bajar una fila
            seguirBucleReiniciar:
            MOV arregloReiniciar[SI], AX ; Guardar el primer elemento en el arreglo
            ADD AX, 10h ; Sumar 10h al primer elemento
            ADD SI, 2 ; Sumar 2 al indice del arreglo
            JMP bucleReiniciar ; Volver al inicio del bucle
        JMP salirReiniciar ; Salir del bucle

        bajarFila:
            ADD AH, 0Eh ; Sumar 0E00h al primer elemento
            MOV AL, 22h ; Mover a AL el valor 22h
            JMP seguirBucleReiniciar ; Continuar con el bucle
        
        salirReiniciar:
    ENDM

    ; Macro para reiniciar un arreglo de disparos
    ; ENTRADAS: arregloReiniciar = Arreglo a reiniciar, cantidadReiniciar = Cantidad de disparos en el arreglo
    ; SALIDAS: Reinicia un arreglo de disparos
    reiniciarArregloDisparos MACRO arregloReiniciar, cantidadReiniciar
        LOCAL bucleReiniciar, salirReiniciar
        MOV SI, 0
        bucleReiniciar:
            CMP SI, cantidadReiniciar ; Comparar si la posicion actual del arreglo es la cantidad de disparos
            JE salirReiniciar ; Si es la cantidad de disparos, salir del bucle
            MOV arregloReiniciar[SI], 0000h ; Reiniciar la posicion del disparo
            ADD SI, 2 ; Sumar 2 al indice del arreglo
            JMP bucleReiniciar ; Volver al inicio del bucle
        salirReiniciar:
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

        CALL limpiarPantalla ; Limpiar la pantalla (En negro)
        CALL pantallaInicio ; Llamar al procedimiento de la pantalla de inicio

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

            ;****************** MOSTRAR ALIENS ********************
            mostrarAliens arregloAliens1, 20 ; Mostrar los aliens de la primera fila
            mostrarAliens arregloAliens2, 40 ; Mostrar los aliens de la segunda y tercera fila
            mostrarAliens arregloAliens3, 40 ; Mostrar los aliens de la cuarta y quinta fila
            ;**************** FIN MOSTRAR ALIENS ******************
            
            ;*************** VERIFICAR COLISIONES *****************
            colisionesBalasConAliens arregloAliens1, 20 ; Verificar colisiones con los aliens de la primera fila
            colisionesBalasConAliens arregloAliens2, 40 ; Verificar colisiones con los aliens de la segunda y tercera fila
            colisionesBalasConAliens arregloAliens3, 40 ; Verificar colisiones con los aliens de la cuarta y quinta fila
            colisionesBalasConNave ; Verificar colisiones con la nave
            ;************* FIN VERIFICAR COLISIONES ***************
            
            CALL mostrarDisparosAliens ; Mostrar los disparos de los aliens
            imprimirCadena etiquetaPuntuacion, 1, 1 ; Llamar al macro para imprimir la puntuacion
            imprimirCadena etiquetaVidas, 1, 30 ; Llamar al macro para imprimir las vidas

            JMP revisarTiempo ; Volver a otro ciclo
        RET

        ;***************** FIN CICLO DE JUEGO *****************


        ;***************!! PROCEDIMIENTOS !!*******************


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


        ;****************** PANTALLA INICIO *******************
        pantallaInicio PROC NEAR
            CALL limpiarPantalla ; Limpiar la pantalla

            imprimirCadena tituloJuego, 5, 10 ; Imprimir el título del juego
            imprimirCadena opcionIniciar, 10, 8 ; Imprimir la opción "Iniciar a jugar"
            imprimirCadena opcionSalir, 12, 8 ; Imprimir la opción "Salir del juego"

            ; Esperar a que el usuario presione una tecla
            esperarTecla:
                MOV AH, 01h ; Función para verificar si hay una tecla presionada
                INT 16h ; Llamada a la interrupción del BIOS
                JZ esperarTecla ; Si no se presionó ninguna tecla, volver a esperar

                ; Leer la tecla presionada
                MOV AH, 00h ; Función para leer la tecla presionada
                INT 16h ; Llamada a la interrupción del BIOS

                ; Verificar qué tecla se presionó
                CMP AL, 'Y'
                JE iniciarJuego
                CMP AL, 'y'
                JE iniciarJuego
                CMP AL, 'N'
                JE salirJuego
                CMP AL, 'n'
                JE salirJuego
                JMP pantallaInicio ; Si no se presionó una tecla válida, volver a mostrar la pantalla de inicio

            iniciarJuego:
                RET ; Retornar al procedimiento que lo llamó

            salirJuego:
                MOV AH, 4Ch ; Función para terminar el programa
                INT 21h ; Llamada a la interrupción del DOS

            RET ; Retornar al procedimiento que lo llamó
        pantallaInicio ENDP

        ;**************** FIN PANTALLA INICIO *****************

        ;****************** PANTALLA FINAL ********************

        pantallaFinal PROC NEAR
            CALL limpiarPantalla ; Limpiar la pantalla

            CMP variableVictoria, 1 ; Verificar si el jugador ganó
            JE mostrarVictoria

            ; Mostrar pantalla de derrota
            imprimirCadena mensajeDerrota, 5, 12 ; Imprimir el mensaje de derrota
            JMP mostrarOpciones

            mostrarVictoria:
                imprimirCadena mensajeVictoria, 5, 12 ; Imprimir el mensaje de victoria

            mostrarOpciones:
                imprimirCadena opcionVolverAJugar, 10, 8 ; Imprimir la opción de volver a jugar
                imprimirCadena opcionSalir, 12, 8 ; Imprimir la opción de salir del programa

                ; Esperar a que el usuario presione una tecla
                esperarTeclaFinal:
                    MOV AH, 01h ; Función para verificar si hay una tecla presionada
                    INT 16h ; Llamada a la interrupción del BIOS
                    JZ esperarTeclaFinal ; Si no se presionó ninguna tecla, volver a esperar

                    ; Leer la tecla presionada
                    MOV AH, 00h ; Función para leer la tecla presionada
                    INT 16h ; Llamada a la interrupción del BIOS

                    ; Verificar qué tecla se presionó
                    CMP AL, 'Y'
                    JE reiniciarJuego
                    CMP AL, 'y'
                    JE reiniciarJuego
                    CMP AL, 'N'
                    JE salirJuegov
                    CMP AL, 'n'
                    JE salirJuegov
                    JMP pantallaFinal ; Si no se presionó una tecla válida, volver a mostrar la pantalla final
    
            reiniciarJuego:
                CALL reiniciarVariables ; Reiniciar las variables del juego
                CALL main ; Llamar al procedimiento principal para iniciar un nuevo juego
                RET ; Retornar al procedimiento que lo llamó

            salirJuegov:
                CALL limpiarPantalla ; Limpiar la pantalla
                imprimirCadena mensajeDespedida, 5, 12 ; Imprimir el mensaje de despedida
                MOV AH, 4Ch ; Función para terminar el programa
                INT 21h ; Llamada a la interrupción del DOS

            RET ; Retornar al procedimiento que lo llamó
        pantallaFinal ENDP

        ;**************** FIN PANTALLA FINAL ******************

        ;*************** REINICIAR VARIABLES ******************

        reiniciarVariables PROC NEAR
            ; Reiniciar las variables del juego a sus valores iniciales
            MOV naveX, 00A0h ; Posición X inicial de la nave
            MOV naveY, 00BEh ; Posición Y inicial de la nave
            MOV controlarAliensX, 0 ; Reiniciar el control de movimiento de los aliens
            MOV direccionMovimientoAliens, 0 ; Reiniciar la dirección de movimiento de los aliens
            MOV numeroRandom, 0 ; Reiniciar el número random
            MOV tiempoAuxiliar, 0 ; Reiniciar el tiempo auxiliar
            MOV contadorMovimientoAliens, 0 ; Reiniciar el contador de movimiento de los aliens
            MOV contadorVelocidadAliens, 0 ; Reiniciar el contador de velocidad de los aliens
            MOV velocidadMovimientoAliens, 19 ; Reiniciar la velocidad de movimiento de los aliens
            MOV variableVictoria, 0 ; Reiniciar la variable de victoria
            MOV etiquetaPuntuacion[0], '0' ; Reiniciar la puntuación
            MOV etiquetaPuntuacion[1], '0'

            ; Reiniciar las vidas
            MOV etiquetaVidas[0], 03h
            MOV etiquetaVidas[1], 03h
            MOV etiquetaVidas[2], 03h

            ; Reiniciar los arreglos
            reiniciarArregloAliens arregloAliens1, 1522h, 20
            reiniciarArregloAliens arregloAliens2, 2322h, 40
            reiniciarArregloAliens arregloAliens3, 3F22h, 40

            ; Reiniciar los disparos
            reiniciarArregloDisparos arregloDisparos, 4
            reiniciarArregloDisparos arregloDisparosAliens, 6

            RET ; Retornar procedimiento
        reiniciarVariables ENDP

        ;************* FIN REINICIAR VARIABLES ****************
        
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
            CMP variableVictoria, 1 ; Verificar si el jugador ganó
            JE imprimirResultado ; Si ganó, mostrar la pantalla final
            CMP variableVictoria, 2 ; Verificar si el jugador perdió
            JE imprimirResultado ; Si perdió, mostrar la pantalla final
            JNE finalizarVerificacion ; Si no ha ganado ni perdido, continuar con el juego

            imprimirResultado:
                CALL pantallaFinal ; Llamar a la pantalla final (victoria o derrota)
                JMP finalizarPrograma ; Salir del programa después de mostrar la pantalla final

            finalizarVerificacion:
                RET ; Retornar al procedimiento que lo llamó
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