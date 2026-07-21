import 'package:equatable/equatable.dart';

/// A retailer's registered delivery address.
class AddressEntity extends Equatable {
  final String street;
  final String city;
  final String pincode;

  const AddressEntity({
    required this.street,
    required this.city,
    required this.pincode,
  });

  @override
  List<Object?> get props => [street, city, pincode];
}
