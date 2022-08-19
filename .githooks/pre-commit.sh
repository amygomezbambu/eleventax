#!/usr/bin/env bash

# Buscamos ubicación de comando flutter 
USER=`whoami`
export PATH="/usr/local/bin:/Users/$USER/fvm/default/bin:$PATH"

printf "\e[33;1m%s\e[0m\n === Ejecutando Flutter Analyzer! ===\n"
flutter analyze

if [ $? -ne 0 ]; then
  exit 1
fi

printf "✅ ✔ Flutter Analyze ejecutado correctamente.\n"

printf "\e[33;1m%s\e[0m\n === Ejecutando pruebas de unidad ===\n"
flutter test

if [ $? -ne 0 ]; then  
  exit 1
fi

printf "✅ ✔ Flutter test ejecutado correctamente\n"
