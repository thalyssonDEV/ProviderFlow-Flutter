import 'package:flutter/material.dart';
import '../../../shared/database/database_helper.dart';
import '../../../shared/utils/session_manager.dart';
import 'client_details_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  @override
  Widget build(BuildContext context) {
    final providerId = SessionManager().loggedProviderId;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Clientes')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getClientsByProvider(providerId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final clients = snapshot.data!;
          
          if (clients.isEmpty) {
            return const Center(child: Text('Nenhum cliente encontrado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final c = clients[index];
              return Card(
                color: const Color(0xFF2D2D44),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.2),
                    child: const Icon(Icons.person, color: Colors.blueAccent),
                  ),
                  title: Text(c['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text(c['plan_type'] ?? 'Sem plano'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientDetailsScreen(client: c),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}