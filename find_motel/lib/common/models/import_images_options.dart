
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
}
