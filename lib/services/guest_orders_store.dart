import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myapp/models/order_model.dart';

/// Commande passée sans compte sur ce téléphone.
class GuestOrder {
  final String orderId;
  final String token;
  final String eventName;
  final DateTime createdAt;

  GuestOrder({required this.orderId, required this.token, required this.eventName, required this.createdAt});

  OrderAccess get access => OrderAccess(orderId, guestToken: token);

  Map<String, dynamic> toJson() =>
      {'orderId': orderId, 'token': token, 'eventName': eventName, 'createdAt': createdAt.toIso8601String()};

  factory GuestOrder.fromJson(Map<String, dynamic> json) => GuestOrder(
        orderId: json['orderId'] as String,
        token: json['token'] as String,
        eventName: json['eventName'] as String? ?? 'Commande',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Commandes sans compte : leur jeton est la seule clé d'accès aux billets (le serveur n'en garde
/// que le hash), il est donc stocké chiffré, comme la session.
class GuestOrdersStore {
  GuestOrdersStore._();
  static final GuestOrdersStore instance = GuestOrdersStore._();

  static const _key = 'guest_orders';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<GuestOrder>> all() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).whereType<Map<String, dynamic>>().map(GuestOrder.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> add(GuestOrder order) async {
    final orders = (await all()).where((o) => o.orderId != order.orderId).toList();
    orders.insert(0, order);
    await _write(orders.take(50).toList());
  }

  Future<void> remove(String orderId) async {
    await _write((await all()).where((o) => o.orderId != orderId).toList());
  }

  Future<void> _write(List<GuestOrder> orders) =>
      _storage.write(key: _key, value: jsonEncode(orders.map((o) => o.toJson()).toList()));
}
