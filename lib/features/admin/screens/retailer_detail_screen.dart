import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/user_entity.dart';
import '../widgets/approval_actions_row.dart';

/// Full retailer profile — everything [RetailerApprovalCard] can't fit on
/// a summary tile (email, GST, bank details, business hours, sign-up date).
/// Reached by tapping a card in the dashboard preview or [ApprovalQueueScreen].
class RetailerDetailScreen extends StatelessWidget {
  final UserEntity user;

  const RetailerDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final address = user.address;
    final bank = user.bankDetails;
    final hours = user.businessHours;

    return Scaffold(
      appBar: AppBar(title: Text(user.shopName, style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    user.shopName.isNotEmpty ? user.shopName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.shopName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      _StatusBadge(status: user.status),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Section(title: 'Owner', child: _KV('Full name', user.fullName)),
                _Section(
                  title: 'Contact',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _KV('Email', user.email),
                      _KV('Phone', user.phone),
                    ],
                  ),
                ),
                _Section(
                  title: 'Address',
                  child: address == null
                      ? Text('Address not provided yet', style: GoogleFonts.inter(fontSize: 13, fontStyle: FontStyle.italic))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _KV('Street', address.street),
                            _KV('City', address.city),
                            _KV('Pincode', address.pincode),
                            if (address.formattedAddress != null) _KV('Location', address.formattedAddress!),
                          ],
                        ),
                ),
                _Section(
                  title: 'GST',
                  child: _KV('GST Number', user.gstNumber != null && user.gstNumber!.isNotEmpty ? user.gstNumber! : '—'),
                ),
                _Section(
                  title: 'Business Hours',
                  child: _KV('Open', hours == null || hours.is24x7 ? 'Open 24×7' : '${hours.openTime} – ${hours.closeTime}'),
                ),
                if (bank != null)
                  _Section(
                    title: 'Bank Details',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _KV('Account holder', bank.accountHolderName),
                        _KV('Account number', bank.maskedAccountNumber),
                        _KV('IFSC', bank.ifscCode),
                        _KV('Bank', bank.bankName),
                        if (bank.upiId != null && bank.upiId!.isNotEmpty) _KV('UPI ID', bank.upiId!),
                      ],
                    ),
                  ),
                _Section(title: 'Registered On', last: true, child: _KV('Date', formatOrderDateTime(user.createdAt))),
              ],
            ),
          ),

          if (user.status == UserStatus.pending) ...[
            const SizedBox(height: 16),
            ApprovalActionsRow(user: user, onActionComplete: () => Navigator.of(context).pop()),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final UserStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      UserStatus.pending => AppColors.warning,
      UserStatus.approved => AppColors.success,
      UserStatus.rejected => AppColors.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final bool last;
  const _Section({required this.title, required this.child, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String label;
  final String value;
  const _KV(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondaryLight))),
          Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
