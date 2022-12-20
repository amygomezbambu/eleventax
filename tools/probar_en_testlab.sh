#!/bin/zsh
pushd android
flutter build apk
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=integration_test/productos_test.dart
popd
echo "✅ Binario de Android generado..."

# //TODO: Documentar como instalar GCloud
gcloud auth activate-service-account --key-file="./testlab_serviceaccount.json"
gcloud --quiet config set project "eleventa"
gcloud firebase test android run --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk\
  --timeout 5m \
  --device model=b2q,version=30,locale=es,orientation=portrait  \
  --device model=bluejay,version=32,locale=en,orientation=portrait  \
  --device model=AndroidTablet270dpi,version=30,locale=es,orientation=landscape   
