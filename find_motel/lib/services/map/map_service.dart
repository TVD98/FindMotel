import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/services/map/models/motels_filter.dart';

abstract class IMapService {
  Future<({List<Motel>? motels, String? error})> getMotels({MotelsFilter? filter, int limit});
}