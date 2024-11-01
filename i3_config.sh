#!/bin/bash

# Instalar programas
yay -S --needed $(<programas)

# Archivos a copiar
archivos=("i3_overgrive" "i3_nzxt")

# Ruta de destino
ruta_destino="$HOME/.config/i3/scripts/"

# Función para copiar un archivo
copiar_archivo() {
    archivo_origen=$1

    # Comprobar si el archivo de origen existe
    if [ ! -f "$archivo_origen" ]; then
        echo "El archivo $archivo_origen no existe."
        return 1
    fi

    # Copiar el archivo
    cp "$archivo_origen" "$ruta_destino"

    # Verificar si la copia fue exitosa
    if [ $? -eq 0 ]; then
        echo "Archivo $archivo_origen copiado exitosamente a $ruta_destino"
        # Hacer el archivo ejecutable
        chmod +x "$ruta_destino/$(basename "$archivo_origen")"
    else
        echo "Error al copiar el archivo $archivo_origen a $ruta_destino"
        return 1
    fi
}

# Comprobar si la carpeta de destino existe
if [ ! -d "$ruta_destino" ]; then
    echo "La carpeta de destino $ruta_destino no existe. Creando carpeta..."
    mkdir -p "$ruta_destino"
    if [ $? -ne 0 ]; then
        echo "No se pudo crear la carpeta de destino $ruta_destino."
        exit 1
    fi
fi

# Copiar los archivos
for archivo in "${archivos[@]}"; do
    copiar_archivo "$archivo"
done

# Configuración adicional
config_file="$HOME/.config/i3/config"

echo "Agregando configuración adicional al archivo $config_file..."

# Añadir configuración al final del archivo si no existe
if ! grep -q "exec i3-layouts" "$config_file"; then
    cat <<EOL >> "$config_file"

# Configuración de i3-layouts
exec xborders --border-width 2 --border-radius 12 --smart-hide-border
exec i3-layouts

set \$i3l spiral to workspace 1
set \$i3l spiral to workspace 2
set \$i3l spiral to workspace 3
set \$i3l spiral to workspace 4
set \$i3l spiral to workspace 5
set \$i3l spiral to workspace 6
set \$i3l spiral to workspace 7
set \$i3l spiral to workspace 8
set \$i3l spiral to workspace 9
set \$i3l spiral to workspace 0
EOL
    echo "Configuración de i3-layouts agregada exitosamente."
else
    echo "La configuración de i3-layouts ya existe en $config_file."
fi

# Modificar ~/.config/i3/scripts/i3_autostart
autostart_file="$HOME/.config/i3/scripts/i3_autostart"
linea_nzxt='# Launch NZXT'
linea_overgrive='# Launch Overgrive'
script_nzxt='"$idir"/scripts/i3_nzxt'
script_overgrive='"$idir"/scripts/i3_overgrive'

if [ -f "$autostart_file" ]; then
    if ! grep -q "$linea_nzxt" "$autostart_file"; then
        sed -i "/# Start mpd/i $linea_nzxt\n$script_nzxt\n" "$autostart_file"
    fi

    if ! grep -q "$linea_overgrive" "$autostart_file"; then
        sed -i "/# Start mpd/i $linea_overgrive\n$script_overgrive\n" "$autostart_file"
    fi
    echo "Modificación del archivo i3_autostart completada."
else
    echo "El archivo $autostart_file no existe."
fi

read -p "¿Quieres reiniciar el sistema en este momento? (s/N) " respuesta
if [[ -z "$respuesta" ]] ; then
    # Asuming 'n' como la respuesta por defecto si el usuario solo presiona Enter.
    respuesta="n"
fi

case ${respuesta:0:1} in
    s|S )
        echo 'El sistema se está reiniciando ahora ...'
        sudo reboot
    ;;
    * )
        echo 'Reinicio cancelado.'
    ;;
esac
