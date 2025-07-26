import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';

abstract class EditMotelEvent extends Equatable {
  const EditMotelEvent();

  @override
  List<Object> get props => [];
}

class EditMotelNameChanged extends EditMotelEvent {
  final String name;
  const EditMotelNameChanged(this.name);
  @override
  List<Object> get props => [name];
}

class EditMotelRoomCodeChanged extends EditMotelEvent {
  final String roomCode;
  const EditMotelRoomCodeChanged(this.roomCode);
  @override
  List<Object> get props => [roomCode];
}

class EditMotelTypeChanged extends EditMotelEvent {
  final String type;
  const EditMotelTypeChanged(this.type);
  @override
  List<Object> get props => [type];
}

class EditMotelTextureChanged extends EditMotelEvent {
  final String texture;
  const EditMotelTextureChanged(this.texture);
  @override
  List<Object> get props => [texture];
}

class EditMotelCommissionChanged extends EditMotelEvent {
  final String commission;
  const EditMotelCommissionChanged(this.commission);
  @override
  List<Object> get props => [commission];
}

class EditMotelPriceChanged extends EditMotelEvent {
  final String price;
  const EditMotelPriceChanged(this.price);
  @override
  List<Object> get props => [price];
}

class EditMotelAddressChanged extends EditMotelEvent {
  final String address;
  const EditMotelAddressChanged(this.address);
  @override
  List<Object> get props => [address];
}

class EditMotelElectricityChanged extends EditMotelEvent {
  final String electricity;
  const EditMotelElectricityChanged(this.electricity);
  @override
  List<Object> get props => [electricity];
}

class EditMotelWaterChanged extends EditMotelEvent {
  final String water;
  const EditMotelWaterChanged(this.water);
  @override
  List<Object> get props => [water];
}

class EditMotelNoteChanged extends EditMotelEvent {
  final String note;
  const EditMotelNoteChanged(this.note);
  @override
  List<Object> get props => [note];
}

class EditMotelExtensionsUpdated extends EditMotelEvent {
  final List<String> extensions;
  const EditMotelExtensionsUpdated(this.extensions);
  @override
  List<Object> get props => [extensions];
}

class EditMotelCustomFeeAdded extends EditMotelEvent {
  final String name;
  final String price;
  final String unit;
  const EditMotelCustomFeeAdded({required this.name, required this.price, required this.unit});
  @override
  List<Object> get props => [name, price, unit];
}

class EditMotelCustomFeeRemoved extends EditMotelEvent {
  final int index;
  const EditMotelCustomFeeRemoved(this.index);
  @override
  List<Object> get props => [index];
}

class EditMotelImagesUpdated extends EditMotelEvent {
  final List<String> images;
  const EditMotelImagesUpdated(this.images);
  @override
  List<Object> get props => [images];
}

class EditMotelMainImageChanged extends EditMotelEvent {
  final String mainImage;
  const EditMotelMainImageChanged(this.mainImage);
  @override
  List<Object> get props => [mainImage];
}

class EditMotelSubmitted extends EditMotelEvent {
  const EditMotelSubmitted();
}

class EditMotelDeleted extends EditMotelEvent {
  const EditMotelDeleted();
}

class EditMotelInitialized extends EditMotelEvent {
  final Motel motel;
  const EditMotelInitialized(this.motel);
  @override
  List<Object> get props => [motel];
}