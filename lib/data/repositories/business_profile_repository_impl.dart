import '../../domain/entities/business_profile_entity.dart';
import '../../domain/repositories/business_profile_repository.dart';
import '../datasources/remote/business_profile_remote_datasource.dart';

class BusinessProfileRepositoryImpl implements BusinessProfileRepository {
  final BusinessProfileRemoteDatasource _remote;

  BusinessProfileRepositoryImpl(this._remote);

  @override
  Stream<BusinessProfileEntity> watchProfile() => _remote.watchProfile();

  @override
  Future<void> saveProfile(BusinessProfileEntity profile) =>
      _remote.saveProfile(profile);
}
