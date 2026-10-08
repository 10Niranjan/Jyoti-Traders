import 'package:equatable/equatable.dart';

/// An admin-authored offer or announcement shown at the top of Home — e.g.
/// "Diwali kit" or "Rice ₹2/kg off this week".
class PromoBannerEntity extends Equatable {
  final String id;
  final String title;

  /// Optional supporting line under the title.
  final String body;
  final bool isActive;

  /// Last moment the banner is shown; null means it runs until switched off.
  final DateTime? endsAt;

  const PromoBannerEntity({
    required this.id,
    required this.title,
    this.body = '',
    this.isActive = true,
    this.endsAt,
  });

  bool isExpiredAt(DateTime now) => endsAt != null && !endsAt!.isAfter(now);

  /// What a retailer actually sees: switched on and not past its end date.
  bool isLiveAt(DateTime now) => isActive && !isExpiredAt(now);

  PromoBannerEntity copyWith({
    String? title,
    String? body,
    bool? isActive,
    DateTime? endsAt,
    bool clearEndsAt = false,
  }) => PromoBannerEntity(
    id: id,
    title: title ?? this.title,
    body: body ?? this.body,
    isActive: isActive ?? this.isActive,
    endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
  );

  @override
  List<Object?> get props => [id, title, body, isActive, endsAt];
}
