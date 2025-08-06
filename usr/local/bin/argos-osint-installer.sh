#!/bin/bash

LOGFILE="$HOME/osint-tools/osint-installer.log"
TOOLS_DIR="$HOME/osint-tools"
mkdir -p "$TOOLS_DIR"
cd "$TOOLS_DIR" || exit 1

# Comprobamos que whiptail esté instalado
if ! command -v whiptail &>/dev/null; then
  echo "Instalando whiptail..."
  sudo apt install -y whiptail
fi

# Función de log
log() {
    echo -e "$1" | tee -a "$LOGFILE"
}

# Función de instalación de paquetes con autoreparación
install_package() {
    local pkg="$1"
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        log "Instalando $pkg..."
        if ! sudo apt install -y "$pkg"; then
            log "Intentando corregir dependencias..."
            sudo apt --fix-broken install -y && sudo apt install -y "$pkg"
        fi
    else
        log "$pkg ya está instalado."
    fi
}

# Instalación de dependencias comunes
instalar_dependencias() {
    log "Instalando dependencias básicas..."
    local packages=(git curl wget build-essential python3 python3-pip python3-venv libffi-dev libssl-dev exiftool net-tools xfce4-terminal)
    for pkg in "${packages[@]}"; do
        install_package "$pkg"
    done
    pip install --upgrade pip
}

# Función para crear un lanzador en el menú XFCE
crear_launcher() {
    local nombre="$1"
    local script_py="$2"
    local ruta="$TOOLS_DIR/$nombre"
    local launcher="$HOME/.local/share/applications/${nombre}.desktop"

    cat <<EOF > "$launcher"
[Desktop Entry]
Type=Application
Name=$nombre
GenericName=Herramienta OSINT
Comment=Ejecutar $nombre desde terminal
Exec=xfce4-terminal --working-directory="$ruta" --command="python3 $script_py"
Icon=utilities-terminal
Categories=OSINT;Utility;
Terminal=true
EOF

    chmod +x "$launcher"
    update-desktop-database ~/.local/share/applications/
}

# Instalación desde repositorio
instalar_repo() {
    local nombre="$1"
    local repo="$2"
    local alias_cmd="$3"

    log "Instalando $nombre..."
    if git clone "$repo" "$nombre"; then
        cd "$nombre" || return
        [[ -f "requirements.txt" ]] && pip install -r requirements.txt || true
        chmod +x *.py 2>/dev/null
        cd ..

        # Crear alias (opcional)
        [[ -n "$alias_cmd" ]] && echo "alias $alias_cmd='python3 $TOOLS_DIR/$nombre/$alias_cmd.py'" >> ~/.bashrc

        # Crear lanzador en el menú
        crear_launcher "$nombre" "$alias_cmd.py"

        log "$nombre instalado correctamente."
    else
        log "Falló la instalación de $nombre"
    fi
}

# Instaladores individuales
instalar_spiderfoot()  { instalar_repo "SpiderFoot" "https://github.com/smicallef/spiderfoot.git" "spiderfoot"; }
instalar_photon()      { instalar_repo "Photon" "https://github.com/s0md3v/Photon.git" "photon"; }
instalar_sherlock()    { instalar_repo "Sherlock" "https://github.com/sherlock-project/sherlock.git" "sherlock"; }
instalar_holehe()      { instalar_repo "Holehe" "https://github.com/megadose/holehe.git" "holehe"; }
instalar_ghunt()       { instalar_repo "GHunt" "https://github.com/mxrch/GHunt.git" "ghunt"; }
instalar_metagoofil()  { instalar_repo "Metagoofil" "https://github.com/laramies/metagoofil.git" "metagoofil"; }

instalar_theharvester() {
    pip install theHarvester
    echo "alias theharvester='theHarvester'" >> ~/.bashrc
    crear_launcher "theHarvester" "theHarvester"
}

instalar_amass() {
    pip install amass
    echo "alias amass='amass'" >> ~/.bashrc
    crear_launcher "Amass" "amass"
}

# Instalación completa automática
instalacion_total() {
    instalar_dependencias
    instalar_theharvester
    instalar_amass
    instalar_spiderfoot
    instalar_photon
    instalar_sherlock
    instalar_holehe
    instalar_ghunt
    instalar_metagoofil

    log "Actualizando y mejorando sistema con apt update && upgrade..."
    sudo apt update && sudo apt upgrade -y
    log "Sistema actualizado correctamente."

    log "Instalación completa finalizada."
    xfdesktop --reload 2>/dev/null
}

# Instalación manual (menú herramienta por herramienta)
instalacion_manual() {
    OPTIONS=(
        1 "theHarvester" OFF
        2 "Amass" OFF
        3 "SpiderFoot" OFF
        4 "Photon" OFF
        5 "Sherlock" OFF
        6 "Holehe" OFF
        7 "GHunt" OFF
        8 "Metagoofil" OFF
    )
    SELECCION=$(whiptail --title "argOS OSINT - Instalación Manual" \
      --checklist "Seleccioná las herramientas a instalar:" 20 78 10 \
      "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

    instalar_dependencias

    for choice in $SELECCION; do
        case $choice in
        "\"1\"") instalar_theharvester ;;
        "\"2\"") instalar_amass ;;
        "\"3\"") instalar_spiderfoot ;;
        "\"4\"") instalar_photon ;;
        "\"5\"") instalar_sherlock ;;
        "\"6\"") instalar_holehe ;;
        "\"7\"") instalar_ghunt ;;
        "\"8\"") instalar_metagoofil ;;
        esac
    done

    xfdesktop --reload 2>/dev/null
}

# Menú principal
while true; do
    OPTION=$(whiptail --title "argOS OSINT Installer" --menu "Seleccioná una opción" 15 60 4 \
        "1" "Instalación automática (todas las herramientas)" \
        "2" "Instalación manual (elegir herramientas)" \
        "3" "Salir" 3>&1 1>&2 2>&3)

    case $OPTION in
    1) instalacion_total ;;
    2) instalacion_manual ;;
    3) break ;;
    esac
done

log "Finalizó el script. Revisá el log: $LOGFILE"
