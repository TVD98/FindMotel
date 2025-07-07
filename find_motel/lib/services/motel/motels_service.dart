import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';

abstract class IMotelsService {
  Future<({List<Motel>? motels, String? error})> getMotels({
    MotelsFilter? filter,
    int limit,
  });

  Future<({String? id, String? error})> addMotel(Motel motel);

  /// Update one or many fields of an existing motel document. Returns `null` on
  /// success, or an error string if the update fails.
  Future<String?> updateMotel(String motelId, Map<String, dynamic> data);

  /// Convenience method for updating a single field.
  Future<String?> updateMotelField(String motelId, String field, dynamic value);

}
