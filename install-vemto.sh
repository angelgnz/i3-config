#!/bin/bash

# Comprueba si curl y wget están instalados
command -v curl >/dev/null 2>&1 || { echo >&2 "curl no está instalado.  Abortando."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "wget no está instalado.  Abortando."; exit 1; }

# Crear carpeta ~/.icons si no existe
mkdir -p ~/.icons

# Descarga la última versión de Vemto
echo "Descargando Vemto..."
APPIMAGE_URL=$(curl -s https://api.github.com/repos/TiagoSilvaPereira/vemto2-releases/releases/latest | \
grep "browser_download_url.*AppImage" | cut -d '"' -f 4)

if [ -z "$APPIMAGE_URL" ]; then
    echo "Error: No se pudo obtener la URL de descarga."
    exit 1
fi

wget "$APPIMAGE_URL" -O vemto.AppImage

# Hacer que el archivo AppImage sea ejecutable
chmod +x vemto.AppImage

# Mover el archivo AppImage a /bin y ajustar permisos a 755
echo "Moviendo Vemto.AppImage a /bin..."
sudo mv vemto.AppImage /bin/Vemto.AppImage
sudo chmod 755 /bin/Vemto.AppImage

# Mover el icono a ~/.icons
ICON_PATH=~/.icons/vemto-logo.png
echo "Moviendo la imagen del icono a ~/.icons..."
cp vemto-logo.png "$ICON_PATH"

# Crear el archivo .desktop
DESKTOP_FILE="$HOME/.local/share/applications/vemto.desktop"

echo "Creando archivo .desktop..."
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=2
Name=Vemto
Exec=/bin/Vemto.AppImage
Icon=$ICON_PATH
Type=Application
Categories=Development;
EOF

# Copiar el archivo .desktop a /usr/share/applications
echo "Copiando el archivo .desktop a /usr/share/applications..."
sudo cp "$DESKTOP_FILE" /usr/share/applications/

# Actualizar el caché de iconos
update-desktop-database ~/.local/share/applications

echo "Vemto ha sido instalado y el archivo .desktop ha sido creado en ambos lugares."
