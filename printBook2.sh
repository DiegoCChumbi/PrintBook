#!/bin/bash

if [ -z "$1" ]; then
	echo "Error: Se requiere un archivo como argumento"
	exit 1
fi

archivo="$1"
modo_bn="$2"

if [ ! -f "$archivo" ]; then
  echo "Error: El archivo '$archivo' no existe."
  exit 1
fi

if [[ "$archivo" != *.* || "$archivo" == .* ]]; then
	echo "Error: No es un archivo valido (1)"
	exit 1
fi

if [ "$modo_bn" == "bw" ]; then
    OPCIONES_IMPRESION="-o Color=Grayscale"
    echo "Se imprimirá en blanco y negro"
else
    OPCIONES_IMPRESION=""
    echo "Se imprimirá en color (o configuración predeterminada)"
fi

extension=${archivo##*.}
nombre_base="${archivo%.pdf}"

if [ "$extension" != "pdf" ]; then
	echo "Error: No es un archivo valido (2)"
	exit 1
fi

pares=$(mktemp --suffix=.pdf)
impares=$(mktemp --suffix=.pdf)

echo "Creando el libro..."
pdfbook2 -n "$archivo"

if [ $? -ne 0 ]; then
	echo "Error al crear el libro"
	exit 1
fi

archivo_libro="${nombre_base}-book.pdf"

echo "Dividiendo el libro"

pdftk "$archivo_libro" cat odd output "$impares"
pdftk "$archivo_libro" cat even output "$pares"

echo "Imprimiendo páginas impares..."
eval lp "$OPCIONES_IMPRESION" "$impares"

read -p "Inserta las hojas impresas nuevamente en la bandeja y presiona Enter para continuar..."

echo "Imprimiendo páginas pares..."
eval lp "$OPCIONES_IMPRESION" "$pares"

rm -f "$impares" "$pares" "$archivo_libro"
echo "Impresión doble cara manual completada."
