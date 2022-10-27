Set-Variable -Name "GIT_DIR" -Value (git rev-parse --git-dir)
Set-Variable -Name "RAIZ" -Value "C:\Code\eleventax"

Write-Host $RAIZ
Write-Host $GIT_DIR
Write-Host "Instalando hooks..."

# this command creates symlink to our pre-commit script
Write-Host "Creando symbolic link en directorio $GIT_DIR"
New-Item -ItemType SymbolicLink -Path "$RAIZ\$GIT_DIR\hooks\pre-commit" -Target "$RAIZ\.githooks\pre-commit.ps1"
ICACLS "$RAIZ\.githooks\pre-commit.ps1" /grant:r "everyone:(F)" /C

Write-Host "Listo!" 