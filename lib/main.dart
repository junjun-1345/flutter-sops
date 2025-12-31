import 'package:flutter/material.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOPS Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: const SecretsPage(),
    );
  }
}

class SecretsPage extends StatelessWidget {
  const SecretsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOPS Secrets Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loaded Secrets:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildItem('API Key', AppConfig.apiKey),
            _buildItem('Database URL', AppConfig.databaseUrl),
            _buildItem('Secret Token', AppConfig.secretToken),
            const Divider(height: 32),
            const Text(
              'All Config:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppConfig.all.toString(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(
            value.isEmpty ? '(not loaded)' : value,
            style: TextStyle(
              fontFamily: 'monospace',
              color: value.isEmpty ? Colors.grey : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
