import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_config.dart';
import 'bootstrap.dart';

// Staging / UAT entry point
// Run: flutter run -t lib/main_staging.dart
Future<void> main() async {
  await dotenv.load(fileName: '.env.staging');
  AppConfig.setEnvironment(AppEnvironment.staging);
  await bootstrap();
}
