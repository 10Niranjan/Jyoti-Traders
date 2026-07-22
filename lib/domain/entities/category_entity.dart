import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconUrl;
  final int displayOrder;
  final bool isActive;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.displayOrder,
    required this.isActive,
  });

  CategoryEntity copyWith({String? iconUrl, int? displayOrder}) {
    return CategoryEntity(
      id: id,
      name: name,
      iconUrl: iconUrl ?? this.iconUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, iconUrl, displayOrder, isActive];
}
