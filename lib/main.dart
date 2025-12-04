import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // [cite: 164]

void main() => runApp(const MyApp()); // [cite: 165]

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState(); // [cite: 168]
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController; // [cite: 169]

  // Coordenadas iniciais (exemplo do slide: Portland)
  final LatLng _center = const LatLng(45.521563, -122.677433); // [cite: 170]

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller; // [cite: 171, 173]
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // [cite: 176]
      home: Scaffold( // [cite: 177]
        appBar: AppBar( // [cite: 178]
          title: const Text('Maps Sample App'), // [cite: 180]
          backgroundColor: Colors.green[700], // [cite: 181]
        ),
        body: GoogleMap( // [cite: 182]
          onMapCreated: _onMapCreated, // [cite: 183]
          initialCameraPosition: CameraPosition( // [cite: 184]
            target: _center, // [cite: 185]
            zoom: 11.0, // [cite: 186]
          ),
        ),
      ),
    );
  }
}