import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';

class MotelDetailState extends Equatable {
  const MotelDetailState();

  @override
  List<Object> get props => [];
}

class MotelDetailLoaded extends MotelDetailState {
  final Motel motelDetail;
  final bool isCanEdit;

  const MotelDetailLoaded({
    required this.motelDetail,
    required this.isCanEdit,
  });

  MotelDetailLoaded copyWith({ 
    Motel? motelDetail,
    bool? isCanEdit,
  }) {
    return MotelDetailLoaded(
      motelDetail: motelDetail ?? this.motelDetail,
      isCanEdit: isCanEdit ?? this.isCanEdit,
    );
  }

  @override
  List<Object> get props => [
        motelDetail,
        isCanEdit,
      ];
}