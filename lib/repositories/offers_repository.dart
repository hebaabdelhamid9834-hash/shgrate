import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/offer_short.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';

class OffersRepository {
  Future<List<OfferShort>> getShorts({int page = 1}) async {
    final response = await ApiRequest.get(
      url: '${AppConfig.BASE_URL}/offers/shorts?page=$page',
      headers: {'App-Language': app_language.$!},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load offer shorts');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return const [];

    final data = decoded['data'];
    final items = data is List
        ? data
        : data is Map<String, dynamic>
            ? (data['data'] ?? data['items'] ?? const [])
            : const [];

    if (items is! List) return const [];

    return items.whereType<Map>().map((item) => OfferShort.fromJson(Map<String, dynamic>.from(item))).toList(growable: false);
  }
}
