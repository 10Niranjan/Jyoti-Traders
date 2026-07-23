import 'package:equatable/equatable.dart';

/// Admin-configured delivery pricing: the warehouse's coordinates (the
/// origin every delivery distance is measured from) and a flat per-km rate.
class DeliveryConfigEntity extends Equatable {
  final double warehouseLat;
  final double warehouseLng;
  final double perKmRate;

  const DeliveryConfigEntity({
    required this.warehouseLat,
    required this.warehouseLng,
    required this.perKmRate,
  });

  @override
  List<Object?> get props => [warehouseLat, warehouseLng, perKmRate];
}
