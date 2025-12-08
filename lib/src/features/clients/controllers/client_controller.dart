import 'package:flutter/material.dart';
import '../../../shared/database/database_helper.dart';
import '../models/client_model.dart';

class ClientController extends ChangeNotifier {
  List<ClientModel> clients = [];
  List<ClientModel> filteredClients = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  String? selectedPlanFilter;

  Future<void> loadClients(int providerId) async {
    isLoading = true;
    notifyListeners();
    try {
      final list = await DatabaseHelper.instance.getClientsByProvider(providerId);
      clients = list.map((m) => ClientModel.fromMap(m)).toList();
      _applyFilters();
    } catch (e) {
      errorMessage = 'Erro ao carregar: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void setPlanFilter(String? plan) {
    selectedPlanFilter = plan;
    _applyFilters();
  }

  void clearFilters() {
    searchQuery = '';
    selectedPlanFilter = null;
    _applyFilters();
  }

  void _applyFilters() {
    filteredClients = clients.where((client) {
      final matchesSearch = searchQuery.isEmpty ||
          client.name.toLowerCase().contains(searchQuery) ||
          client.cpf.contains(searchQuery);
      
      final matchesPlan = selectedPlanFilter == null ||
          client.planType == selectedPlanFilter;

      return matchesSearch && matchesPlan;
    }).toList();
    notifyListeners();
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
        street: client.street,
        number: client.number,
        neighborhood: client.neighborhood,
        city: client.city,
        state: client.state,
        zipCode: client.zipCode,
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
        street: client.street,
        number: client.number,
        neighborhood: client.neighborhood,
        city: client.city,
        state: client.state,
        zipCode: client.zipCode,
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
