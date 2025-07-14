import 'package:find_motel/common/models/area.dart';

abstract class ICatalogService {
  Future<({List<Province>? provinces, String? error})> fetchProvinces();
}
