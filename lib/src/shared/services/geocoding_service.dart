import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressResult {
  final String street;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final LatLng? location;

  AddressResult({
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.location,
  });
}

class GeocodingService {
  static Future<AddressResult?> searchByCep(String cep) async {
    try {
      final cleanCep = cep.replaceAll(RegExp(r'\D'), '');
      if (cleanCep.length != 8) return null;

      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cleanCep/json/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['erro'] == true) return null;

        // Busca coordenadas do endereço
        final fullAddress = '${data['logradouro']}, ${data['bairro']}, ${data['localidade']}, ${data['uf']}';
        final location = await _getCoordinates(fullAddress);

        return AddressResult(
          street: data['logradouro'] ?? '',
          neighborhood: data['bairro'] ?? '',
          city: data['localidade'] ?? '',
          state: data['uf'] ?? '',
          zipCode: cep,
          location: location,
        );
      }
    } catch (e) {
      // Erro ao buscar CEP
    }
    return null;
  }

  static Future<AddressResult?> searchByAddress(String address) async {
    try {
      final location = await _getCoordinates(address);
      if (location == null) return null;

      // Tenta extrair partes do endereço
      final parts = address.split(',');
      
      return AddressResult(
        street: parts.isNotEmpty ? parts[0].trim() : '',
        neighborhood: parts.length > 1 ? parts[1].trim() : '',
        city: parts.length > 2 ? parts[2].trim() : '',
        state: parts.length > 3 ? parts[3].trim() : '',
        zipCode: '',
        location: location,
      );
    } catch (e) {
      // Erro ao buscar endereço
    }
    return null;
  }

  static Future<LatLng?> _getCoordinates(String address) async {
    try {
      // Usando Nominatim (OpenStreetMap) - gratuito
      final encodedAddress = Uri.encodeComponent(address);
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1'),
        headers: {'User-Agent': 'ProviderFlow-Flutter'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      // Erro ao obter coordenadas
    }
    return null;
  }
}
