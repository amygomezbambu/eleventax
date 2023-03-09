import 'package:integration_test/integration_test.dart';
import 'smoke_test.dart' as smoke;
import 'productos_test.dart' as productos;

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  smoke.main();
  productos.main();
}
