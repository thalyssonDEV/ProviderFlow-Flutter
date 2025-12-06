import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/database/database_helper.dart';
import '../../../shared/utils/session_manager.dart';
import 'client_details_screen.dart';
import 'edit_client_screen.dart';

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
                color: Theme.of(context).cardTheme.color,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: Colors.blueAccent),
                  ),
                  title: Text(
                    c['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    c['plan_type'] ?? 'Sem plano',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'WhatsApp',
                        icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                        onPressed: () => _openWhatsApp(context, c['phone'] ?? ''),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            if (!mounted) return;
                            final changed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditClientScreen(client: c),
                              ),
                            );
                            if (changed == true && mounted) {
                              setState(() {});
                            }
                          } else if (value == 'delete') {
                            await _confirmAndDelete(context, c['id'] as int);
                            if (!mounted) return;
                            setState(() {});
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Editar')),
                          const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                        ],
                      ),
                    ],
                  ),
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

  Future<void> _confirmAndDelete(BuildContext context, int id) async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cliente'),
        content: const Text('Tem certeza que deseja excluir este cliente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await DatabaseHelper.instance.deleteClient(id);
        messenger.showSnackBar(const SnackBar(content: Text('Cliente excluído.')));
      } catch (e) {
        messenger.showSnackBar(const SnackBar(content: Text('Falha ao excluir.')));
      }
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String phone) async {
    // Capture messenger early to avoid using BuildContext after awaits
    final messenger = ScaffoldMessenger.of(context);
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) return;
    cleanPhone = cleanPhone.replaceFirst(RegExp(r'^\+'), '');
    final hasCountry = cleanPhone.startsWith('55');
    final fullNumber = hasCountry ? cleanPhone : '55$cleanPhone';

    final message = Uri.encodeComponent('Olá, tudo bem?');
    final nativeUri = Uri.parse('whatsapp://send?phone=$fullNumber&text=$message');
    final businessUri = Uri.parse('whatsapp-business://send?phone=$fullNumber&text=$message');
    final webUri = Uri.parse('https://wa.me/$fullNumber');
    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(businessUri)) {
        await launchUrl(businessUri, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('WhatsApp não disponível neste dispositivo.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Erro ao tentar abrir o WhatsApp.')),
      );
    }
  }
}