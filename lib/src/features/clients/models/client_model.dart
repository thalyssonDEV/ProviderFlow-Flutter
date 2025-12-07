class ClientModel {
  final int? id;
  final int providerId;
  final String name;
  final String cpf;
  final String phone;
  final String planType;
  final double? latitude;
  final double? longitude;

  ClientModel({
    this.id,
    required this.providerId,
    required this.name,
    required this.cpf,
    required this.phone,
    required this.planType,
    this.latitude,
    this.longitude,
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
    };
  }
}
