# Nombre del archivo de salida
TARGET = SpaceInvaders.exe

# Archivo fuente
SRC = SpaceInvaders.asm

# Archivo objeto generado por MASM
OBJ = SpaceInvaders.obj

# Compilador y enlazador
ASM = ml
LINKER = link

# Opciones del compilador
ASMFLAGS = /c /coff

# Opciones del enlazador
LINKFLAGS = /SUBSYSTEM:CONSOLE

# Regla por defecto
all: $(TARGET)

# Regla para crear el archivo objeto
$(OBJ): $(SRC)
	$(ASM) $(ASMFLAGS) $(SRC)

# Regla para crear el ejecutable
$(TARGET): $(OBJ)
	$(LINKER) $(LINKFLAGS) $(OBJ) /OUT:$(TARGET)

# Limpieza de archivos intermedios
clean:
	del $(OBJ) $(TARGET)