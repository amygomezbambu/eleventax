
Set-Location -Path "C:\Code\eleventax"
Set-Variable -Name "GIT_DIR" -Value (git rev-parse --git-dir)
Set-Variable -Name "RAIZ" -Value "C:\Code\eleventax"

Write-Host $RAIZ
Write-Host $GIT_DIR
Write-Host "Instalando hooks..."

#Si existe un archivo "pre-commit" lo eliminamos y creamos uno nuevo
if (Test-Path "$RAIZ\$GIT_DIR\hooks\pre-commit") { 
  Write-Host -ForegroundColor Red "Archivo pre-commit pre existente, se eliminara"
  Remove-Item -Path "$RAIZ\$GIT_DIR\hooks\pre-commit"
}

# this command creates symlink to our pre-commit script
Write-Host "Creando symbolic link en directorio $GIT_DIR\hooks"
New-Item -ItemType SymbolicLink -Path "$RAIZ\$GIT_DIR\hooks\pre-commit" -Target "$RAIZ\.githooks\pre-commit.bat"
ICACLS "$RAIZ\.githooks\pre-commit.bat" /grant:r "everyone:(F)" /C

Write-Host "Listo!" 