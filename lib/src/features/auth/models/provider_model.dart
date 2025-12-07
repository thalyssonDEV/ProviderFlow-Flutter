class ProviderModel {
  final int id;
  final String username;

  ProviderModel({required this.id, required this.username});

  factory ProviderModel.fromMap(Map<String, dynamic> map) {
    return ProviderModel(
      id: map['id'],
      username: map['username'],
    );
  }
}
