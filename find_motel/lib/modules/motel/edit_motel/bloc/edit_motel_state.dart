import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum EditMotelStatus { initial, loading, success, failure, deleting }

class EditMotelState extends Equatable {
  final EditMotelStatus status;
  final String name;
  final String roomCode;
  final String type;
  final String texture;
  final String commission;
  final String price;
  final String address;
  final String note;
  final List<String> phoneNumbers;
  final List<String> extensions;
  final List<Fee> customFees;
  final List<String> images;
  final LatLng? location;
  final String? errorMessage;
  final Motel? initialMotel;
  final Motel? updatedMotel;

  const EditMotelState({
    this.status = EditMotelStatus.initial,
    this.name = '',
    this.roomCode = '',
    this.type = '',
    this.texture = '',
    this.commission = '',
    this.price = '',
    this.address = '',
    this.note = '',
    this.phoneNumbers = const [],
    this.extensions = const [],
    this.customFees = const [],
    this.images = const [],
    this.location,
    this.errorMessage,
    this.initialMotel,
    this.updatedMotel,
  });

  EditMotelState copyWith({
    EditMotelStatus? status,
    String? name,
    String? roomCode,
    String? type,
    String? texture,
    String? commission,
    String? price,
    String? address,
    String? note,
    List<String>? phoneNumbers,
    List<String>? extensions,
    List<Fee>? customFees,
    List<String>? images,
    LatLng? location,
    String? errorMessage,
    Motel? initialMotel,
    Motel? updatedMotel,
  }) {
    return EditMotelState(
      status: status ?? this.status,
      name: name ?? this.name,
      roomCode: roomCode ?? this.roomCode,
      type: type ?? this.type,
      texture: texture ?? this.texture,
      commission: commission ?? this.commission,
      price: price ?? this.price,
      address: address ?? this.address,
      note: note ?? this.note,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      extensions: extensions ?? this.extensions,
      customFees: customFees ?? this.customFees,
      images: images ?? this.images,
      location: location ?? this.location,
      errorMessage: errorMessage,
      initialMotel: initialMotel ?? this.initialMotel,
      updatedMotel: updatedMotel,
    );
  }

  @override
  List<Object?> get props => [
    status,
    name,
    roomCode,
    type,
    texture,
    commission,
    price,
    address,
    note,
    phoneNumbers,
    extensions,
    customFees,
    images,
    location,
    errorMessage,
    initialMotel,
    updatedMotel,
  ];
}
