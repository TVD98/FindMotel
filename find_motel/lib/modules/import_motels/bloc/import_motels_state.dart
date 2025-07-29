import 'package:find_motel/common/models/motel.dart';

class ImportedMotel {
  final Motel motel;
  final bool isValid;

  const ImportedMotel({required this.motel, required this.isValid});
}

class ImportMotelsState {
  final List<ImportedMotel>? motels;
  final bool isCanImport;
  final bool isLoading;
  final bool? isSaved;
  final String? error;

  const ImportMotelsState({this.motels, this.isLoading = false, this.isSaved, this.error, this.isCanImport = false});

  ImportMotelsState copyWith({List<ImportedMotel>? motels, bool? isLoading, bool? isSaved, String? error, bool? isCanImport}) {
    return ImportMotelsState(
      motels: motels ?? this.motels,
      isCanImport: isCanImport ?? this.isCanImport,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? this.isSaved,
      error: error ?? this.error,
    );
  }
}