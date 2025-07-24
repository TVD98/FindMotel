import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';

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
  final String electricity;
  final String water;
  final String note;
  final List<String> extensions;
  final List<Map<String, dynamic>> customFees;
  final List<String> images;
  final String mainImage;
  final String? errorMessage;
  final Motel? initialMotel;

  const EditMotelState({
    this.status = EditMotelStatus.initial,
    this.name = '',
    this.roomCode = '',
    this.type = '',
    this.texture = '',
    this.commission = '',
    this.price = '',
    this.address = '',
    this.electricity = '',
    this.water = '',
    this.note = '',
    this.extensions = const [],
    this.customFees = const [],
    this.images = const [],
    this.mainImage = '',
    this.errorMessage,
    this.initialMotel,
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
    String? electricity,
    String? water,
    String? note,
    List<String>? extensions,
    List<Map<String, dynamic>>? customFees,
    List<String>? images,
    String? mainImage,
    String? errorMessage,
    Motel? initialMotel,
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
      electricity: electricity ?? this.electricity,
      water: water ?? this.water,
      note: note ?? this.note,
      extensions: extensions ?? this.extensions,
      customFees: customFees ?? this.customFees,
      images: images ?? this.images,
      mainImage: mainImage ?? this.mainImage,
      errorMessage: errorMessage,
      initialMotel: initialMotel ?? this.initialMotel,
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
        electricity,
        water,
        note,
        extensions,
        customFees,
        images,
        mainImage,
        errorMessage,
        initialMotel,
      ];
}