import 'package:uuid/uuid.dart';
import '../../domain/entities/address_entity.dart';

/// Adds [address] (given [label]) into [existing], the retailer's saved
/// addresses — reused for both "save this address at checkout" (Checkout)
/// and any other future save-address entry point. Matches on street/city/
/// pincode (case/whitespace-insensitive) so re-saving the same physical
/// address just refreshes its label/coordinates and keeps its `id`, rather
/// than piling up near-duplicate entries every time a retailer re-orders to
/// the same place with the "save" toggle left on.
List<AddressEntity> mergeSavedAddress(
  List<AddressEntity> existing,
  AddressEntity address,
  String label,
) {
  String normalize(String s) => s.trim().toLowerCase();
  final matchIndex = existing.indexWhere(
    (a) =>
        normalize(a.street) == normalize(address.street) &&
        normalize(a.city) == normalize(address.city) &&
        normalize(a.pincode) == normalize(address.pincode),
  );

  if (matchIndex == -1) {
    final saved = address.copyWith(id: const Uuid().v4(), label: label);
    return [...existing, saved];
  }

  final updated = [...existing];
  updated[matchIndex] = address.copyWith(id: existing[matchIndex].id, label: label);
  return updated;
}
