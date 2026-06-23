import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_config.dart';
import 'bootstrap.dart';

// Default entry point — Development
// Run: flutter run  (or  flutter run -t lib/main.dart)
Future<void> main() async {
  await dotenv.load(fileName: '.env.dev');
  AppConfig.setEnvironment(AppEnvironment.dev);
  await bootstrap();
}

// test
void mainProd(String envFile) async {
  await dotenv.load(fileName: envFile);
  AppConfig.setEnvironment(AppEnvironment.prod);
  await bootstrap();
  
}
