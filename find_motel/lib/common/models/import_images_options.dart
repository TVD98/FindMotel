import 'package:find_motel/services/image_picker/image_source_option.dart';

class ImportImagesOptions {
  bool gallery;
  bool link;

  ImportImagesOptions({required this.gallery, required this.link});

  factory ImportImagesOptions.fromMap(Map<String, dynamic> map) {
    return ImportImagesOptions(
      gallery: map['gallery'] as bool,
      link: map['link'] as bool,
    );
  }

  List<ImageSourceOption> imageSourceOptions() {
    final List<ImageSourceOption> imageSourceOptions = [];
    if (gallery) {
      imageSourceOptions.add(ImageSourceOption.gallery);
    }
    if (link) {
      imageSourceOptions.add(ImageSourceOption.link);
    }

    return imageSourceOptions;
  }
}
