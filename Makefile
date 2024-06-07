# Makefile para compilar programas en MASM x86

# Nombre del ejecutable a generar
TARGET = programa.exe

# Directorios de los archivos fuente y objeto
SRC_DIR = src
OBJ_DIR = obj

# Lista de archivos fuente (assembler)
SOURCES = $(wildcard $(SRC_DIR)/*.asm)

# Lista de archivos objeto generados
OBJECTS = $(SOURCES:$(SRC_DIR)/%.asm=$(OBJ_DIR)/%.obj)

# Opciones de compilación
MASM = ml.exe
MASM_FLAGS = /c /Fo$(OBJ_DIR)/

# Regla para generar el ejecutable
$(TARGET): $(OBJECTS)
    link.exe /OUT:$(TARGET) $(OBJECTS)

# Regla para compilar cada archivo fuente
$(OBJ_DIR)/%.obj: $(SRC_DIR)/%.asm
    $(MASM) $(MASM_FLAGS) $<

# Regla para limpiar archivos generados
clean:
    del /Q $(OBJ_DIR)\*.obj
    del /Q $(TARGET)