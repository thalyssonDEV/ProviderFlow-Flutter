import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../shared/database/database_helper.dart';
import '../../shared/utils/session_manager.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientMarkers();
  }

  Future<void> _loadClientMarkers() async {
    final providerId = SessionManager().loggedProviderId;
    if (providerId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final clients = await DatabaseHelper.instance.getClientsByProvider(providerId);
    final Set<Marker> newMarkers = {};

    for (var client in clients) {
      final double? lat = (client['latitude'] as num?)?.toDouble();
      final double? lng = (client['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      newMarkers.add(
        Marker(
          markerId: MarkerId(client['id'].toString()),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: client['name']?.toString() ?? 'Cliente',
            snippet: '${client['plan_type']} • ${client['phone']}',
          ),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Geral'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-5.092, -42.8038),
                zoom: 12,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
