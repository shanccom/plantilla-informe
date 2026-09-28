# Plantilla de informes (UNSA) + comando `informe`

Plantilla en **Typst** para los informes de la Universidad Nacional de San
Agustín. Trae portada, índice, encabezado con los logos de la facultad,
numeración de títulos estilo *1.1 / 1.1.1* y bibliografía en formato IEEE.

Además trae el comando **`informe`**, que instala esta plantilla en tu equipo
para crearte una copia nueva en cualquier carpeta con un solo comando.

```
informe                  # crea la plantilla en la carpeta donde estás
typst compile main.typ   # y ya tienes tu PDF
```

---

## Requisitos

| Herramienta | Versión | Para qué |
| ----------- | ------- | -------- |
| Typst       | 0.11 o superior | compilar los PDF |
| Python 3    | 3.8 o superior   | ejecutar el comando `informe` |
| Bash        | 3.2 o superior   | ejecutar `install.sh` |

No hace falta instalar nada más: el comando usa solo la biblioteca estándar de
Python.

<details>
<summary>¿Cómo instalo Typst?</summary>

**macOS** (con [Homebrew](https://brew.sh)):

```sh
brew install typst
```

**Linux**:

```sh
# Ubuntu / Debian
sudo apt install typst
# Fedora
sudo dnf install typst
# o descarga directa
curl -fsSL https://typst.app/install.sh | sh
```

Comprueba que quedó instalado:

```sh
typst --version
```
</details>

---

## Instalación

### macOS y Linux (un solo paso)

```sh
git clone https://github.com/shanccom/plantilla-informe.git
cd plantilla-informe
./install.sh
```

El instalador hace tres cosas:

1. Copia la plantilla a `~/.local/share/informe-plantilla`.
2. Crea el comando `informe` en `~/.local/bin/informe`.
3. Te dice si falta agregar esa carpeta al `PATH`.

Si al final aparece el aviso sobre el `PATH`, agrega esta línea a tu
`~/.zshrc` (macOS) o `~/.bashrc` / `~/.profile` (Linux) y recarga:

```sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Después verifica:

```sh
informe --version
```

### Instalación para todo el sistema

Si quieres que el comando esté disponible para todos los usuarios y **no**
necesitas tocar ningún `PATH`:

```sh
sudo ./install.sh --prefix /usr/local
```

### Otras opciones del instalador

```sh
./install.sh --help        # ver todas las opciones
./install.sh --prefix DIR  # instalar en otra carpeta
./install.sh --uninstall   # quitar el comando y la plantilla
```

`--uninstall` borra solo lo que instaló el script, no toca tus informes.

---

## Uso

### Lo normal: en la carpeta de tu trabajo

```sh
mkdir mi-informe-01
cd mi-informe-01
informe
```

`informe` sin argumentos crea la plantilla **en la carpeta donde estás**, así
que no tienes que escribir ninguna carpeta. Si la carpeta está vacía, te
pregunta los datos de la portada y arma el proyecto:

```
Título del informe [Título del informe]: Diseño de un Sistema de Inventarios
Subtítulo (vacío para no ponerlo): FICHA 07
Curso [Nombre del curso]: Análisis y Diseño de Sistemas
Docente [Nombre del docente]: Ing. Juan Pérez Ramírez
Lugar [Arequipa, Perú]:
Fecha [dd - mm - aaaa]: 20 - 09 - 2026
Idioma del documento (es/en) [es]:

Integrantes (uno por línea, línea vacía para terminar):
  Ramos Quinoa, Ana:
  Ccahuana Mamani, Luis:

¿Mostrar portada? [S/n]:
¿Mostrar índice? [S/n]:
```

Si no quieres preguntas, usa `-n` y rellena después:

```sh
informe -n
```

### Crear la plantilla en una carpeta nueva

```sh
informe mi-informe-02
```

Crea `./mi-informe-02/` con la plantilla dentro.

### Sin preguntas, todo por banderas

```sh
informe ficha-07 \
  --titulo "Diseño de un Sistema de Inventarios" \
  --subtitulo "FICHA 07" \
  --curso "Análisis y Diseño de Sistemas" \
  --docente "Ing. Juan Pérez Ramírez" \
  --integrante "Ramos Quinoa, Ana" \
  --integrante "Ccahuana Mamani, Luis" \
  --lugar "Arequipa, Perú" \
  --fecha "20 - 09 - 2026" \
  -n
```

### Todas las opciones

| Opción | Qué hace |
| ------ | -------- |
| `DESTINO` | Carpeta destino. Si se omite, se usa la carpeta actual. |
| `-n`, `--no-interactive` | No pregunta nada; usa los valores por defecto. |
| `-f`, `--force` | Sobrescribe archivos que ya existan. |
| `--titulo`, `--subtitulo`, `--curso`, `--docente` | Datos de la portada. |
| `--integrante NOMBRE` | Un integrante. Repite la opción para agregar más. |
| `--lugar`, `--fecha` | Lugar y fecha de la portada. |
| `--idioma {es,en}` | Idioma del documento. |
| `--sin-portada` | No genera la portada. |
| `--sin-indice` | No genera el índice. |
| `--sin-logo` | Deja los dos logos del encabezado en `none`. |
| `--plantilla DIR` | Usa otra plantilla. Útil para desarrollo. |
| `-V`, `--version` | Muestra la versión instalada. |
| `-h`, `--help` | Muestra la ayuda. |

Si vuelves a ejecutar `informe` en una carpeta que ya tiene la plantilla, te
pregunta antes de sobrescribir. Con `-n` no pregunta y te pide que agregues
`-f`.

---

## Compilar el informe

El comando `informe` solo crea la estructura; el PDF lo compila Typst:

```sh
typst compile main.typ        # genera main.pdf
typst watch main.typ          # recompila solo cada vez que guardas
```

`watch` es la forma cómoda de trabajar: dejas el editor abierto y el PDF se
actualiza en cada `Ctrl+S` o `Cmd+S`.

---

## Estructura que se crea

```
mi-informe/
├── main.typ            # une las piezas: aquí agregas o quitas secciones
├── config.typ          # TODOS los datos y ajustes del informe
├── plantilla.typ       # la lógica de la plantilla (no hay que tocarla)
├── referencias.bib     # fuentes bibliográficas
├── secciones/
│   ├── 01-introduccion.typ
│   ├── 02-desarrollo.typ
│   ├── 03-conclusiones.typ
│   └── 04-referencias.typ
└── imagenes/
    ├── logo-izquierdo.png
    └── logo-derecho.png
```

### Escribir el contenido

Agrega o quita secciones en `secciones/` y lístalas en `main.typ`:

```typ
#include "secciones/01-introduccion.typ"
#include "secciones/02-desarrollo.typ"
#include "secciones/03-conclusiones.typ"
#include "secciones/04-referencias.typ"
#include "secciones/05-anexos.typ"   # la nueva
```

### Citar fuentes

Las fuentes van en `referencias.bib`, en formato BibTeX:

```bibtex
@book{sommerville2011,
  author    = {Ian Sommerville},
  title     = {Software Engineering},
  publisher = {Addison-Wesley},
  edition   = {9},
  year      = {2011}
}
```

Y en el texto las citas con `@`:

```typ
Según @sommerville2011, el proceso de desarrollo requiere metodologías
estructuradas. También @pressman2014 coincide con esto.
```

Las referencias se arma solas al final, en estilo IEEE.

### Ajustar el formato

Todo se cambia en `config.typ`, sin tocar `plantilla.typ`. Los ajustes más
usados:

```typ
#let tamano        = 11pt          // tamaño de letra
#let interlineado  = 0.7em         // interlineado
#let margen-lateral = 2cm          // márgenes
#let numeracion-titulos = "1.1"    // estilo de numeración de títulos
#let portada            = true     // poner en false para quitar la portada
#let indice             = true     // poner en false para quitar el índice
#let idioma        = "es"          #let idioma = "en"
```

Para cambiar los logos del encabezado:

```typ
#let logo-izquierdo = "imagenes/logo-izquierdo.png"   // o none
#let logo-derecho   = "imagenes/logo-derecho.png"     // o none
#let altura-logo    = 1.4cm
```

Y para que la fecha sea la del día en que compilas:

```typ
#let fecha = datetime.today().display("[day] - [month] - [year]")
```

---

## Desinstalar

```sh
./install.sh --uninstall
```

Borra `informe` y la plantilla instalada. Tus informes quedan intactos.

---

## Problemas frecuentes

**`informe: command not found`**

`~/.local/bin` no está en el `PATH`. Agrega la línea de la sección de
instalación a tu `~/.zshrc` o `~/.bashrc` y ejecuta `source` sobre ese archivo.

**`informe: no se encuentra la plantilla instalada`**

La plantilla no está donde el instalador la dejó. Vuelve a instalar:

```sh
cd ~/ruta/al/repo && ./install.sh
```

**`typst: command not found`**

Typst no está instalado. Ver la sección de requisitos.

**El PDF sale con otra tipografía**

La plantilla pide Times New Roman y, si no está, cae en New Computer Modern.
En Linux normalmente no hay Times New Roman; instálalo o pon en `config.typ`
una fuente que sí tengas:

```typ
#let fuente = ("Liberation Serif", "New Computer Modern")
```

**Sale `error: unknown variable` al compilar**

Sobra una llave o falta un paréntesis en `config.typ`. Revisa que cada
`#let` termine en coma si es parte de una tupla.

**Quiero volver a instalar una plantilla actualizada**

```sh
git pull && ./install.sh
```

El instalador reemplaza la plantilla guardada. Los informes que ya creaste no
se tocan.

---

## Estructura de este repositorio

| Ruta | Qué es |
| ---- | ------ |
| `install.sh` | Instalador para macOS y Linux. |
| `bin/informe` | El CLI, escrito en Python sin dependencias. |
| `plantilla.typ` | Lógica de la plantilla: portada, índice, encabezado, títulos. |
| `config.typ` | Datos y ajustes. Ejemplo de cómo debe quedar el tuyo. |
| `main.typ` | Une las secciones. |
| `secciones/` | Contenido de ejemplo. |
| `referencias.bib` | Fuentes de ejemplo. |
| `imagenes/` | Logos de la facultad. |

Los PDF que compiles no se suben a Git: están en `.gitignore`. Cada estudiante
puede versionar su propio informe sin arrastrar documentos pesados.

---

## Desarrollo

Para probar los cambios sin instalar nada:

```sh
cd /tmp/carpeta-de-pruebas
/ruta/al/repo/bin/informe -n
```

Para instalar una versión concreta del repositorio, sin copiar archivos a mano:

```sh
./install.sh --prefix ~/.local
```
