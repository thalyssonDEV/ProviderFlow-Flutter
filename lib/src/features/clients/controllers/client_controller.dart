import 'package:flutter/material.dart';
import '../../../shared/database/database_helper.dart';
import '../models/client_model.dart';

class ClientController extends ChangeNotifier {
  List<ClientModel> clients = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadClients(int providerId) async {
    isLoading = true;
    notifyListeners();
    try {
      final list = await DatabaseHelper.instance.getClientsByProvider(providerId);
      clients = list.map((m) => ClientModel.fromMap(m)).toList();
    } catch (e) {
      errorMessage = 'Erro ao carregar: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addClient(ClientModel client) async {
    try {
      await DatabaseHelper.instance.createClient(
        providerId: client.providerId,
        name: client.name,
        cpf: client.cpf,
        phone: client.phone,
        planType: client.planType,
        latitude: client.latitude,
        longitude: client.longitude,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateClient(ClientModel client) async {
    try {
      await DatabaseHelper.instance.updateClient(
        id: client.id!,
        name: client.name,
        cpf: client.cpf,
        phone: client.phone,
        planType: client.planType,
        latitude: client.latitude,
        longitude: client.longitude,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteClient(int id, int providerId) async {
    await DatabaseHelper.instance.deleteClient(id);
    await loadClients(providerId);
  }

  Future<List<String>> getPlans() async {
    return await DatabaseHelper.instance.getPlans();
  }
}
