class Event {
  final int id;
  final String? uuid;
  final String name;
  final String slug;
  final String category;
  final String? subCategory;
  final DateTime startDate;
  final DateTime? endDate;
  final String venueName;
  final int cityId;
  final String cityName;
  final String cityCountry;
  final int soldSeats;
  final int availableSeats;
  final double minPrice;
  final double maxPrice;
  final String coverImageUrl;
  final String? status;
  final bool isFeatured;
  final bool isPromoted;
  final int viewCount;
  final double? averageRating;
  final bool isSaleOpen;
  final bool isPastEvent;
  final bool isSoldOut;

  Event({
    required this.id,
    this.uuid,
    required this.name,
    required this.slug,
    required this.category,
    this.subCategory,
    required this.startDate,
    this.endDate,
    required this.venueName,
    required this.cityId,
    required this.cityName,
    required this.cityCountry,
    required this.soldSeats,
    required this.availableSeats,
    required this.minPrice,
    required this.maxPrice,
    required this.coverImageUrl,
    this.status,
    required this.isFeatured,
    required this.isPromoted,
    required this.viewCount,
    this.averageRating,
    required this.isSaleOpen,
    required this.isPastEvent,
    required this.isSoldOut,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
      slug: json['slug'],
      category: json['category'],
      subCategory: json['subCategory'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      venueName: json['venueName'],
      cityId: json['cityId'],
      cityName: json['cityName'],
      cityCountry: json['cityCountry'],
      soldSeats: json['soldSeats'],
      availableSeats: json['availableSeats'],
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      coverImageUrl: json['coverImageUrl'],
      status: json['status'],
      isFeatured: json['isFeatured'],
      isPromoted: json['isPromoted'],
      viewCount: json['viewCount'],
      averageRating: json['averageRating'] != null ? (json['averageRating'] as num).toDouble() : null,
      isSaleOpen: json['isSaleOpen'],
      isPastEvent: json['isPastEvent'],
      isSoldOut: json['isSoldOut'],
    );
  }

  // Helper getters to keep compatibility with existing UI if needed
  String get imagePath => coverImageUrl;
  String get location => "$venueName, $cityName";
  String get date => startDate.toString(); // You might want to format this later
  double get price => minPrice;
}