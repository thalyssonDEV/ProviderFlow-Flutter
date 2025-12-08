import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/utils/session_manager.dart';
import '../clients/controllers/client_controller.dart';
import 'controllers/map_controller.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  final _clientController = ClientController();
  final _nameSearchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameSearchController.dispose();
    super.dispose();
  }

  void _loadData() async {
    final providerId = SessionManager().loggedProviderId;
    if (providerId != null) {
      await _clientController.loadClients(providerId);
    }
    await _mapController.loadMarkers(onMarkerTap: _showClientDetails);
  }

  Future<void> _openWhatsApp(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final url = Uri.parse('https://wa.me/55$cleanPhone');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp'), backgroundColor: Colors.red),
      );
    }
  }

  void _showClientDetails(String clientId) {
    final client = _mapController.allClients.firstWhere((c) => c.id.toString() == clientId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          client.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Plano: ${client.planType}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.badge, 'CPF', client.cpf),
                  _buildInfoRow(Icons.phone, 'Telefone', client.phone),
                  if (client.fullAddress.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.location_on, 'Endereço', client.fullAddress),
                  ],
                  if (client.latitude != null && client.longitude != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.map,
                      'Coordenadas',
                      '${client.latitude!.toStringAsFixed(6)}, ${client.longitude!.toStringAsFixed(6)}',
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () => _openWhatsApp(context, client.phone),
                      icon: const Icon(Icons.message),
                      label: const Text('Conversar no WhatsApp'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Clientes'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilters ? null : 0,
            child: _showFilters
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameSearchController,
                          decoration: InputDecoration(
                            labelText: 'Pesquisar por nome',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _nameSearchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _nameSearchController.clear();
                                      _mapController.setNameFilter('', _loadData);
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            _mapController.setNameFilter(value, _loadData);
                          },
                        ),
                        const SizedBox(height: 12),
                        AnimatedBuilder(
                          animation: _clientController,
                          builder: (context, _) {
                            return DropdownButtonFormField<String?>(
                              initialValue: _mapController.selectedPlanFilter,
                              decoration: InputDecoration(
                                labelText: 'Filtrar por plano',
                                prefixIcon: const Icon(Icons.wifi),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Todos os planos')),
                                ..._clientController.clients
                                    .map((c) => c.planType)
                                    .toSet()
                                    .map((plan) => DropdownMenuItem(value: plan, child: Text(plan))),
                              ],
                              onChanged: (value) {
                                _mapController.setPlanFilter(value, _loadData);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _mapController,
              builder: (context, _) {
                if (_mapController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_mapController.markers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum cliente encontrado no mapa',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return GoogleMap(
                  initialCameraPosition: _mapController.initialPosition,
                  markers: _mapController.markers,
                  onMapCreated: (controller) {
                    // Controller do Google Maps criado
                    for (var marker in _mapController.markers) {
                      if (marker.onTap != null) {
                        // Markers já tem onTap configurado via infoWindow
                      }
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: (position) {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
