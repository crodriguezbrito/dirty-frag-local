# Mitigación del dirty frag en versiones de Linux
# https://ubuntu.com/blog/dirty-frag-linux-vulnerability-fixes-available

#!/bin/bash

# Asegurar que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root o usando sudo."
  exit 1
fi

echo "==============================================="
CURRENT_HOST=$(hostname)
echo "Iniciando dirty frag en: $CURRENT_HOST" 

if [ ! -f /etc/modprobe.d/dirty-frag.conf ]; then

    CONF_FILE="/etc/modprobe.d/dirty-frag.conf"

    cat > $CONF_FILE << 'EOF'
install esp4 /bin/false
install esp6 /bin/false
install rxrpc /bin/false
EOF

    if [ -f "/etc/modprobe.d/dirty-frag.conf" ]; then
        echo "Archivo creado con éxito."
    else
        echo "El archivo no existe."
    fi

    echo "Actualizando initramfs..."
    sudo update-initramfs -u -k all

    echo "Intentando descargar módulos en ejecución..."
    sudo rmmod esp4 2>/dev/null || true
    sudo rmmod esp6 2>/dev/null || true
    sudo rmmod rxrpc 2>/dev/null || true

    echo "Verificación:"
    if lsmod | grep -E "esp4|esp6|rxrpc" >/dev/null; then
        echo "Algunos módulos siguen activos"
    else
        echo "No hay módulos vulnerables cargados"
    fi
else
    echo "Los módulos vulnerables no están cargados"
fi

echo "Proceso terminado para $CURRENT_HOST"
