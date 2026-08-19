import 'dart:convert';

class Event {
  final int id;
  final String? uuid;
  final String name;
  final String slug;
  final String? fullDescription;
  final int categoryId;
  final String category;
  final String categoryDisplayName;
  final String? subCategory;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? doorsOpenTime;
  final DateTime? saleStartDate;
  final DateTime? saleEndDate;
  final String venueName;
  final String venueAddress;
  final int cityId;
  final String cityName;
  final String cityCountry;
  final String? venueAccessInfo;
  final int totalSeats;
  final int availableSeats;
  final int reservedSeats;
  final int soldSeats;
  final double minPrice;
  final double maxPrice;
  final dynamic structureId;
  final dynamic structureName;
  final String? organizerName;
  final String? organizerPhone;
  final String coverImageUrl;
  final String eventStatus;
  final bool isFeatured;
  final bool isPromoted;
  final bool isOnline;
  final String? onlineMeetingUrl;
  final bool isPublic;
  final bool isActive;
  final int minAge;
  final String? termsAndConditions;
  final String? cancellationPolicy;
  final bool allowRefund;
  final int refundDeadlineDays;
  final int maxTicketsPerUser;
  final int viewCount;
  final int favoriteCount;
  final int shareCount;
  final double? averageRating;
  final int reviewCount;
  final String validationMode;
  final String? createdBy;
  final String? updatedBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime? publishedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCancelled;
  final List<dynamic> ticketCategories;
  final bool isSaleOpen;
  final bool isPastEvent;
  final bool isSoldOut;

  Event({
    required this.id,
    this.uuid,
    required this.name,
    required this.slug,
    this.fullDescription,
    required this.categoryId,
    required this.category,
    required this.categoryDisplayName,
    this.subCategory,
    required this.startDate,
    this.endDate,
    this.doorsOpenTime,
    this.saleStartDate,
    this.saleEndDate,
    required this.venueName,
    required this.venueAddress,
    required this.cityId,
    required this.cityName,
    required this.cityCountry,
    this.venueAccessInfo,
    required this.totalSeats,
    required this.availableSeats,
    required this.reservedSeats,
    required this.soldSeats,
    required this.minPrice,
    required this.maxPrice,
    this.structureId,
    this.structureName,
    this.organizerName,
    this.organizerPhone,
    required this.coverImageUrl,
    required this.eventStatus,
    required this.isFeatured,
    required this.isPromoted,
    required this.isOnline,
    this.onlineMeetingUrl,
    required this.isPublic,
    required this.isActive,
    required this.minAge,
    this.termsAndConditions,
    this.cancellationPolicy,
    required this.allowRefund,
    required this.refundDeadlineDays,
    required this.maxTicketsPerUser,
    required this.viewCount,
    required this.favoriteCount,
    required this.shareCount,
    this.averageRating,
    required this.reviewCount,
    required this.validationMode,
    this.createdBy,
    this.updatedBy,
    this.approvedBy,
    this.approvedAt,
    this.publishedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    required this.isCancelled,
    required this.ticketCategories,
    required this.isSaleOpen,
    required this.isPastEvent,
    required this.isSoldOut,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse dates
    DateTime? safeParseDate(String? dateString) {
      if (dateString == null) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }
    
    // Helper function to safely parse numbers to double
    double safeParseDouble(dynamic value) {
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
    }

    // Helper function to safely parse numbers to int
    int safeParseInt(dynamic value) {
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
    }


    return Event(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
      slug: json['slug'] ?? '',
      fullDescription: json['fullDescription'],
      categoryId: json['categoryId'],
      category: json['category'],
      categoryDisplayName: json['categoryDisplayName'],
      subCategory: json['subCategory'],
      startDate: safeParseDate(json['startDate'])!,
      endDate: safeParseDate(json['endDate']),
      doorsOpenTime: safeParseDate(json['doorsOpenTime']),
      saleStartDate: safeParseDate(json['saleStartDate']),
      saleEndDate: safeParseDate(json['saleEndDate']),
      venueName: json['venueName'],
      venueAddress: json['venueAddress'],
      cityId: json['cityId'],
      cityName: json['cityName'],
      cityCountry: json['cityCountry'],
      venueAccessInfo: json['venueAccessInfo'],
      totalSeats: json['totalSeats'],
      availableSeats: json['availableSeats'],
      reservedSeats: json['reservedSeats'],
      soldSeats: json['soldSeats'],
      minPrice: safeParseDouble(json['minPrice']),
      maxPrice: safeParseDouble(json['maxPrice']),
      structureId: json['structureId'],
      structureName: json['structureName'],
      organizerName: json['organizerName'],
      organizerPhone: json['organizerPhone'],
      coverImageUrl: json['coverImageUrl'],
      eventStatus: json['eventStatus'],
      isFeatured: json['isFeatured'] ?? false,
      isPromoted: json['isPromoted'] ?? false,
      isOnline: json['isOnline'] ?? false,
      onlineMeetingUrl: json['onlineMeetingUrl'],
      isPublic: json['isPublic'] ?? true,
      isActive: json['isActive'] ?? true,
      minAge: safeParseInt(json['minAge']),
      termsAndConditions: json['termsAndConditions'],
      cancellationPolicy: json['cancellationPolicy'],
      allowRefund: json['allowRefund'] ?? false,
      refundDeadlineDays: safeParseInt(json['refundDeadlineDays']),
      maxTicketsPerUser: safeParseInt(json['maxTicketsPerUser']),
      viewCount: json['viewCount'],
      favoriteCount: json['favoriteCount'],
      shareCount: json['shareCount'],
      averageRating: safeParseDouble(json['averageRating']),
      reviewCount: json['reviewCount'],
      validationMode: json['validationMode'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      approvedBy: json['approvedBy'],
      approvedAt: safeParseDate(json['approvedAt']),
      publishedAt: safeParseDate(json['publishedAt']),
      cancelledAt: safeParseDate(json['cancelledAt']),
      cancellationReason: json['cancellationReason'],
      createdAt: safeParseDate(json['createdAt'])!,
      updatedAt: safeParseDate(json['updatedAt'])!,
      isCancelled: json['isCancelled'] ?? false,
      ticketCategories: json['ticketCategories'] ?? [],
      isSaleOpen: json['isSaleOpen'] ?? false,
      isPastEvent: json['isPastEvent'] ?? false,
      isSoldOut: json['isSoldOut'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'slug': slug,
      'fullDescription': fullDescription,
      'categoryId': categoryId,
      'category': category,
      'categoryDisplayName': categoryDisplayName,
      'subCategory': subCategory,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'doorsOpenTime': doorsOpenTime?.toIso8601String(),
      'saleStartDate': saleStartDate?.toIso8601String(),
      'saleEndDate': saleEndDate?.toIso8601String(),
      'venueName': venueName,
      'venueAddress': venueAddress,
      'cityId': cityId,
      'cityName': cityName,
      'cityCountry': cityCountry,
      'venueAccessInfo': venueAccessInfo,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'reservedSeats': reservedSeats,
      'soldSeats': soldSeats,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'structureId': structureId,
      'structureName': structureName,
      'organizerName': organizerName,
      'organizerPhone': organizerPhone,
      'coverImageUrl': coverImageUrl,
      'eventStatus': eventStatus,
      'isFeatured': isFeatured,
      'isPromoted': isPromoted,
      'isOnline': isOnline,
      'onlineMeetingUrl': onlineMeetingUrl,
      'isPublic': isPublic,
      'isActive': isActive,
      'minAge': minAge,
      'termsAndConditions': termsAndConditions,
      'cancellationPolicy': cancellationPolicy,
      'allowRefund': allowRefund,
      'refundDeadlineDays': refundDeadlineDays,
      'maxTicketsPerUser': maxTicketsPerUser,
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'shareCount': shareCount,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'validationMode': validationMode,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCancelled': isCancelled,
      'ticketCategories': ticketCategories,
      'isSaleOpen': isSaleOpen,
      'isPastEvent': isPastEvent,
      'isSoldOut': isSoldOut,
    };
  }

}
