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

    ;*************** FIN FUNCIONES (MACROS) **************