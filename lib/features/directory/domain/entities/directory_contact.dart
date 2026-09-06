class DirectoryContact {
  final String id;
  final String name;
  final String phone;
  final String category;
  final String? email;
  final String? region;
  final String? website;
  final String source;
  final bool isEmergency;

  DirectoryContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.category,
    this.email,
    this.region,
    this.website,
    required this.source,
    this.isEmergency = false,
  });
}
