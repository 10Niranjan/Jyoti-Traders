import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/bank_details_entity.dart';
import 'package:traders_retailer/features/profile/utils/profile_completeness.dart';

UserModel _user({
  String? photoUrl,
  AddressEntity? address,
  String? gst,
  BankDetailsEntity? bank,
}) => UserModel(
  uid: 'u1',
  name: 'Ramesh',
  email: 'r@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.approved,
  businessName: 'Ramesh Store',
  createdAt: DateTime(2026, 1, 1),
  photoUrl: photoUrl,
  address: address,
  gstNumber: gst,
  bankDetails: bank,
);

const _located = AddressEntity(
  street: 'St',
  city: 'City',
  pincode: '123456',
  latitude: 19.0,
  longitude: 72.8,
);

void main() {
  test('a brand-new profile is missing everything', () {
    final c = computeProfileCompleteness(_user());
    expect(c.missing, ProfileTask.values);
    expect(c.percent, 0);
    expect(c.isComplete, isFalse);
  });

  test('a typed address without coordinates does not count as location', () {
    final c = computeProfileCompleteness(
      _user(
        address: const AddressEntity(
          street: 'St',
          city: 'C',
          pincode: '123456',
        ),
      ),
    );
    expect(c.missing, contains(ProfileTask.location));
  });

  test('each filled item drops out of the missing list', () {
    final c = computeProfileCompleteness(
      _user(
        photoUrl: 'https://x/y.png',
        address: _located,
        gst: '22AAAAA0000A1Z5',
      ),
    );
    expect(c.missing, [ProfileTask.payout]);
    expect(c.percent, 75);
  });

  test('UPI alone counts as payout details', () {
    final c = computeProfileCompleteness(
      _user(
        bank: const BankDetailsEntity(
          accountHolderName: '',
          accountNumber: '',
          ifscCode: '',
          bankName: '',
          upiId: 'shop@upi',
        ),
      ),
    );
    expect(c.missing, isNot(contains(ProfileTask.payout)));
  });

  test('whitespace-only GST is not filled in', () {
    expect(
      computeProfileCompleteness(_user(gst: '   ')).missing,
      contains(ProfileTask.gst),
    );
  });

  test('everything filled is complete at 100%', () {
    final c = computeProfileCompleteness(
      _user(
        photoUrl: '/local/photo.jpg',
        address: _located,
        gst: '22AAAAA0000A1Z5',
        bank: const BankDetailsEntity(
          accountHolderName: 'R',
          accountNumber: '123456789',
          ifscCode: 'SBIN0000001',
          bankName: 'SBI',
        ),
      ),
    );
    expect(c.isComplete, isTrue);
    expect(c.percent, 100);
  });
}
