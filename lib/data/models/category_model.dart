import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconUrl;
  final int displayOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.displayOrder,
    required this.isActive,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final json = doc.data() ?? {};
    return CategoryModel(
      id: doc.id,
      name: json['name'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
      displayOrder: json['displayOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
      displayOrder: json['displayOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconUrl': iconUrl,
      'displayOrder': displayOrder,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toJson() => {'id': id, ...toFirestore()};

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      iconUrl: iconUrl,
      displayOrder: displayOrder,
      isActive: isActive,
    );
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      iconUrl: entity.iconUrl,
      displayOrder: entity.displayOrder,
      isActive: entity.isActive,
    );
  }
}
