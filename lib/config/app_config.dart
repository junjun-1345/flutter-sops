import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class AppConfig {
  static Map<String, dynamic> _config = {};
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final configString =
          await rootBundle.loadString('assets/config/secrets.yaml');
      final yamlDoc = loadYaml(configString);
      _config = _convertYamlToMap(yamlDoc);
      _initialized = true;
    } catch (e) {
      _config = {};
    }
  }

  static Map<String, dynamic> _convertYamlToMap(dynamic yaml) {
    if (yaml is YamlMap) {
      return Map<String, dynamic>.from(
        yaml.map(
          (key, value) => MapEntry(key.toString(), _convertYamlToMap(value)),
        ),
      );
    } else if (yaml is YamlList) {
      return {'list': yaml.map((item) => _convertYamlToMap(item)).toList()};
    }
    return yaml;
  }

  static String get apiKey => _config['api']?['key'] ?? '';
  static String get dbPassword => _config['database']?['password'] ?? '';

  static Map<String, dynamic> get all => _config;
}
