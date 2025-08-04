import 'package:find_motel/common/models/motel.dart';

class ImportedMotel {
  final Motel motel;
  final bool isValid;

  const ImportedMotel({required this.motel, required this.isValid});

  ImportedMotel copyWith({Motel? motel, bool? isValid}) {
    return ImportedMotel(
      motel: motel ?? this.motel,
      isValid: isValid ?? this.isValid,
    );
  }
}

class ImportedMotelList {
  final String sheetName;
  final List<ImportedMotel> motels;

  const ImportedMotelList({required this.sheetName, required this.motels});
}

class ImportMotelsState {
  final List<ImportedMotelList>? sheetList;
  final bool isCanImport;
  final bool isLoading;
  final bool? isSaved;
  final String? error;

  const ImportMotelsState({
    this.sheetList,
    this.isLoading = false,
    this.isSaved,
    this.error,
    this.isCanImport = false,
  });

  ImportMotelsState copyWith({
    List<ImportedMotelList>? sheetList,
    bool? isLoading,
    bool? isSaved,
    String? error,
    bool? isCanImport,
  }) {
    return ImportMotelsState(
      sheetList: sheetList ?? this.sheetList,
      isCanImport: isCanImport ?? this.isCanImport,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? this.isSaved,
      error: error ?? this.error,
    );
  }
}
