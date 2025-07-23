import 'package:equatable/equatable.dart';

abstract class MotelDetailEvent extends Equatable { 
  const MotelDetailEvent();

  @override
  List<Object> get props => [];
}

class MotelDetailInitialLoad extends MotelDetailEvent {
  final String motelId;
  const MotelDetailInitialLoad(this.motelId);

  @override
  List<Object> get props => [motelId];
}

class MotelDetailUpdateMainImage extends MotelDetailEvent {
  final String newImageUrl;
  const MotelDetailUpdateMainImage(this.newImageUrl);

  @override
  List<Object> get props => [newImageUrl];
}

class MotelDetailMotelUpdated extends MotelDetailEvent { 
  const MotelDetailMotelUpdated();

  @override
  List<Object> get props => [];
}