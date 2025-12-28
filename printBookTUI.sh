#!/bin/bash

printbook() {
  fileName=$1
  local CONF=(-d ${PRINTERNAME})
  if [ "$VARCOL" == "BW" ]; then
    CONF+=(-o Color=Grayscale)
  fi

  bookFileName="${fileName%.pdf}-book.pdf"
  pares=$(mktemp --suffix=.pdf)
  impares=$(mktemp --suffix=.pdf)

  gum spin --spinner points --title "Generando el formato libro..." -- \
    bash -c "pdfbook2 -n '$fileName' && \
             pdftk '$bookFileName' cat odd output '$impares' && \
             pdftk '$bookFileName' cat even output '$pares'"

  JOB_MSG=$(LC_ALL=C lp "${CONF[@]}" "$impares")
  JOB_ID=$(echo "$JOB_MSG" | awk '{print $4}')

  gum spin --spinner points --title "Imprimiendo caras IMPAR ($JOB_ID)..." -- \
    bash -c "while lpstat | grep -q '$JOB_ID'; do sleep 2; done"

  gum style \
    --border double --border-foreground 212 --padding "1 2" --align center --width 50 \
    "IMPRESIÓN IMPAR FINALIZADA" \
    " " \
    "1. Espere a que salgan todas las hojas." \
    "2. Voltea las hojas (según tu impresora)." \
    "3. Vuelve a insertarlas en la bandeja."

  if gum confirm "Continuar, imprimir PARES"; then
    JOB_MSG=$(LC_ALL=C lp "${CONF[@]}" "$pares")
    JOB_ID=$(echo "$JOB_MSG" | awk '{print $4}')

    gum spin --spinner points --title "Imprimiendo caras PAR ($JOB_ID)..." -- \
      bash -c "while lpstat | grep -q '$JOB_ID'; do sleep 2; done"

    gum style --foreground 46 "Impresion de ${fileName} completada"
  else
    gum style --foreground 196 "Impresión de pares cancelada."
  fi

  rm "$impares" "$pares" "$bookFileName"
}

printNormal() {
  fileName=$1
  local CONF=(-d $PRINTERNAME)
  if [ "$VARCOL" == "BW" ]; then
    CONF+=(-o Color=Grayscale)
  fi

  pares=$(mktemp --suffix=.pdf)
  impares=$(mktemp --suffix=.pdf)

  gum spin --spinner points --title "Generando el formato..." -- \
    bash -c "pdftk '$fileName' cat odd output '$impares' && \
             pdftk '$fileName' cat even output '$pares'"

  JOB_MSG=$(LC_ALL=C lp "${CONF[@]}" "$impares")
  JOB_ID=$(echo "$JOB_MSG" | awk '{print $4}')

  gum spin --spinner points --title "Imprimiendo caras IMPAR ($JOB_ID)..." -- \
    bash -c "while lpstat | grep -q '$JOB_ID'; do sleep 2; done"

  gum style \
    --border double --border-foreground 212 --padding "1 2" --align center --width 50 \
    "IMPRESIÓN IMPAR FINALIZADA" \
    " " \
    "1. Espere a que salgan todas las hojas." \
    "2. Voltea las hojas (según tu impresora)." \
    "3. Vuelve a insertarlas en la bandeja."

  if gum confirm "Continuar, imprimir PARES"; then
    JOB_MSG=$(LC_ALL=C lp "${CONF[@]}" "$pares")
    JOB_ID=$(echo "$JOB_MSG" | awk '{print $4}')

    gum spin --spinner points --title "Imprimiendo caras PAR ($JOB_ID)..." -- \
      bash -c "while lpstat | grep -q '$JOB_ID'; do sleep 2; done"

    gum style --foreground 46 "Impresion de ${fileName} completada"
  else
    gum style --foreground 196 "Impresión de pares cancelada."
  fi

  rm "$impares" "$pares"
}

PRINTER_LIST=$(lpstat -e)
if [ -z "$PRINTER_LIST" ]; then
  gum style --foreground 196 "Error: No se detectaron impresoras (lpstat -e vacío)."
  exit 1
fi
echo "Escoga una impresora:"
PRINTERNAME=$(echo "$PRINTER_LIST" | gum choose)
echo "Color: "
VARCOL=$(gum choose {Color,BW})
echo "Formato de impresion:"
VARFOR=$(gum choose {FullPage,Cuaderno})
echo "Archivos a imprimir:"
ARCHLIST=$(find . -maxdepth 1 -name "*.pdf" -printf "%f\n" | gum choose --no-limit)

if [ -z "$ARCHLIST" ]; then
  gum style --foreground 196 "No seleccionaste ningún archivo. Saliendo."
  exit 0
fi

while IFS= read -r -u 3 archivo; do

  [ -z "$archivo" ] && continue

  gum style --border normal --margin "1 0" --padding "0 1" --border-foreground 212 \
    "Procesando: $archivo" "Modo: $VARFOR" "Color: $VARCOL" "Impresora: $PRINTERNAME"

  case "$VARFOR" in
  "Cuaderno")
    printbook "$archivo"
    ;;
  "FullPage")
    printNormal "$archivo"
    ;;
  esac

  echo ""

done 3<<<"$ARCHLIST"
gum style --foreground 46 --bold "¡Cola de impresión finalizada!"
