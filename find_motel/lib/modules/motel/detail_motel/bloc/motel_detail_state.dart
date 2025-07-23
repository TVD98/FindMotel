import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';

class MotelDetailState extends Equatable {
  const MotelDetailState();

  @override
  List<Object> get props => [];
}

class MotelDetailInitial extends MotelDetailState {} 

class MotelDetailLoading extends MotelDetailState {} 

class MotelDetailLoaded extends MotelDetailState {
  final Motel motelDetail;
  final String currentMainImage;
  final bool isCanEdit;
  final bool needsReloadHome;

  const MotelDetailLoaded({
    required this.motelDetail,
    required this.currentMainImage,
    required this.isCanEdit,
    this.needsReloadHome = false,
  });

  MotelDetailLoaded copyWith({ 
    Motel? motelDetail,
    String? currentMainImage,
    bool? isCanEdit,
    bool? needsReloadHome,
  }) {
    return MotelDetailLoaded(
      motelDetail: motelDetail ?? this.motelDetail,
      currentMainImage: currentMainImage ?? this.currentMainImage,
      isCanEdit: isCanEdit ?? this.isCanEdit,
      needsReloadHome: needsReloadHome ?? this.needsReloadHome,
    );
  }

  @override
  List<Object> get props => [
        motelDetail,
        currentMainImage,
        isCanEdit,
        needsReloadHome,
      ];
}

class MotelDetailError extends MotelDetailState {
  final String message;
  const MotelDetailError(this.message);

  @override
  List<Object> get props => [message];
}