import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;

  static const LatLng _initialPosition = LatLng(-5.092, -42.8038);

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toque para selecionar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_pickedLocation != null)
            IconButton(
              icon: const Icon(Icons.check, color: Color(0xFF4E9F3D)),
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
              },
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _initialPosition,
          zoom: 13,
        ),
        onTap: _selectLocation,
        markers: _pickedLocation == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _pickedLocation!,
                ),
              },
      ),
    );
  }
}
