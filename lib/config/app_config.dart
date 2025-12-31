import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: 'lib/.env');
  }

  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String get databaseUrl => dotenv.env['DATABASE_URL'] ?? '';
  static String get secretToken => dotenv.env['SECRET_TOKEN'] ?? '';

  static Map<String, String> get all => dotenv.env;
}
