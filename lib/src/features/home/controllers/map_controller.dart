import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shared/database/database_helper.dart';

class MapController extends ChangeNotifier {
  Set<Marker> markers = {};
  bool isLoading = true;

  Future<void> loadMarkers(int providerId, Function(Map<String, dynamic>) onMarkerTap) async {
    isLoading = true;
    notifyListeners();

    final clients = await DatabaseHelper.instance.getClientsByProvider(providerId);
    final Set<Marker> newMarkers = {};

    for (var c in clients) {
      final double? lat = c['latitude'];
      final double? lng = c['longitude'];
      if (lat == null || lng == null) continue;

      newMarkers.add(
        Marker(
          markerId: MarkerId(c['id'].toString()),
          position: LatLng(lat, lng),
          onTap: () => onMarkerTap(c),
        ),
      );
    }

    markers = newMarkers;
    isLoading = false;
    notifyListeners();
  }
}
