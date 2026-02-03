#!/bin/bash

# =============================================
# SCRIPT DE CONFIGURACIÓN PARA Archcraft i3wm
# Este script realiza las siguientes acciones:
# 1. Actualiza los atajos de teclado
# 2. Instala programas necesarios
# 3. Configura el desplazamiento natural
# 4. Copia archivos de configuración
# 5. Añade configuraciones adicionales
# =============================================

# ========================
# PARTE 1: Actualización de atajos de teclado
# ========================

# Archivo de configuración a modificar
CONFIG_FILE="$HOME/.config/i3/config.d/02_keybindings.conf"

# Archivo temporal
TEMP_FILE=$(mktemp)

echo "Actualizando atajos de teclado en el archivo de configuración..."

# Procesar el archivo para:
# 1. Comentar el atajo MOD+a focus parent
# 2. Reemplazar ALT+F1 por MOD+a para el lanzador rofi
sed -e 's/^bindsym $MOD+a focus parent/# &/' \
    -e 's|^bindsym $ALT+F1[[:space:]]*exec --no-startup-id $rofi_applets/rofi_launcher|bindsym $MOD+a \t\t\texec --no-startup-id $rofi_applets/rofi_launcher|' \
    "$CONFIG_FILE" > "$TEMP_FILE"

# Reemplazar el archivo original
mv "$TEMP_FILE" "$CONFIG_FILE"

echo "✅ Atajos actualizados correctamente:"
echo "   - Se comentó 'bindsym \$MOD+a focus parent'"
echo "   - Se reemplazó ALT+F1 por MOD+a para el lanzador rofi"

# ========================
# PARTE 2: Configuración de Picom (corner-radius)
# ========================

PICOM_FILE="$HOME/.config/i3/picom.conf"

echo "Configurando corner-radius en picom.conf..."

# Cambiar corner-radius de 0 a 12 en la sección delimitada por #-cr-start y #-cr-end
sed -i '/#-cr-start/,/#-cr-end/s/corner-radius = 0;/corner-radius = 12;/' "$PICOM_FILE"

# Verificar que el cambio se realizó correctamente
if grep -A 1 "#-cr-start" "$PICOM_FILE" | grep -q "corner-radius = 12;"; then
    echo "✅ corner-radius configurado a 12 correctamente"
else
    echo "⚠️  No se pudo verificar el cambio de corner-radius"
fi

# ========================
# PARTE 3: Configuración de i3 border size
# ========================

THEME_FILE="$HOME/.config/i3/config.d/01_theme.conf"

echo "Configurando i3_border_size en 01_theme.conf..."

# Cambiar i3_border_size a 0
sed -i 's/^set \$i3_border_size [0-9]\+$/set $i3_border_size 0/' "$THEME_FILE"

# Verificar que el cambio se realizó correctamente
if grep -q "^set \$i3_border_size 0$" "$THEME_FILE"; then
    echo "✅ i3_border_size configurado a 0 correctamente"
else
    echo "⚠️  No se pudo verificar el cambio de i3_border_size"
fi

# ========================
# PARTE 4: Instalación y configuración del sistema
# ========================

# Instalar programas desde el archivo 'programas'
echo "Instalando programas desde la lista 'programas'..."
yay -S --needed $(<programas)

# Configurar desplazamiento natural en el touchpad
echo "Configurando desplazamiento natural para el touchpad..."
xinput set-prop "MSFT0001:00 06CB:CE44 Touchpad" "libinput Natural Scrolling Enabled" 1

# Archivos que se copiarán
archivos=("i3_overgrive" "i3_nzxt")

# Ruta donde se copiarán los archivos
ruta_destino="$HOME/.config/i3/scripts/"

# Función para copiar archivos con verificación
copiar_archivo() {
    archivo_origen=$1

    # Verificar si el archivo origen existe
    if [ ! -f "$archivo_origen" ]; then
        echo "⚠️  El archivo $archivo_origen no existe."
        return 1
    fi

    # Copiar el archivo
    cp "$archivo_origen" "$ruta_destino"

    # Verificar si la copia fue exitosa
    if [ $? -eq 0 ]; then
        echo "✅ Archivo $archivo_origen copiado correctamente a $ruta_destino"
        # Hacer el archivo ejecutable
        chmod +x "$ruta_destino/$(basename "$archivo_origen")"
    else
        echo "❌ Error al copiar $archivo_origen a $ruta_destino"
        return 1
    fi
}

# Verificar si existe la carpeta destino
if [ ! -d "$ruta_destino" ]; then
    echo "La carpeta $ruta_destino no existe. Creándola..."
    mkdir -p "$ruta_destino"
    if [ $? -ne 0 ]; then
        echo "❌ No se pudo crear la carpeta $ruta_destino"
        exit 1
    fi
fi

# Copiar todos los archivos necesarios
echo "Copiando archivos de configuración..."
for archivo in "${archivos[@]}"; do
    copiar_archivo "$archivo"
done

# ========================
# PARTE 5: Configuración adicional para i3
# ========================

config_file="$HOME/.config/i3/config"

echo "Añadiendo configuraciones adicionales al archivo $config_file..."

# Añadir configuración de i3-layouts si no existe
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
    echo "✅ Configuración de i3-layouts añadida correctamente"
else
    echo "ℹ️  La configuración de i3-layouts ya existe en $config_file"
fi

# Modificar el archivo de autostart
autostart_file="$HOME/.config/i3/scripts/i3_autostart"
linea_nzxt='# Launch NZXT'
linea_overgrive='# Launch Overgrive'
script_nzxt='"$idir"/scripts/i3_nzxt'
script_overgrive='"$idir"/scripts/i3_overgrive'

if [ -f "$autostart_file" ]; then
    echo "Modificando el archivo de autostart..."
    
    if ! grep -q "$linea_nzxt" "$autostart_file"; then
        sed -i "/# Start mpd/i $linea_nzxt\n$script_nzxt\n" "$autostart_file"
        echo "✅ Se añadió la configuración para NZXT"
    fi

    if ! grep -q "$linea_overgrive" "$autostart_file"; then
        sed -i "/# Start mpd/i $linea_overgrive\n$script_overgrive\n" "$autostart_file"
        echo "✅ Se añadió la configuración para Overgrive"
    fi
else
    echo "⚠️  El archivo $autostart_file no existe"
fi

# ========================
# PARTE 6: Reinicio del sistema
# ========================

echo -e "\n¿Deseas reiniciar el sistema para aplicar los cambios?"
read -p "(Sí/No) [Por defecto: No] " respuesta

# Convertir respuesta a minúsculas y tomar primera letra
respuesta=${respuesta,,}
case ${respuesta:0:1} in
    s|y|j )
        echo -e "\n🔄 El sistema se reiniciará ahora..."
        sudo reboot
    ;;
    * )
        echo -e "\n❌ Reinicio cancelado."
        echo "Recuerda que algunos cambios requieren reinicio para aplicarse."
    ;;
esac

echo -e "\n🎉 Configuración completada con éxito!"
