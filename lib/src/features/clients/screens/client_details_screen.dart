import 'package:flutter/material.dart';
import '../models/client_model.dart';

class ClientDetailsScreen extends StatelessWidget {
  final ClientModel client;

  const ClientDetailsScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(client.name)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.badge, 'CPF', client.cpf),
            _buildDetailRow(Icons.wifi, 'Plano', client.planType),
            _buildDetailRow(Icons.phone, 'Telefone', client.phone),
            const Divider(height: 30),
            const Text(
              "Localização",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.location_on, 'Latitude', client.latitude?.toString() ?? 'N/A'),
            _buildDetailRow(Icons.location_on, 'Longitude', client.longitude?.toString() ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
