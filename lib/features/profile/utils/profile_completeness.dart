import '../../../data/models/user_model.dart';

/// One thing a retailer can still fill in. Each is something the app actually
/// uses: the photo identifies the shop, coordinates drive the per-km delivery
/// charge, GST goes on invoices, payout details are needed to be paid back.
enum ProfileTask { photo, location, gst, payout }

/// How complete a retailer's profile is — [missing] drives the tappable
/// prompts on the Profile tab, [percent] the progress ring.
class ProfileCompleteness {
  final List<ProfileTask> missing;

  const ProfileCompleteness(this.missing);

  int get total => ProfileTask.values.length;
  int get done => total - missing.length;
  int get percent => (done * 100 / total).round();
  bool get isComplete => missing.isEmpty;
}

ProfileCompleteness computeProfileCompleteness(UserModel user) {
  final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;
  // A typed address without coordinates still leaves delivery charge on the
  // flat placeholder, so it doesn't count as "location set".
  final hasLocation = user.address?.hasCoordinates ?? false;
  final hasGst = user.gstNumber != null && user.gstNumber!.trim().isNotEmpty;
  final bank = user.bankDetails;
  final hasPayout =
      bank != null &&
      (bank.accountNumber.trim().isNotEmpty ||
          (bank.upiId != null && bank.upiId!.trim().isNotEmpty));

  return ProfileCompleteness([
    if (!hasPhoto) ProfileTask.photo,
    if (!hasLocation) ProfileTask.location,
    if (!hasGst) ProfileTask.gst,
    if (!hasPayout) ProfileTask.payout,
  ]);
}
