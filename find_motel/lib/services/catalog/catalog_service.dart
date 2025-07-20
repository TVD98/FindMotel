import 'package:find_motel/common/models/area.dart';
import 'package:find_motel/common/models/import_images_options.dart';

abstract class ICatalogService {
  Future<({List<Province>? provinces, String? error})> fetchProvinces();
  Future<({ImportImagesOptions? options, String? error})> fetchImportImagesOptions();
}
