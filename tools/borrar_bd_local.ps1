$mydocuments = [environment]::getfolderpath("mydocuments")

if (Test-Path ("$mydocuments\eleventa.db")) { 
    remove-Item -Path "$mydocuments\eleventa.db" -Force   
    Write-Host "Base de datos eliminada"
}
else {
    Write-Host "Base de datos no existe"
}