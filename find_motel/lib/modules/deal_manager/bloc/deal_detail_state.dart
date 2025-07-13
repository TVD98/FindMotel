import 'package:equatable/equatable.dart';

class DealDetailState extends Equatable {
  final String motelAddress;
  final bool isViewMode;
  final bool isSaving;
  final bool isSaved;
  final String? error;

  const DealDetailState({
    this.motelAddress = '',
    this.isViewMode = true,
    this.isSaving = false,
    this.isSaved = false,
    this.error,
  });

  DealDetailState copyWith({
    String? motelAddress,
    bool? isViewMode,
    bool? isSaving,
    bool? isSaved,
    String? error,
  }) {
    return DealDetailState(
      motelAddress: motelAddress ?? this.motelAddress,
      isViewMode: isViewMode ?? this.isViewMode,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    motelAddress,
    isViewMode,
    isSaving,
    isSaved,
    error,
  ];
}
