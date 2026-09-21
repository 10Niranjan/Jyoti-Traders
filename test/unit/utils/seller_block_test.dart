import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/constants/app_constants.dart';
import 'package:traders_retailer/core/utils/invoice_pdf.dart';
import 'package:traders_retailer/domain/entities/business_profile_entity.dart';

void main() {
  test('with no profile it falls back to the built-in defaults', () {
    final s = resolveSellerBlock(null);
    expect(s.name, AppConstants.kAppName);
    expect(s.address, AppConstants.kInvoiceSellerAddress);
    expect(s.gstin, AppConstants.kInvoiceSellerGstin);
  });

  test('an empty profile behaves the same as none', () {
    expect(
      resolveSellerBlock(BusinessProfileEntity.empty),
      resolveSellerBlock(null),
    );
  });

  test('what the owner entered wins', () {
    final s = resolveSellerBlock(
      const BusinessProfileEntity(
        legalName: 'Jyoti Traders Pvt Ltd',
        address: '12 Market Yard, Pune',
        gstin: '27ABCDE1234F1Z5',
      ),
    );
    expect(s.name, 'Jyoti Traders Pvt Ltd');
    expect(s.address, '12 Market Yard, Pune');
    expect(s.gstin, '27ABCDE1234F1Z5');
  });

  test('each field falls back independently', () {
    final s = resolveSellerBlock(
      const BusinessProfileEntity(gstin: '27ABCDE1234F1Z5'),
    );
    expect(s.name, AppConstants.kAppName);
    expect(s.gstin, '27ABCDE1234F1Z5');
  });
}
