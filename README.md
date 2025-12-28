# PrintBook

Pequeños scripts utilitarios y una sencilla interfaz de terminal (TUI) para preparar e imprimir archivos PDF como libros (flujo de trabajo de dúplex manual), usando `gum` de Charm para una experiencia TUI.

## Qué hace este proyecto

PrintBook ofrece dos puntos de entrada principales:

- `printBookTUI.sh` — TUI interactiva que permite elegir impresora, modo de color, formato de impresión (libro/dúplex manual o página completa) y uno o más archivos PDF para imprimir. Usa `gum` para los menús y cuadros de confirmación/estado.
- `printBook2.sh` — ayuda no interactiva para crear un PDF en formato libro e imprimir páginas impares/pares (dúplex manual) para un solo archivo.

Estos scripts automatizan la generación del formato libro (con `pdfbook2`), la separación de páginas impares/pares con `pdftk` y el envío de trabajos a CUPS (`lp`). Incluyen indicaciones y spinners con `gum` para guiar al usuario durante el proceso de dúplex manual.

## Por qué es útil

- Convierte rápidamente PDFs en un diseño de folleto apto para impresión dúplex manual.
- Proporciona un flujo de trabajo interactivo sencillo para seleccionar impresoras y opciones sin escribir código de interfaz: `gum` aporta la experiencia de usuario.
- Conjunto de herramientas pequeño basado en shell que funciona en sistemas Linux con CUPS y las utilidades de PDF habituales.

## Características clave

- Selección interactiva (TUI) de impresora, modo de color y archivos
- Creación de folleto usando `pdfbook2`
- Separación de páginas impares/pares con `pdftk`
- Uso de `gum` para una UX consistente y agradable (`choose`, `confirm`, `spin`, `style`)

## Requisitos

- bash (shell POSIX)
- Utilidades de CUPS: `lp`, `lpstat`
- `pdfbook2` (https://github.com/jenom/pdfbook2)
- `pdftk` (o un extractor de páginas PDF compatible)
- `gum` (herramienta TUI de Charm)

En Debian/Ubuntu normalmente puedes instalar los paquetes necesarios con:

```bash
sudo apt update
sudo apt install pdftk
# instala gum por separado
```

Nota: los nombres de paquete varían según la distribución. `pdfbook2` puede venir con la cadena de herramientas de TeX (pdfjam). Si `pdfbook2` no está disponible, instala el paquete que lo provea en tu distro.

## Instalación / Cómo empezar

1. Clona el repositorio:

```bash
git clone https://github.com/DiegoCChumbi/PrintBook.git
cd PrintBook
```

2. Haz ejecutables los scripts si es necesario:

```bash
chmod +x printBookTUI.sh printBook2.sh
```

3. Asegúrate de que las dependencias estén instaladas. Instala `gum` si quieres la experiencia TUI:

```bash
# Recomendado: instalar gum con el gestor de paquetes o vía `go install`
go install github.com/charmbracelet/gum@latest
```

## Ejemplos de uso

- TUI interactiva (recomendado):

```bash
./printBookTUI.sh
```

Esto mostrará menús para seleccionar la impresora, color (Color/BW), formato de impresión (FullPage/Cuaderno) y uno o varios archivos `*.pdf` en el directorio actual.

- Ayudante no interactivo para un solo archivo y siempre en modo cuadernillo:

```bash
./printBook2.sh miarchivo.pdf         # imprime en color (por defecto)
./printBook2.sh miarchivo.pdf bw     # fuerza blanco y negro
```

Notas sobre el flujo de trabajo:

- Los scripts generan un `*-book.pdf` (formato folleto), luego separan páginas impares/pares y envían primero las impares a la impresora. Se te pedirá que vuelvas a insertar las hojas para imprimir las páginas pares.
- **Estos scripts están orientados a escenarios de dúplex manual.**
 
## Agradecimientos

- Gracias a Charm (charmbracelet) por crear y mantener `gum`, que aporta la interfaz interactiva y los componentes TUI usados en `printBookTUI.sh`.
- Gracias a Jenom por `pdfbook2`, la herramienta que usamos para generar el formato libro (booklet) a partir de PDFs.