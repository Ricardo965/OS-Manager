#!/bin/bash

# Directorio de destino para los backups 
backup_dir="/home/ricardo965/Documentos/Universidad/sem7/SisOp/Backups" # Elige un directorio adecuado
mkdir -p "$backup_dir"

# Nombre del archivo con fecha
fecha_actual=$(date +%Y%m%d_%H%M%S) # Para backups diarios, solo la fecha puede ser suficiente
nombre_archivo_backup="backup_home_${fecha_actual}.tar.gz"
ruta_completa_backup="$backup_dir/$nombre_archivo_backup"

# Comando de backup
# Registrar la salida en un log
tar -czvf "$ruta_completa_backup" /home >> "${backup_dir}/backup_log.txt" 2>&1

# Opcional: Eliminar backups antiguos (ej: más de 7 días)
find "$backup_dir" -name "backup_home_*.tar.gz" -type f -mtime +7 -delete >> "${backup_dir}/backup_log.txt" 2>&1

echo "Backup automático de /home completado: $ruta_completa_backup" >> "${backup_dir}/backup_log.txt#!/bin/bash

