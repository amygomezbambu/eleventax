# Buscamos ubicacion de comando flutter 

#Set-Variable -Name "USER" -Value ($env:UserName)
#Write-Host $USER


#Revisamos si existe la variable de entorno FLUTTER_ROOT
if (!(Test-Path 'env:FLUTTER_ROOT')) { 
  Write-Host -ForegroundColor Red "Define la variable de entorno FLUTTER_ROOT"
  exit 1
}

if (! $?)
{
    Write-Host -ForegroundColor Red "Error al buscar la variable de entorno FLUTTER_ROOT"
    exit 1
}  

Write-Host -ForegroundColor Green "=== Ejecutando Flutter Analyzer! ==="

flutter analyze 

if (! $?)
{
    Write-Host -ForegroundColor Red "Error al ejecutar Flutter Analyzer"
    exit 1
}


Write-Host -ForegroundColor Green "✔ Flutter Analyze ejecutado correctamente."

Write-Host -ForegroundColor Green "=== Ejecutando pruebas de unidad ==="

flutter test --test-randomize-ordering-seed=random -rexpanded

if (! $?)
{
    Write-Host -ForegroundColor Red "Error en prueba de unidad"
    exit 1
}

Write-Host -ForegroundColor Green "✔ Flutter test ejecutado correctamencte"