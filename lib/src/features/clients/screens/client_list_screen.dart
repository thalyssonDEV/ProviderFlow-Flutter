import 'package:flutter/material.dart';
import '../../../shared/utils/session_manager.dart';
import '../controllers/client_controller.dart';
import '../models/client_model.dart';
import 'add_client_screen.dart';
import 'edit_client_screen.dart';
import 'client_details_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final _controller = ClientController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final providerId = SessionManager().loggedProviderId;
    if (providerId != null) {
      _controller.loadClients(providerId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddClient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddClientScreen()),
    );
    if (result == true) {
      final providerId = SessionManager().loggedProviderId;
      if (providerId != null) {
        _controller.loadClients(providerId);
      }
    }
  }

  void _navigateToEdit(ClientModel client) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditClientScreen(client: client)),
    );
    if (result == true) {
      final providerId = SessionManager().loggedProviderId;
      if (providerId != null) {
        _controller.loadClients(providerId);
      }
    }
  }

  void _navigateToDetails(ClientModel client) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClientDetailsScreen(client: client)),
    );
  }

  void _confirmDelete(ClientModel client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Cliente'),
        content: Text('Deseja excluir ${client.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final providerId = SessionManager().loggedProviderId;
              if (providerId != null) {
                await _controller.deleteClient(client.id!, providerId);
              }
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cliente excluído'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar por nome ou CPF',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _controller.setSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _controller.setSearchQuery(value),
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return DropdownButtonFormField<String?>(
                      initialValue: _controller.selectedPlanFilter,
                      decoration: InputDecoration(
                        labelText: 'Filtrar por plano',
                        prefixIcon: const Icon(Icons.filter_list),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Todos os planos')),
                        ..._controller.clients
                            .map((c) => c.planType)
                            .toSet()
                            .map((plan) => DropdownMenuItem(value: plan, child: Text(plan))),
                      ],
                      onChanged: (value) => _controller.setPlanFilter(value),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final clients = _controller.filteredClients;

          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isNotEmpty || _controller.selectedPlanFilter != null
                        ? 'Nenhum cliente encontrado'
                        : 'Nenhum cliente cadastrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            itemBuilder: (context, i) {
              final client = clients[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      client.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CPF: ${client.cpf}'),
                      Text('Plano: ${client.planType}'),
                      if (client.fullAddress.isNotEmpty)
                        Text(
                          client.fullAddress,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text('Detalhes')),
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          _navigateToDetails(client);
                          break;
                        case 'edit':
                          _navigateToEdit(client);
                          break;
                        case 'delete':
                          _confirmDelete(client);
                          break;
                      }
                    },
                  ),
                  onTap: () => _navigateToDetails(client),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              if (_searchController.text.isEmpty && _controller.selectedPlanFilter == null) {
                return const SizedBox.shrink();
              }
              return FloatingActionButton.small(
                heroTag: 'clear_filters',
                onPressed: () {
                  _searchController.clear();
                  _controller.clearFilters();
                },
                child: const Icon(Icons.clear_all),
              );
            },
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add_client',
            onPressed: _navigateToAddClient,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
