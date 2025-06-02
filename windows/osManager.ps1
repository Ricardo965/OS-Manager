#  Herramienta de administracion.

function Mostrar-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "=============== MENÚ PRINCIPAL DE ADMINISTRACIÓN ==============="
    Write-Host "Procesos:"
    Write-Host "  1. Listar procesos"
    Write-Host "  2. Top 5 procesos por consumo de CPU"
    Write-Host "  3. Top 5 procesos por consumo de Memoria"
    Write-Host "  4. Terminar un proceso"
    Write-Host "Usuarios:"
    Write-Host "  5. Listar usuarios del sistema"
    Write-Host "  6. Listar usuarios por vejez de contraseña"
    Write-Host "  7. Cambiar contraseña de un usuario"
    Write-Host "Backup:"
    Write-Host "  8. Realizar backup del directorio de usuarios"
    Write-Host "Sistema:"
    Write-Host "  9. Apagar el equipo"
    Write-Host "  0. Salir"
    Write-Host "=============================================================="
}

function Listar-Procesos {
    Get-Process | Sort-Object Name | Format-Table Id, ProcessName, CPU, WS -AutoSize
}

function Top5-CPU {
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table Id, ProcessName, CPU -AutoSize
}

function Top5-Memoria {
    Get-Process | Sort-Object WS -Descending | Select-Object -First 5 | Format-Table Id, ProcessName, @{Name="Memoria(MB)";Expression={"{0:N2}" -f ($_.WS / 1MB)}} -AutoSize
}

function Terminar-Proceso {
    $pidNumber = Read-Host "Ingrese el PID del proceso que desea terminar"
    try {
        Stop-Process -Id $pidNumber -Force
        Write-Host "Proceso $pidNumber terminado correctamente."
    } catch {
        Write-Host "Error al terminar el proceso: $_"
    }
}

function Listar-Usuarios {
    Get-LocalUser | Format-Table Name, Enabled, LastLogon -AutoSize
}

function Usuarios-Por-Vejez {
    Get-LocalUser | Sort-Object PasswordLastSet | Format-Table Name, PasswordLastSet -AutoSize
}

function Cambiar-Password {
    $usuario = Read-Host "Ingrese el nombre del usuario"
    $nuevaPass = Read-Host "Ingrese la nueva contraseña" -AsSecureString
    try {
        Set-LocalUser -Name $usuario -Password $nuevaPass
        Write-Host "Contraseña cambiada correctamente para el usuario $usuario."
    } catch {
        Write-Host "Error al cambiar la contraseña: $_"
    }
}
function Apagar-Equipo {
    Stop-Computer
}


# Realizar respaldo de C:\Users

function Realizar-Backup {
    # Obtener fecha y hora actual para nombrar el archivo
    $fecha = Get-Date -Format "yyyyMMdd_HHmmss"

    # Obtener ruta del directorio actual y crear carpeta usersBackUp
    $rutaActual = Get-Location
    $rutaDestino = Join-Path $rutaActual "usersBackUp"

    # Crear la carpeta si no existe
    if (-not (Test-Path $rutaDestino)) {
        New-Item -Path $rutaDestino -ItemType Directory | Out-Null
        Write-Host "Se creó el directorio automáticamente en: $rutaDestino"
    }

    # Nombre del archivo de backup
    $nombreBackup = "UserBackup_$fecha.zip"
    $rutaCompleta = Join-Path $rutaDestino $nombreBackup

    # Comprimir todo el contenido de C:\Users
    Compress-Archive -Path "$env:SystemDrive\Users\*" -DestinationPath $rutaCompleta -Force

    Write-Host "✅ Backup creado exitosamente en: $rutaCompleta"
}


# Ejecución automática diaria a las 3:00 a.m.

function Programar-Backup-Automatico {
    if (-not (Get-ScheduledTask -TaskName "UserBackupDaily" -ErrorAction SilentlyContinue)) {
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$PSCommandPath`" -BackupAuto"
        $trigger = New-ScheduledTaskTrigger -Daily -At 3:00am
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        Register-ScheduledTask -TaskName "UserBackupDaily" -Action $action -Trigger $trigger -Principal $principal -Force

        Write-Host "🕒 Tarea programada 'UserBackupDaily' creada exitosamente. Se ejecutará todos los días a las 3:00 a.m."
    }
}


# Verificación para ejecución automática

param(
    [switch]$BackupAuto
)

if ($BackupAuto) {
    Realizar-Backup
    exit
}
# Programar la tarea si no existe
Programar-Backup-Automatico

# Bucle principal del menú
do {
    Mostrar-Menu
    $opcion = Read-Host "Selecciona una opción"
    switch ($opcion) {
        "1" { Listar-Procesos; Pause }
        "2" { Top5-CPU; Pause }
        "3" { Top5-Memoria; Pause }
        "4" { Terminar-Proceso; Pause }
        "5" { Listar-Usuarios; Pause }
        "6" { Usuarios-Por-Vejez; Pause }
        "7" { Cambiar-Password; Pause }
        "8" { Realizar-Backup; Pause }
        "9" { Apagar-Equipo }
        "0" { Write-Host "Saliendo..."; break }
        default { Write-Host "Opción inválida. Intente de nuevo."; Pause }
    }
} while ($true)
