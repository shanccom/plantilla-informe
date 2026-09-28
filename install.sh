#!/usr/bin/env bash
#
# install.sh - instala el comando `informe` en macOS y Linux.
#
#   ./install.sh              instala en ~/.local
#   ./install.sh --prefix DIR instala en DIR (por ejemplo /usr/local)
#   ./install.sh --uninstall  quita lo que instaló
#   ./install.sh --help       muestra esta ayuda
#
# Qué hace:
#   1. Copia la plantilla a <prefix>/share/informe-plantilla
#   2. Copia el CLI a <prefix>/bin/informe con la ruta de la plantilla grabada
#   3. Avisa si <prefix>/bin no está en el PATH

set -euo pipefail

PROG="informe"
SHARE_SUBDIR="informe-plantilla"

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_CLI="${REPO_ROOT}/bin/${PROG}"

# Archivos y carpetas que forman la plantilla que se copia al destino.
TEMPLATE_FILES=(plantilla.typ config.typ main.typ referencias.bib)
TEMPLATE_DIRS=(secciones imagenes)

# ---------------------------------------------------------------- salida ----

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    C_RESET=$'\033[0m'; C_OK=$'\033[32m'; C_WARN=$'\033[33m'
    C_HEAD=$'\033[1;36m'; C_DIM=$'\033[90m'
else
    C_RESET=""; C_OK=""; C_WARN=""; C_HEAD=""; C_DIM=""
fi

say()  { printf '%s\n' "$*"; }
title() { printf '%s\n' "${C_HEAD}$*${C_RESET}"; }
ok()   { printf '%s %s\n' "${C_OK}OK${C_RESET}" "$*"; }
warn() { printf '%s %s\n' "${C_WARN}aviso:${C_RESET}" "$*"; }
die()  { printf '%s %s\n' "${C_WARN}error:${C_RESET}" "$*" >&2; exit 1; }
dim()  { printf '   %s%s%s\n' "${C_DIM}" "$*" "${C_RESET}"; }

usage() {
    cat <<EOF
${C_HEAD}Instalador de la plantilla de informes (${PROG})${C_RESET}

Uso:
  ./install.sh [opciones]

Opciones:
  --prefix DIR   Carpeta de instalación.
                 Por defecto: \$HOME/.local
                 (con sudo: sudo ./install.sh --prefix /usr/local)
  --uninstall    Elimina el comando y la plantilla instalada.
  -h, --help     Muestra esta ayuda.

Requisitos:
  - macOS o Linux
  - Python 3.8 o superior (${PROG} está escrito en Python)
  - Typst 0.11 o superior, para compilar los PDF
    https://typst.app/docs/install/
EOF
}

# ------------------------------------------------------------ argumentos ----

PREFIX="${HOME}/.local"
ACTION="install"

while [ $# -gt 0 ]; do
    case "$1" in
        --prefix)
            [ $# -ge 2 ] || die "--prefix necesita una carpeta"
            PREFIX="$2"
            shift 2
            ;;
        --prefix=*) PREFIX="${1#*=}"; shift ;;
        --uninstall) ACTION="uninstall"; shift ;;
        -h|--help)   usage; exit 0 ;;
        *)           usage >&2; die "opción desconocida: $1" ;;
    esac
done

case "$PREFIX" in
    /*) ;;
    *) PREFIX="$(cd -- "$(dirname -- "$PREFIX")" 2>/dev/null && pwd)/$(basename -- "$PREFIX")" \
         || die "no se pudo resolver --prefix $PREFIX" ;;
esac

BIN_DIR="${PREFIX}/bin"
DATA_DIR="${PREFIX}/share/${SHARE_SUBDIR}"
TARGET_CLI="${BIN_DIR}/${PROG}"

# ------------------------------------------------------------- desinstalar --

if [ "$ACTION" = "uninstall" ]; then
    title "Desinstalando ${PROG}"
    if [ -e "$TARGET_CLI" ]; then
        rm -f "$TARGET_CLI"
        ok "comando eliminado: ${TARGET_CLI}"
    else
        dim "no había comando en ${TARGET_CLI}"
    fi
    if [ -d "$DATA_DIR" ]; then
        rm -rf "$DATA_DIR"
        ok "plantilla eliminada: ${DATA_DIR}"
    else
        dim "no había plantilla en ${DATA_DIR}"
    fi
    say ""
    ok "desinstalación completa"
    exit 0
fi

# ------------------------------------------------------------- comprobar ----

title "Instalando ${PROG} para ${USER:-$(id -un)}"

OS="$(uname -s)"
case "$OS" in
    Darwin) dim "sistema: macOS ($(sw_vers -productVersion 2>/dev/null || echo '?'))" ;;
    Linux)  dim "sistema: Linux ($(uname -r))" ;;
    *)      warn "sistema no verificado: ${OS}. Se intenta instalar de todos modos." ;;
esac

if [ ! -f "$SOURCE_CLI" ]; then
    die "no encuentro el CLI en ${SOURCE_CLI}"
fi

PYTHON=""
for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1; then
        if "$candidate" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)' 2>/dev/null; then
            PYTHON="$candidate"
            break
        fi
    fi
done
if [ -z "$PYTHON" ]; then
    die "no encuentro Python 3.8 o superior.
     macOS:  brew install python
     Debian: sudo apt install python3
     Fedora: sudo dnf install python3"
fi
dim "python: $(command -v "$PYTHON") ($("$PYTHON" --version 2>&1))"

if command -v typst >/dev/null 2>&1; then
    dim "typst: $(typst --version 2>/dev/null | head -n 1)"
else
    warn "no encuentro typst. ${PROG} crea el proyecto igual, pero necesitarás Typst para
     compilarlo:  https://typst.app/docs/install/"
fi

# -------------------------------------------------------------- instalar ----

# 1. La plantilla va a <prefix>/share/informe-plantilla
if [ -d "$DATA_DIR" ] && [ ! -f "${DATA_DIR}/.stamp" ]; then
    warn "${DATA_DIR} ya existe y no fue creado por este instalador."
    warn "Se sobreescribe. Borra esa carpeta si contiene algo importante."
fi

mkdir -p "$DATA_DIR"
for name in "${TEMPLATE_FILES[@]}"; do
    if [ ! -f "${REPO_ROOT}/${name}" ]; then
        die "falta ${name} en el repositorio"
    fi
    cp -f "${REPO_ROOT}/${name}" "${DATA_DIR}/${name}"
done
for name in "${TEMPLATE_DIRS[@]}"; do
    if [ -d "${REPO_ROOT}/${name}" ]; then
        rm -rf "${DATA_DIR:?}/${name}"
        cp -R "${REPO_ROOT}/${name}" "${DATA_DIR}/${name}"
    fi
done
: > "${DATA_DIR}/.stamp"
ok "plantilla copiada a ${DATA_DIR}"

# 2. El CLI va a <prefix>/bin/informe, con la ruta de la plantilla ya escrita
mkdir -p "$BIN_DIR"
"$PYTHON" - "$SOURCE_CLI" "$TARGET_CLI" "$DATA_DIR" "$PROG" <<'PY'
import os
import sys

source, target, data_dir, prog = sys.argv[1:5]

with open(source, encoding="utf-8") as handle:
    content = handle.read()

# Se reemplaza la ruta de la plantilla por la definitiva y se fija el nombre
# del programa, para que los mensajes de error y de ayuda sean precisos.
old = 'INSTALLED_TEMPLATE_DIR = ""'
if old not in content:
    sys.exit("bin/%s no contiene la línea %s" % (prog, old))
content = content.replace(old, 'INSTALLED_TEMPLATE_DIR = %r' % data_dir, 1)
content = content.replace('PROG = "%s"' % prog, 'PROG = %r' % prog, 1)

tmp = target + ".tmp"
with open(tmp, "w", encoding="utf-8") as handle:
    handle.write(content)
os.chmod(tmp, 0o755)
os.replace(tmp, target)
PY
ok "comando instalado en ${TARGET_CLI}"

# 3. Aviso sobre el PATH
say ""
case ":${PATH}:" in
    *":${BIN_DIR}:"*)
        ok "${BIN_DIR} ya está en tu PATH"
        ;;
    *)
        warn "${BIN_DIR} no está en tu PATH."
        say ""
        say "Agrega esta línea a tu ~/.bashrc, ~/.zshrc o ~/.profile:"
        say ""
        say "    export PATH=\"${BIN_DIR}:\$PATH\""
        say ""
        say "Y luego ejecuta:  source ~/.zshrc   (o ~/.bashrc)"
        say "Si instalaste en /usr/local y usas sudo, no hace falta tocar el PATH."
        ;;
esac

# 4. Comprobación final
say ""
if "$TARGET_CLI" --version >/dev/null 2>&1; then
    ok "verificación: $("$TARGET_CLI" --version)"
else
    warn "el comando no responde. Prueba:  ${TARGET_CLI} --version"
    warn "si sigue fallando, ejecuta:  INFORME_TEMPLATE_DIR=${DATA_DIR} ${TARGET_CLI} --version"
fi

say ""
title "Listo. Prueba esto:"
say ""
say "    ${PROG} mi-informe        # crea ./mi-informe con la plantilla"
say "    cd mi-informe"
say "    typst compile main.typ   # genera mi-informe.pdf"
say ""
say "Para desinstalar:  ./install.sh --uninstall"
say ""
