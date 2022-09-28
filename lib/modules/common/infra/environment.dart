// Establecemos los secretos de la app por fuera al momento de ejecutar o compilar
// ejemplo:
// flutter run -d macos --dart-define=DB_PASSWORD=debugmode
// flutter build macos --dart-define=DB_PASSWORD=productionpassword
class Environment {
  // En producción se compilará la app con una contraseña especifica, en modo dev será 123 siempre
  //static const databasePassword =
  //String.fromEnvironment('DB_PASSWORD', defaultValue: "123");
}

//TODO: eliminar este archivo cuando ya este el CI funcionando con .env o cualquier
//otro metodo que decidamos
