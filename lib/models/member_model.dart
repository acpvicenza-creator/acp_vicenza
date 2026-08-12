class MemberModel {
  final String id;
  final String fullName;
  final String fiscalCode;
  final String phone;
  final String address;
  final String city;
  final DateTime registrationDate;
  final String? signatureUrl;

  MemberModel({
    required this.id,
    required this.fullName,
    required this.fiscalCode,
    required this.phone,
    required this.address,
    this.city = 'Vicenza',
    required this.registrationDate,
    this.signatureUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'fiscalCode': fiscalCode,
      'phone': phone,
      'address': address,
      'city': city,
      'registrationDate': registrationDate.toIso8601String(),
      'signatureUrl': signatureUrl,
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      fiscalCode: map['fiscalCode'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? 'Vicenza',
      registrationDate: map['registrationDate'] != null
          ? DateTime.parse(map['registrationDate'])
          : DateTime.now(),
      signatureUrl: map['signatureUrl'],
    );
  }
}