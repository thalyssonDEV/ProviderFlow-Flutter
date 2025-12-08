import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shared/database/database_helper.dart';
import '../../../shared/utils/session_manager.dart';
import '../../clients/models/client_model.dart';

class MapController extends ChangeNotifier {
  Set<Marker> markers = {};
  bool isLoading = true;
  String? selectedPlanFilter;
  String nameFilter = '';
  List<ClientModel> allClients = [];
  Function(String)? onMarkerTapCallback;

  final CameraPosition initialPosition = const CameraPosition(
    target: LatLng(-5.0919, -42.8034), // Teresina, PI
    zoom: 13,
  );

  Future<void> loadMarkers({Function(String)? onMarkerTap}) async {
    isLoading = true;
    onMarkerTapCallback = onMarkerTap;
    notifyListeners();

    final providerId = SessionManager().loggedProviderId;
    if (providerId == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    final clientsData = await DatabaseHelper.instance.getClientsByProvider(providerId);
    allClients = clientsData.map((data) => ClientModel.fromMap(data)).toList();
    _applyFilter();

    isLoading = false;
    notifyListeners();
  }

  void setPlanFilter(String? plan, Function callback) {
    selectedPlanFilter = plan;
    _applyFilter();
    callback();
  }

  void setNameFilter(String query, Function callback) {
    nameFilter = query;
    _applyFilter();
    callback();
  }

  void _applyFilter() {
    final Set<Marker> newMarkers = {};

    for (var client in allClients) {
      // Aplica filtro de nome
      if (nameFilter.isNotEmpty && 
          !client.name.toLowerCase().contains(nameFilter.toLowerCase())) {
        continue;
      }

      // Aplica filtro de plano
      if (selectedPlanFilter != null && client.planType != selectedPlanFilter) {
        continue;
      }

      final double? lat = client.latitude;
      final double? lng = client.longitude;
      if (lat == null || lng == null) continue;

      newMarkers.add(
        Marker(
          markerId: MarkerId(client.id.toString()),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: client.name,
            snippet: client.fullAddress.isNotEmpty 
                ? '${client.planType} • ${client.fullAddress}'
                : client.planType,
          ),
          onTap: () {
            if (onMarkerTapCallback != null) {
              onMarkerTapCallback!(client.id.toString());
            }
          },
        ),
      );
    }

    markers = newMarkers;
    notifyListeners();
  }
}
