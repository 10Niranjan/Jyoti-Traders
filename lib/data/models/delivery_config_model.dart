import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/delivery_config_entity.dart';

class DeliveryConfigModel {
  final double warehouseLat;
  final double warehouseLng;
  final double perKmRate;

  DeliveryConfigModel({
    required this.warehouseLat,
    required this.warehouseLng,
    required this.perKmRate,
  });

  factory DeliveryConfigModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return DeliveryConfigModel.fromJson(doc.data() ?? {});
  }

  factory DeliveryConfigModel.fromJson(Map<String, dynamic> json) {
    return DeliveryConfigModel(
      warehouseLat: (json['warehouseLat'] as num?)?.toDouble() ?? DeliveryConfigModel.defaultConfig.warehouseLat,
      warehouseLng: (json['warehouseLng'] as num?)?.toDouble() ?? DeliveryConfigModel.defaultConfig.warehouseLng,
      perKmRate: (json['perKmRate'] as num?)?.toDouble() ?? DeliveryConfigModel.defaultConfig.perKmRate,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'warehouseLat': warehouseLat,
        'warehouseLng': warehouseLng,
        'perKmRate': perKmRate,
      };

  Map<String, dynamic> toJson() => toFirestore();

  DeliveryConfigEntity toEntity() {
    return DeliveryConfigEntity(warehouseLat: warehouseLat, warehouseLng: warehouseLng, perKmRate: perKmRate);
  }

  factory DeliveryConfigModel.fromEntity(DeliveryConfigEntity entity) {
    return DeliveryConfigModel(
      warehouseLat: entity.warehouseLat,
      warehouseLng: entity.warehouseLng,
      perKmRate: entity.perKmRate,
    );
  }

  /// Bootstrapping default until the admin sets the real warehouse location
  /// via the Delivery Settings screen — a placeholder in the same spirit as
  /// `AppConstants.kStubDeliveryCharge` was before this feature existed.
  /// Coordinates are central India (Nagpur); rate matches PRD §4.4's example.
  static final defaultConfig = DeliveryConfigModel(warehouseLat: 21.1458, warehouseLng: 79.0882, perKmRate: 10.0);
}
