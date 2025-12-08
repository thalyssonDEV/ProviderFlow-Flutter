import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? addressPreview;

  const LocationPickerScreen({
    super.key,
    this.initialLocation,
    this.addressPreview,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _pickedLocation = widget.initialLocation;
      _isLoading = false;
      // Move camera para a localização inicial após o mapa ser criado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(widget.initialLocation!, 16),
        );
      });
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Por favor, ative o GPS do dispositivo.');
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Permissão de localização negada.');
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError('Permissões de localização permanentemente negadas.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );
      final currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _pickedLocation = currentLatLng;
        _isLoading = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng, 15),
      );
    } catch (e) {
      _showError('Erro ao obter localização: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Localização'),
        actions: [
          if (_pickedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.initialLocation ?? const LatLng(-5.092, -42.8038),
                    zoom: widget.initialLocation != null ? 16 : 13,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (widget.initialLocation != null) {
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(widget.initialLocation!, 16),
                      );
                    }
                  },
                  onTap: _selectLocation,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _pickedLocation == null
                      ? {}
                      : {
                          Marker(
                            markerId: const MarkerId('selected'),
                            position: _pickedLocation!,
                            infoWindow: InfoWindow(
                              title: 'Local Selecionado',
                              snippet: widget.addressPreview ?? 'Toque para confirmar',
                            ),
                          ),
                        },
                ),
          if (widget.addressPreview != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Endereço:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.addressPreview!,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toque no mapa para ajustar a marcação',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
