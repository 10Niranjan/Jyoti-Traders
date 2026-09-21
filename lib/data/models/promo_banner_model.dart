import '../../core/utils/firestore_date_parser.dart';
import '../../domain/entities/promo_banner_entity.dart';

/// (De)serialises the banner list stored as `items` in `config/banners`.
/// Dates are written as plain [DateTime] — Firestore turns them into a
/// `Timestamp` on write, and Hive (simulation mode) stores them as-is.
class PromoBannerModel {
  PromoBannerModel._();

  static List<PromoBannerEntity> listFromJson(Map<String, dynamic>? json) {
    final raw = json?['items'];
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map) _fromMap(Map<String, dynamic>.from(item)),
    ];
  }

  static Map<String, dynamic> listToJson(List<PromoBannerEntity> banners) => {
    'items': [
      for (final b in banners)
        {
          'id': b.id,
          'title': b.title,
          'body': b.body,
          'isActive': b.isActive,
          'endsAt': b.endsAt,
        },
    ],
  };

  static PromoBannerEntity _fromMap(Map<String, dynamic> m) =>
      PromoBannerEntity(
        id: m['id'] as String? ?? '',
        title: m['title'] as String? ?? '',
        body: m['body'] as String? ?? '',
        isActive: m['isActive'] as bool? ?? true,
        endsAt: m['endsAt'] == null ? null : parseFirestoreDate(m['endsAt']),
      );
}
