import 'package:find_motel/common/models/motel.dart';

class ImportMotelsState {
  final List<Motel>? motels;
  final bool isLoading;
  final bool? isSaved;
  final String? error;

  const ImportMotelsState({this.motels, this.isLoading = false, this.isSaved, this.error});

  ImportMotelsState copyWith({List<Motel>? motels, bool? isLoading, bool? isSaved, String? error}) {
    return ImportMotelsState(
      motels: motels ?? this.motels,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? this.isSaved,
      error: error ?? this.error,
    );
  }
}