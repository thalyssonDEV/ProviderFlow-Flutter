import 'package:flutter/material.dart';
import '../../../shared/database/database_helper.dart';

class ReportsController extends ChangeNotifier {
  Map<String, dynamic>? stats;
  bool isLoading = true;

  Future<void> loadStats(int providerId) async {
    isLoading = true;
    notifyListeners();
    stats = await DatabaseHelper.instance.getProviderStats(providerId);
    isLoading = false;
    notifyListeners();
  }
}
