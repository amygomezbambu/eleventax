#!/bin/zsh

echo "Verificando que tengas credenciales..."
if [ ! -f "./testlab_serviceaccount.json" ]; then
    echo "🔵 Descargando credenciales de TestLab..."
    op read -o ./testlab_serviceaccount.json "op://eleventax/eleventax - TestLab Service Account/testlab_serviceaccount.json" 
    if [ $? -eq 0 ] 
    then 
      echo "✅ Credenciales de TesLab obtenidas correctamente."
      pushd android
      flutter build apk
      ./gradlew app:assembleAndroidTest
      ./gradlew app:assembleDebug -Ptarget=integration_test/productos_test.dart
      popd
      echo "✅ Binario de Android generado..."

      # //TODO: Documentar como instalar GCloud
      gcloud auth activate-service-account --key-file="./testlab_serviceaccount.json"
      gcloud --quiet config set project "eleventa"
      echo "✅ Ejecutando pruebas en TestLab, esto tardará varios minutos..."
      gcloud firebase test android run --type instrumentation \
        --app build/app/outputs/apk/debug/app-debug.apk \
        --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk\
        --timeout 5m \
        --device model=b2q,version=30,locale=es,orientation=portrait  \
        --device model=bluejay,version=32,locale=en,orientation=portrait  \
        --device model=AndroidTablet270dpi,version=30,locale=es,orientation=landscape  
    else 
      echo "🔴 Ocurrió un error al obtener las credenciales" >&2 
    fi
         
    echo "🔵 Borrando credenciales de TestLab por seguridad..."
    rm ./testlab_serviceaccount.json
else
  echo "🔴 No tienes credenciales de TestLab, favor de verificar acceso a 1Password"
  exit 1
fi


