import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class EditMotelEvent extends Equatable {
  const EditMotelEvent();

  @override
  List<Object> get props => [];
}

class EditMotelPhoneNumbersChanged extends EditMotelEvent {
  final List<String> phoneNumbers;
  const EditMotelPhoneNumbersChanged(this.phoneNumbers);
  @override
  List<Object> get props => [phoneNumbers];
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

class EditMotelFeeUpdated extends EditMotelEvent {
  final Fee fee;
  const EditMotelFeeUpdated(this.fee);
  @override
  List<Object> get props => [fee];
}

class EditMotelFeeAdded extends EditMotelEvent {
  final Fee fee;
  const EditMotelFeeAdded(this.fee);
  @override
  List<Object> get props => [fee];
}

class EditMotelFeeDeleted extends EditMotelEvent {
  final Fee fee;
  const EditMotelFeeDeleted(this.fee);
  @override
  List<Object> get props => [fee];
}

class EditMotelImagesUpdated extends EditMotelEvent {
  final List<String> images;
  const EditMotelImagesUpdated(this.images);
  @override
  List<Object> get props => [images];
}

class EditMotelLocationUpdated extends EditMotelEvent {
  final LatLng location;
  const EditMotelLocationUpdated(this.location);
  @override
  List<Object> get props => [location];
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