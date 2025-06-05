# Herramienta de administración
function showMenu {
    Clear-Host
    Write-Host " - Menu de Administracion del Sistema -"
    Write-Host "  1. Listar procesos"
    Write-Host "  2. Top 5 procesos por consumo de CPU"
    Write-Host "  3. Top 5 procesos por consumo de Memoria"
    Write-Host "  4. Terminar un proceso"
    Write-Host "Usuarios:"
    Write-Host "  5. Listar usuarios del sistema"
    Write-Host "  6. Listar usuarios por vejez de password"
    Write-Host "  7. Cambiar contraseña de un usuario"
    Write-Host "  8. Realizar backup del directorio de usuarios"
    Write-Host "Sistema:"
    Write-Host " 9. Apagar el equipo"
    Write-Host "  0. Salir"
}

function ListarProcesos {
    Get-Process | Sort-Object Name | Format-Table Id, ProcessName, CPU, WS -AutoSize
}

function Top5CPU {
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table Id, ProcessName, CPU -AutoSize
}

function Top5Memoria {
    Get-Process | Sort-Object WS -Descending | Select-Object -First 5 | Format-Table Id, ProcessName, @{Name="Memoria(MB)";Expression={"{0:N2}" -f ($_.WS / 1MB)}} -AutoSize
}

function TerminarProceso {
    $pidNumber = Read-Host "Ingrese el PID del proceso que desea terminar"
    if (-not ($pidNumber -as [int])) {
        Write-Host "PID invalido. Debe ser un numero entero." -ForegroundColor Red
        return
    }
    try {
        Stop-Process -Id $pidNumber -Force
        Write-Host "Proceso $pidNumber terminado correctamente."
    } catch {
        Write-Host "Error al terminar el proceso: $_" -ForegroundColor Red
    }
}

function ListarUsuarios {
    Get-LocalUser | Format-Table Name, Enabled, LastLogon -AutoSize
}

function UsuariosPorVejez {
    Get-LocalUser | Sort-Object PasswordLastSet | Format-Table Name, PasswordLastSet -AutoSize
}

function CambiarPassword {
    $usuario = Read-Host "Ingrese el nombre del usuario"
    if ([string]::IsNullOrWhiteSpace($usuario)) {
        Write-Host "El nombre del usuario no puede estar vacío." -ForegroundColor Red
        return
    }
    $nuevaPass = Read-Host "Ingrese la nueva password" -AsSecureString
    try {
        Set-LocalUser -Name $usuario -Password $nuevaPass
        Write-Host "Password cambiada correctamente para el usuario $usuario."
    } catch {
        Write-Host "Error al cambiar la password: $_" -ForegroundColor Red
    }
}
function BackupUserDirectory {
    $backupPath = Read-Host "Ingrese la ruta donde desea guardar el backup: "
    
    if (-not (Test-Path -Path $backupPath -IsValid)) {
        Write-Host "La ruta ingresada no es valida." -ForegroundColor Red
        return
    }
    
    if (-not (Test-Path -Path $backupPath)) {
        try {
            New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
            Write-Host "Directorio de backup creado en: $backupPath" -ForegroundColor Green
        } catch {
            Write-Host "Error al crear el directorio de backup: $_" -ForegroundColor Red
            return
        }
    }
    
    # Definir origen (directorio de usuarios) y destino (archivo ZIP)
    $usersDir = "$env:SystemDrive\Users"
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = Join-Path -Path $backupPath -ChildPath "Users_Backup_$timestamp.zip"
    
    if (-not (Test-Path -Path $usersDir)) {
        Write-Host "El directorio de usuarios no se encontro en: $usersDir" -ForegroundColor Red
        return
    }
    
    # Crear el backup
    try {
        Write-Host "Creando backup de $usersDir..." -ForegroundColor Yellow
        Write-Host "Esto puede tomar varios minutos dependiendo del tamaño del directorio..." -ForegroundColor Yellow
        
        
        Compress-Archive -Path $usersDir -DestinationPath $backupFile -CompressionLevel Optimal
        
        Write-Host "Backup completado exitosamente" -ForegroundColor Green
        Write-Host "Archivo creado: $backupFile" -ForegroundColor Green
        
        $backupInfo = Get-Item -Path $backupFile
        $sizeMB = [math]::Round($backupInfo.Length / 1MB, 2)
        Write-Host "Tamaño del backup: $sizeMB MB" -ForegroundColor Cyan
    } catch {
        Write-Host "Error al crear el backup: $_" -ForegroundColor Red
    }
}
function ApagarEquipo {
    Stop-Computer
}

# Bucle principal del menú
$ejecutando = $true

while ($ejecutando) {
    showMenu
    $opcion = Read-Host "Selecciona una opcion"
    switch ($opcion) {
        "1" { ListarProcesos; Read-Host "Presiona ENTER para continuar..." }
        "2" { Top5CPU; Read-Host "Presiona ENTER para continuar..." }
        "3" { Top5Memoria; Read-Host "Presiona ENTER para continuar..." }
        "4" { TerminarProceso; Read-Host "Presiona ENTER para continuar..." }
        "5" { ListarUsuarios; Read-Host "Presiona ENTER para continuar..." }
        "6" { UsuariosPorVejez; Read-Host "Presiona ENTER para continuar..." }
        "7" { CambiarPassword; Read-Host "Presiona ENTER para continuar..." }
        "8" { BackupUserDirectory; Read-Host "Presiona ENTER para continuar..." }
        "9" { ApagarEquipo }
        "0" {
            Write-Host "Saliendo del programa..."
            $ejecutando = $false
        }
        default {
            Write-Host "Opción invalida, intente de nuevo." -ForegroundColor Yellow
            Read-Host "Presiona ENTER para continuar..."
        }
    }
}