#!/bin/bash

# Función para listar procesos
listar_procesos() {
    echo "--- Listado de Procesos ---"
    ps aux
    echo "---------------------------"
}

# Función para mostrar los 5 procesos que más CPU consumen
top_cpu_procesos() {
    echo "--- Top 5 Procesos por CPU ---"
    ps aux --sort=-%cpu | head -n 6
    echo "------------------------------"
}

# Función para mostrar los 5 procesos que más memoria consumen
top_mem_procesos() {
    echo "--- Top 5 Procesos por Memoria ---"
    ps aux --sort=-%mem | head -n 6
    echo "--------------------------------"
}

# Función para terminar un proceso
terminar_proceso() {
    echo "--- Terminar Proceso ---"
    read -p "Introduce el PID del proceso a terminar: " pid
    if [[ -z "$pid" ]]; then
        echo "No se introdujo ningún PID."
        return
    fi
    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        echo "PID inválido. Debe ser un número."
        return
    fi
    if kill "$pid"; then
        echo "Proceso $pid terminado."
    else
        echo "Error al terminar el proceso $pid. Verifica el PID o si tienes permisos."
    fi
    echo "------------------------"
}

# Función para listar usuarios del sistema
listar_usuarios() {
    echo "--- Listado de Usuarios del Sistema ---"
    awk -F':' '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd # UID >= 1000 para usuarios regulares
    # O de forma más simple pero incluye más:
    # getent passwd | awk -F: '{print $1}'
    echo "-------------------------------------"
}

# Función para listar usuarios por vejez de contraseña (requiere sudo)
# Esta es una aproximación, ya que obtener la "vejez" exacta de forma simple para todos es complejo.
# Mostraremos la última fecha de cambio de contraseña.
listar_usuarios_pass_vejez() {
    echo "--- Listado de Usuarios y Último Cambio de Contraseña (Requiere sudo) ---"
    if [[ $EUID -ne 0 ]]; then
        echo "Este comando necesita privilegios de superusuario. Ejecuta con sudo."
        return 1
    fi
    echo "Usuario         | Último Cambio de Contraseña"
    echo "----------------|----------------------------"
    for user in $(awk -F':' '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd); do
        # chage -l $user | grep 'Last password change' | awk '{print $NF}'
        last_change=$(sudo chage -l "$user" 2>/dev/null | grep 'Last password change' | awk -F': ' '{print $2}')
        if [[ -z "$last_change" ]]; then
            last_change="Nunca o información no disponible"
        fi
        printf "%-15s | %s\n" "$user" "$last_change"
    done
    echo "-----------------------------------------------------------------------"
    echo "Nota: Para un ordenamiento real por vejez, se necesitaría procesar estas fechas."
}

# Función para cambiar la contraseña de un usuario (requiere sudo)
cambiar_password_usuario() {
    echo "--- Cambiar Contraseña de Usuario (Requiere sudo) ---"
    if [[ $EUID -ne 0 ]]; then
        echo "Este comando necesita privilegios de superusuario. Ejecuta con sudo."
        return 1
    fi
    read -p "Introduce el nombre del usuario: " usuario
    if [[ -z "$usuario" ]]; then
        echo "No se introdujo ningún nombre de usuario."
        return
    fi
    if id "$usuario" &>/dev/null; then
        sudo passwd "$usuario"
    else
        echo "Usuario '$usuario' no encontrado."
    fi
    echo "-------------------------------------------------"
}

# Función para realizar backup del directorio de usuarios
realizar_backup_usuarios() {
    echo "--- Realizar Backup del Directorio /home ---"
    read -p "Introduce el directorio de destino para el backup (ej: /mnt/backups): " backup_dir

    if [[ -z "$backup_dir" ]]; then
        echo "No se introdujo un directorio de destino. Cancelando."
        return
    fi

    if [ ! -d "$backup_dir" ]; then
        echo "El directorio de destino '$backup_dir' no existe. ¿Deseas crearlo? (s/N)"
        read -r crear_dir_respuesta
        if [[ "$crear_dir_respuesta" =~ ^([sS][iI]|[sS])$ ]]; then
            mkdir -p "$backup_dir"
            if [ $? -ne 0 ]; then
                echo "Error al crear el directorio '$backup_dir'. Verifica los permisos."
                return
            fi
            echo "Directorio '$backup_dir' creado."
        else
            echo "Cancelando backup."
            return
        fi
    fi

    fecha_actual=$(date +%Y%m%d_%H%M%S)
    nombre_archivo_backup="backup_home_${fecha_actual}.tar.gz"
    ruta_completa_backup="$backup_dir/$nombre_archivo_backup"

    echo "Directorio de origen: /home"
    echo "Directorio de destino: $backup_dir"
    echo "Nombre del archivo: $nombre_archivo_backup"
    read -p "¿Estás seguro de que deseas continuar con el backup? (s/N): " confirmacion
    if [[ "$confirmacion" =~ ^([sS][iI]|[sS])$ ]]; then
        echo "Realizando backup de /home en $ruta_completa_backup ..."
        # Se recomienda ejecutar con sudo si hay directorios de usuario con permisos restringidos
        if tar -czvf "$ruta_completa_backup" /home; then
            echo "Backup completado exitosamente: $ruta_completa_backup"
        else
            echo "Error al realizar el backup. Verifica los permisos o el espacio en disco."
        fi
    else
        echo "Backup cancelado."
    fi
    echo "--------------------------------------------"
}

# Función para apagar el equipo (requiere sudo)
apagar_equipo() {
    echo "--- Apagar Equipo (Requiere sudo) ---"
    if [[ $EUID -ne 0 ]]; then
        echo "Este comando necesita privilegios de superusuario. Ejecuta con sudo."
        return 1
    fi
    read -p "¿Estás seguro de que deseas apagar el equipo AHORA? (s/N): " confirmacion
    if [[ "$confirmacion" =~ ^([sS][iI]|[sS])$ ]]; then
        echo "Apagando el equipo..."
        sudo shutdown -h now
    else
        echo "Apagado cancelado."
    fi
    echo "-----------------------------------"
}

# Menú principal
while true; do
    echo ""
    echo "=============== MENÚ PRINCIPAL DE ADMINISTRACIÓN ==============="
    echo "Procesos:"
    echo "  1. Listar procesos"
    echo "  2. Top 5 procesos por consumo de CPU"
    echo "  3. Top 5 procesos por consumo de Memoria"
    echo "  4. Terminar un proceso"
    echo "Usuarios:"
    echo "  5. Listar usuarios del sistema"
    echo "  6. Listar usuarios por vejez de contraseña (sudo)"
    echo "  7. Cambiar contraseña de un usuario (sudo)"
    echo "Backup:"
    echo "  8. Realizar backup del directorio /home"
    echo "Sistema:"
    echo "  9. Apagar el equipo (sudo)"
    echo "  0. Salir"
    echo "=============================================================="
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) listar_procesos ;;
        2) top_cpu_procesos ;;
        3) top_mem_procesos ;;
        4) terminar_proceso ;;
        5) listar_usuarios ;;
        6) listar_usuarios_pass_vejez ;;
        7) cambiar_password_usuario ;;
        8) realizar_backup_usuarios ;;
        9) apagar_equipo ;;
        0) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción inválida. Por favor, intenta de nuevo." ;;
    esac
    echo ""
    read -n 1 -s -r -p "Presiona cualquier tecla para continuar..."
    clear # Limpia la pantalla para el siguiente menú
done
