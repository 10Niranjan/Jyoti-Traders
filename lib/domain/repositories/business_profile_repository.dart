import '../entities/business_profile_entity.dart';

/// A single config document (`config/business`), like
/// `DeliveryConfigRepository`. Everyone signed in can read it (invoices are
/// built on the retailer's phone too); only the admin writes it.
abstract class BusinessProfileRepository {
  Stream<BusinessProfileEntity> watchProfile();

  Future<void> saveProfile(BusinessProfileEntity profile);
}
