import 'package:find_motel/common/models/motel.dart';

class ImportMotelsState {
  final List<Motel>? motels;
  final bool? isSaved;
  final String? error;

  const ImportMotelsState({this.motels, this.isSaved, this.error});

  ImportMotelsState copyWith({List<Motel>? motels, bool? isSaved, String? error}) {
    return ImportMotelsState(
      motels: motels ?? this.motels,
      isSaved: isSaved ?? this.isSaved,
      error: error ?? this.error,
    );
  }
}