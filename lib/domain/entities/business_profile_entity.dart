import 'package:equatable/equatable.dart';

/// The shop owner's legal identity, printed as the seller block on invoices:
/// name, registered address and GSTIN. Edited by the admin; every field is
/// optional because the client hasn't supplied them all yet — an invoice must
/// never carry an invented GSTIN, so blank means "leave that line out".
class BusinessProfileEntity extends Equatable {
  final String legalName;
  final String address;
  final String gstin;

  const BusinessProfileEntity({
    this.legalName = '',
    this.address = '',
    this.gstin = '',
  });

  static const BusinessProfileEntity empty = BusinessProfileEntity();

  bool get isEmpty => legalName.isEmpty && address.isEmpty && gstin.isEmpty;

  @override
  List<Object?> get props => [legalName, address, gstin];
}
