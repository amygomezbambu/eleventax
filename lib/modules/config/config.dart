enum WindowMode { normal, maximized }

class Config {
  static WindowMode windowMode = WindowMode.normal;
  static var deviceId = '7273637373-Test';
  static var loggedUser = 'Jhon Doe';

  void save() {}

  void load() {}
}
