
class Category {
  final int id;
  final String uuid;
  final String name;
  final String displayName;
  final String? iconUrl;

  Category({
    required this.id,
    required this.uuid,
    required this.name,
    required this.displayName,
    this.iconUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
      displayName: json['displayName'],
      iconUrl: json['iconUrl'],
    );
  }
}
