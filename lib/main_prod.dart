import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_config.dart';
import 'bootstrap.dart';

// Production entry point
// Run: flutter run -t lib/main_prod.dart
// Build: flutter build apk -t lib/main_prod.dart --release
Future<void> main() async {
  await dotenv.load(fileName: '.env.prod');
  AppConfig.setEnvironment(AppEnvironment.prod);
  await bootstrap();
}
