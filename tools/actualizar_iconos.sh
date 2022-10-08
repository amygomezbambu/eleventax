#!/bin/bash

# Este script sirve para actualizar los iconos de las distintas plataformas cuando se actualice desde Figma
# El icono se puede actualizar desde: https://www.figma.com/file/j98DQt7fixpxRLBAXAE9IG/eleventa-Icon-Design  
# siguiendo las instrucciones para exportar el icono para todas las plataformas
# posteriormente ejecutar este script para que lo copie a las rutas correctas de cada plataforma 

echo Por favor ingresa ruta de iconos generada por Figma:
read ruta

# iOS Icons
echo "Copiando iconos de iOS..."
cp $ruta/Apple/App_store_1024_1x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPad_App_76_1x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPad_App_76_2x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPad_Notifications_20_1x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPad_Notifications_20_2x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPad_Pro_App_83.5_2x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPad_Settings_29_1x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPad_Settings_29_2x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPad_Spotlight_40_1x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPad_Spotlight_40_2x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPhone_App_60_2x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPhone_App_60_3x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPhone_Notifications_20_2x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPhone_Notifications_20_3x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPhone_Settings_29_2x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPhone_Settings_29_3x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPhone_Spotlight_40_2x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset
cp $ruta/Apple/iPhone_Spotlight_40_3x.png ../ios/Runner/Assets.xcassets/AppIcon.appiconset

# macOS Icons
echo "Copiando iconos de macOS..."
cp $ruta/Mac/* ../macOS/Runner/Assets.xcassets/AppIcon.appiconset

# Android
echo "Copiando iconos de Android..."
cp $ruta/Android/ic_launcher_hdpi.png ../android/app/src/main/res/mipmap-hdpi/ic_launcher.png
cp $ruta/Android/ic_launcher_mdpi.png ../android/app/src/main/res/mipmap-mdpi/ic_launcher.png
cp $ruta/Android/ic_launcher_xhdpi.png ../android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
cp $ruta/Android/ic_launcher_xxhdpi.png ../android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
cp $ruta/Android/ic_launcher_xxxhdpi.png ../android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

echo "Generando iconos de Windows..."
# TODO: Generar iconos para Windows (ico)