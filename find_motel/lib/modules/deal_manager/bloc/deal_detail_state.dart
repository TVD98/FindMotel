import 'package:equatable/equatable.dart';

class DealDetailState extends Equatable {
  final String motelAddress;
  final bool isCreate;
  final bool isViewMode;
  final bool isSaving;
  final bool isSaved;
  final bool isDeleted;
  final String? error;

  const DealDetailState({
    this.motelAddress = '',
    this.isCreate = false,
    this.isViewMode = true,
    this.isSaving = false,
    this.isSaved = false,
    this.isDeleted = false,
    this.error,
  });

  DealDetailState copyWith({
    String? motelAddress,
    bool? isCreate,
    bool? isViewMode,
    bool? isSaving,
    bool? isSaved,
    bool? isDeleted,
    String? error,
  }) {
    return DealDetailState(
      motelAddress: motelAddress ?? this.motelAddress,
      isCreate: isCreate ?? this.isCreate,
      isViewMode: isViewMode ?? this.isViewMode,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      isDeleted: isDeleted ?? this.isDeleted,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    motelAddress,
    isCreate,
    isViewMode,
    isSaving,
    isSaved,
    isDeleted,
    error,
  ];
}
