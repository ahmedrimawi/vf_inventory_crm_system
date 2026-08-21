class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final bool isActive;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.isActive,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      isActive: json['is_active'] ?? true,
    );
  }
}
