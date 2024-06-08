# Space Invaders x86 MASM
Debe de saber que este juego está en proceso de ser terminado visualmente y optimizado, pero ya está disponible su jugabilidad completa.
### Introducción
Este es un proyecto del mítico juego "Space Invaders", recreándolo en ensamblador x86 MASM sin utilizar recursos externos a los del propio ensamblador, así que debería ser fácil de ejecutar en cualquier máquina que utilice Windows como sistema operativo.
>El programa debe ser compilado en MASM, de lo contrario, no va a funcionar, para una ejecución más sencilla puede usar el **[Compilador de MASM/TASM en VSCode](https://marketplace.visualstudio.com/items?itemName=xsro.masm-tasm)**.

### Aspectos de Jugabilidad
- Movimiento: A = Izquierda, D = Derecha, Espacio = Disparar
- Opciones: Y = Aceptar, N = Rechazar
- Vidas de la nave: 3
- Vidas de las casas: 8
- Puntuación: 2 puntos por cada alien eliminado
- Balas a la vez en pantalla (Nave) : 2

### Estructura
##### Segmento de Datos:
- Arreglos: Variables para contener los siguientes datos: Aliens, Casas, Disparos, Vidas de las casas.
- Control X,Y: Datos que sirven para controlar la posición de la nave y los aliens, así como contener un número aleatorio.
- Variables Aux: Variables para controlar el tiempo del juego.
- Puntos: Variables para controlar la puntuación y saber si el jugador ya ganó o perdió.
- Opciones de Juego: Etiquetas para mostrar información al jugador.

##### Segmento de Código:
- Funciones (Macros).
- Procedimiento principal (Bucle del juego).
- Procedimientos.

### Autor de la Recreación
Jose Mario Jiménez Vargas (Zenstrok)