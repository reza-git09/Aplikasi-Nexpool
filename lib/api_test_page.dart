import 'package:flutter/material.dart';
import 'services/api_service.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  late Future<List<dynamic>> kolamFuture;

  @override
  void initState() {
    super.initState();
    kolamFuture = ApiService.getKolamRenang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API NEXPOOL'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: kolamFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'ERROR:\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final kolam = snapshot.data ?? [];

          if (kolam.isEmpty) {
            return const Center(
              child: Text('Data kolam kosong'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kolam.length,
            itemBuilder: (context, index) {
              final item = kolam[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(
                    Icons.pool,
                    size: 35,
                  ),
                  title: Text(
                    item['nama_kolam'] ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${item['kota'] ?? '-'}\n'
                    'Pool ID: ${item['pool_id'] ?? '-'}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}