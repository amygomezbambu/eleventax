// Establecemos los secretos de la app por fuera al momento de ejecutar o compilar
// ejemplo:
// flutter run -d macos --dart-define=DB_PASSWORD=debugmode
// flutter build macos --dart-define=DB_PASSWORD=productionpassword
class Environment {
  static const databasePassword = String.fromEnvironment('DB_PASSWORD');
}
