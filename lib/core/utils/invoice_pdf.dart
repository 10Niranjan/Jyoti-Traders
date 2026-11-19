import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/business_profile_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import 'date_formatter.dart';
import 'extensions.dart';
import 'weight_formatter.dart';

// Derived from the app's brand color so the invoice can never drift from it.
final _brand = PdfColor.fromInt(AppColors.primary.toARGB32());
// Saffron tint from the design spec (#FBEADD) — solid, since PDF fills here don't blend alpha.
const _brandTint = PdfColor.fromInt(0xFFFBEADD);
const _grey = PdfColor.fromInt(0xFF6B7280);
const _line = PdfColor.fromInt(0xFFD1D5DB);

/// Fonts the invoice is drawn with. The PDF standard fonts have neither the
/// ₹ sign nor Devanagari, so Noto Sans is bundled (plus Noto Sans Devanagari
/// as the fallback for Hindi/Marathi shop names and addresses).
class InvoiceFonts {
  final pw.Font regular;
  final pw.Font bold;
  final pw.Font devanagariRegular;
  final pw.Font devanagariBold;

  const InvoiceFonts({
    required this.regular,
    required this.bold,
    required this.devanagariRegular,
    required this.devanagariBold,
  });

  static Future<pw.Font> _font(String file) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/$file'));

  static Future<InvoiceFonts>? _cached;

  /// Read and parsed once per app run — about 1.7 MB of font data that every
  /// later invoice can reuse. A failed load isn't cached, so the next tap
  /// retries instead of failing forever.
  ///
  /// ponytail: the PDF is laid out on the UI isolate. Fine for a one-page
  /// invoice; move the build into `compute()` if it ever janks on a low-end
  /// phone.
  static Future<InvoiceFonts> load() => _cached ??= _load().onError((e, st) {
    _cached = null;
    throw e!;
  });

  static Future<InvoiceFonts> _load() async => InvoiceFonts(
    regular: await _font('NotoSans-Regular.ttf'),
    bold: await _font('NotoSans-Bold.ttf'),
    devanagariRegular: await _font('NotoSansDevanagari-Regular.ttf'),
    devanagariBold: await _font('NotoSansDevanagari-Bold.ttf'),
  );
}

/// Builds a printable invoice for [order]. Deliberately a plain invoice with
/// no tax split: the catalogue carries no per-product GST rate or HSN code,
/// so a CGST/SGST breakdown can't be computed honestly yet.
/// [buyerGstin] is the retailer's GST number when they have one on file.
Future<Uint8List> buildInvoicePdf(
  OrderEntity order, {
  String? buyerGstin,
  BusinessProfileEntity? seller,
  InvoiceFonts? fonts,
}) async {
  final t = _Text(fonts ?? await InvoiceFonts.load());
  final doc = pw.Document(
    title: 'Invoice #${order.id.shortId}',
    author: AppConstants.kAppName,
  );
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (_) => [
        _header(t, order, seller),
        pw.SizedBox(height: 18),
        _billTo(t, order, buyerGstin),
        pw.SizedBox(height: 18),
        _itemsTable(t, order),
        pw.SizedBox(height: 12),
        _totals(t, order),
        pw.SizedBox(height: 28),
        t('Thank you for your business.', bold: true),
        pw.SizedBox(height: 2),
        t('This is a computer-generated invoice.', size: 8, color: _grey),
      ],
    ),
  );
  return doc.save();
}

/// Text with the regular/bold Noto face and the matching Devanagari fallback.
class _Text {
  final InvoiceFonts _f;

  const _Text(this._f);

  pw.Widget call(
    String text, {
    double size = 9.5,
    bool bold = false,
    PdfColor? color,
    pw.TextAlign align = pw.TextAlign.left,
  }) => pw.Text(
    text,
    textAlign: align,
    style: pw.TextStyle(
      font: bold ? _f.bold : _f.regular,
      fontFallback: [bold ? _f.devanagariBold : _f.devanagariRegular],
      fontSize: size,
      color: color,
    ),
  );
}

pw.Widget _header(_Text t, OrderEntity order, BusinessProfileEntity? seller) {
  final (:name, :address, :gstin) = resolveSellerBlock(seller);
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          t(name, size: 20, bold: true, color: _brand),
          if (address.isNotEmpty) t(address, color: _grey),
          t('Phone: ${AppConstants.kSupportPhone}', color: _grey),
          t('Email: ${AppConstants.kSupportEmail}', color: _grey),
          if (gstin.isNotEmpty) t('GSTIN: $gstin', bold: true),
        ],
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          t('INVOICE', size: 22, bold: true, color: _brand),
          t('Order #${order.id.shortId}', bold: true),
          t(formatOrderDateTime(order.createdAt), color: _grey),
        ],
      ),
    ],
  );
}

String _addressLine(OrderEntity order) {
  final a = order.deliveryAddress;
  if (a.street.isNotEmpty) return '${a.street}, ${a.city} - ${a.pincode}';
  return a.formattedAddress ?? '${a.city} - ${a.pincode}';
}

pw.Widget _billTo(_Text t, OrderEntity order, String? buyerGstin) {
  final paymentLabel = order.paymentMethod == PaymentMethod.cod
      ? 'Cash on Delivery'
      : 'UPI';
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: _brandTint,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              t('BILL TO', size: 8, bold: true, color: _grey),
              pw.SizedBox(height: 3),
              t(order.shopName, size: 11, bold: true),
              t(_addressLine(order)),
              if (buyerGstin != null && buyerGstin.isNotEmpty)
                t('GSTIN: $buyerGstin', bold: true),
            ],
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            t('PAYMENT', size: 8, bold: true, color: _grey),
            pw.SizedBox(height: 3),
            t(paymentLabel, bold: true),
            t(order.paymentStatus.label),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _cell(
  _Text t,
  String text, {
  bool bold = false,
  bool right = false,
  PdfColor? color,
}) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
  child: t(
    text,
    bold: bold,
    color: color,
    align: right ? pw.TextAlign.right : pw.TextAlign.left,
  ),
);

pw.Widget _itemsTable(_Text t, OrderEntity order) {
  return pw.Table(
    columnWidths: {
      0: const pw.FixedColumnWidth(26),
      1: const pw.FlexColumnWidth(),
      2: const pw.FixedColumnWidth(64),
      3: const pw.FixedColumnWidth(70),
      4: const pw.FixedColumnWidth(78),
    },
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: _line, width: 0.5),
      bottom: pw.BorderSide(color: _line, width: 0.5),
    ),
    children: [
      pw.TableRow(
        repeat: true,
        decoration: pw.BoxDecoration(color: _brand),
        children: [
          _cell(t, '#', bold: true, color: PdfColors.white),
          _cell(t, 'Item', bold: true, color: PdfColors.white),
          _cell(t, 'Qty', bold: true, right: true, color: PdfColors.white),
          _cell(t, 'Rate', bold: true, right: true, color: PdfColors.white),
          _cell(t, 'Amount', bold: true, right: true, color: PdfColors.white),
        ],
      ),
      for (final (i, item) in order.items.indexed)
        pw.TableRow(
          children: [
            _cell(t, '${i + 1}', color: _grey),
            _cell(t, item.name),
            _cell(t, _qtyLabel(item), right: true),
            _cell(t, _rateLabel(item), right: true),
            _cell(t, item.totalPrice.formatted, right: true, bold: true),
          ],
        ),
    ],
  );
}

String _qtyLabel(OrderItemEntity item) {
  if (item.isWeighed) return formatGrams(item.qty);
  return item.unit == null ? '${item.qty}' : '${item.qty} ${item.unit!.value}';
}

String _rateLabel(OrderItemEntity item) => item.isWeighed
    ? '${item.unitPrice.formatted}/kg'
    : item.unitPrice.formatted;

pw.Widget _totals(_Text t, OrderEntity order) {
  pw.Widget row(
    String label,
    String value, {
    bool bold = false,
    double size = 9.5,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        t(label, bold: bold, size: size),
        t(value, bold: bold, size: size),
      ],
    ),
  );

  final discount = order.discount;
  return pw.Align(
    alignment: pw.Alignment.centerRight,
    child: pw.SizedBox(
      width: 230,
      child: pw.Column(
        children: [
          row('Subtotal', order.subtotal.formatted),
          if (discount != null && discount.amount > 0)
            row(
              order.couponCode == null
                  ? 'Discount'
                  : 'Discount (${order.couponCode})',
              '-${discount.formatted}',
            ),
          row('Delivery charge', order.deliveryCharge.formatted),
          pw.Divider(color: _line, thickness: 0.5),
          row('Total', order.grandTotal.formatted, bold: true, size: 12),
        ],
      ),
    ),
  );
}

/// The seller block as printed. What the owner entered wins; a blank field
/// falls back to the built-in constant (itself blank until the client supplies
/// it), and a blank address/GSTIN line is left out of the PDF rather than
/// printed empty.
({String name, String address, String gstin}) resolveSellerBlock(
  BusinessProfileEntity? seller,
) {
  String pick(String? entered, String fallback) =>
      (entered != null && entered.isNotEmpty) ? entered : fallback;
  return (
    name: pick(seller?.legalName, AppConstants.kAppName),
    address: pick(seller?.address, AppConstants.kInvoiceSellerAddress),
    gstin: pick(seller?.gstin, AppConstants.kInvoiceSellerGstin),
  );
}
