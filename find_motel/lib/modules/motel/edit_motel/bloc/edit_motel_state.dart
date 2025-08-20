import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum EditMotelStatus { initial, loading, success, failure, deleting }

enum EditMotelMode { create, edit }

class EditMotelState extends Equatable {
  final EditMotelStatus status;
  final String name;
  final String roomCode;
  final String type;
  final String texture;
  final String commission;
  final String price;
  final String prefixAddress;
  final Address? address;
  final String fullAddress;
  final String note;
  final String car;
  final RentalStatus rentalStatus;
  final List<String> phoneNumbers;
  final List<String> extensions;
  final List<Fee> customFees;
  final List<String> images;
  final LatLng? location;
  final String? errorMessage;
  final Motel? initialMotel;
  final Motel? updatedMotel;
  final EditMotelMode mode;

  const EditMotelState({
    this.status = EditMotelStatus.initial,
    this.name = '',
    this.roomCode = '',
    this.type = '',
    this.texture = '',
    this.commission = '',
    this.price = '',
    this.prefixAddress = '',
    this.address,
    this.fullAddress = '',
    this.note = '',
    this.car = '',
    this.rentalStatus = RentalStatus.empty,
    this.phoneNumbers = const [],
    this.extensions = const [],
    this.customFees = const [],
    this.images = const [],
    this.location,
    this.errorMessage,
    this.initialMotel,
    this.updatedMotel,
    this.mode = EditMotelMode.edit,
  });

  EditMotelState copyWith({
    EditMotelStatus? status,
    String? name,
    String? roomCode,
    String? type,
    String? texture,
    String? commission,
    String? price,
    String? prefixAddress,
    Address? address,
    String? fullAddress,
    String? note,
    String? car,
    RentalStatus? rentalStatus,
    List<String>? phoneNumbers,
    List<String>? extensions,
    List<Fee>? customFees,
    List<String>? images,
    LatLng? location,
    String? errorMessage,
    Motel? initialMotel,
    Motel? updatedMotel,
    EditMotelMode? mode,
  }) {
    return EditMotelState(
      status: status ?? this.status,
      name: name ?? this.name,
      roomCode: roomCode ?? this.roomCode,
      type: type ?? this.type,
      texture: texture ?? this.texture,
      commission: commission ?? this.commission,
      price: price ?? this.price,
      prefixAddress: prefixAddress ?? this.prefixAddress,
      address: address ?? this.address,
      fullAddress: fullAddress ?? this.fullAddress,
      note: note ?? this.note,
      car: car ?? this.car,
      rentalStatus: rentalStatus ?? this.rentalStatus,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      extensions: extensions ?? this.extensions,
      customFees: customFees ?? this.customFees,
      images: images ?? this.images,
      location: location ?? this.location,
      errorMessage: errorMessage,
      initialMotel: initialMotel ?? this.initialMotel,
      updatedMotel: updatedMotel,
      mode: mode ?? this.mode,
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
    prefixAddress,
    address,
    fullAddress,
    note,
    car,
    rentalStatus,
    phoneNumbers,
    extensions,
    customFees,
    images,
    location,
    errorMessage,
    initialMotel,
    updatedMotel,
    mode,
  ];
}
