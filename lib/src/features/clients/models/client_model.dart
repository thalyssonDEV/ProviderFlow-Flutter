class ClientModel {
  final int? id;
  final int providerId;
  final String name;
  final String cpf;
  final String phone;
  final String planType;
  final double? latitude;
  final double? longitude;
  final String? street;
  final String? number;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? zipCode;

  ClientModel({
    this.id,
    required this.providerId,
    required this.name,
    required this.cpf,
    required this.phone,
    required this.planType,
    this.latitude,
    this.longitude,
    this.street,
    this.number,
    this.neighborhood,
    this.city,
    this.state,
    this.zipCode,
  });

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'],
      providerId: map['provider_id'],
      name: map['name'],
      cpf: map['cpf'],
      phone: map['phone'],
      planType: map['plan_type'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      street: map['street'],
      number: map['number'],
      neighborhood: map['neighborhood'],
      city: map['city'],
      state: map['state'],
      zipCode: map['zip_code'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'provider_id': providerId,
      'name': name,
      'cpf': cpf,
      'phone': phone,
      'plan_type': planType,
      'latitude': latitude,
      'longitude': longitude,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zip_code': zipCode,
    };
  }

  String get fullAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (number != null && number!.isNotEmpty) parts.add(number!);
    if (neighborhood != null && neighborhood!.isNotEmpty) parts.add(neighborhood!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    return parts.join(', ');
  }
}
