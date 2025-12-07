import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/utils/session_manager.dart';
import '../controllers/client_controller.dart';
import '../models/client_model.dart';
import 'client_details_screen.dart';
import 'edit_client_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final ClientController _controller = ClientController();
  late int _providerId;

  @override
  void initState() {
    super.initState();
    final id = SessionManager().loggedProviderId;
    if (id != null) {
      _providerId = id;
      _controller.loadClients(_providerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Clientes')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) return const Center(child: CircularProgressIndicator());

          if (_controller.clients.isEmpty) {
            return const Center(child: Text('Nenhum cliente encontrado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _controller.clients.length,
            itemBuilder: (context, index) {
              final client = _controller.clients[index];
              return _buildClientCard(client);
            },
          );
        },
      ),
    );
  }

  Widget _buildClientCard(ClientModel client) {
    return Card(
      color: Theme.of(context).cardTheme.color,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2196F3).withAlpha(51),
          child: const Icon(Icons.person, color: Color(0xFF2196F3)),
        ),
        title: Text(
          client.name,
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        subtitle: Text(
          client.planType,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(179)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'WhatsApp',
              icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
              onPressed: () => _openWhatsApp(client.phone),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'edit') {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditClientScreen(client: client)),
                  );
                  if (changed == true && mounted) {
                    _controller.loadClients(_providerId);
                  }
                } else if (value == 'delete') {
                  await _confirmAndDelete(client);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'delete', child: Text('Excluir')),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClientDetailsScreen(client: client)),
          );
        },
      ),
    );
  }

  Future<void> _confirmAndDelete(ClientModel client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cliente'),
        content: const Text('Tem certeza que deseja excluir este cliente?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _controller.deleteClient(client.id!, _providerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente excluído.')));
      }
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
