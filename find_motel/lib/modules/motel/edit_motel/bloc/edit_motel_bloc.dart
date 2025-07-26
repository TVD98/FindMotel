import 'package:bloc/bloc.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:find_motel/services/motel/motels_service.dart';
import 'package:find_motel/services/reload_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'edit_motel_event.dart';
import 'edit_motel_state.dart';

class EditMotelBloc extends Bloc<EditMotelEvent, EditMotelState> {
  final IMotelsService _motelsService;

  EditMotelBloc({IMotelsService? motelsService})
      : _motelsService = motelsService ?? FirestoreService(),
        super(const EditMotelState()) {
    on<EditMotelInitialized>(_onInitialized);
    on<EditMotelNameChanged>(_onNameChanged);
    on<EditMotelRoomCodeChanged>(_onRoomCodeChanged);
    on<EditMotelTypeChanged>(_onTypeChanged);
    on<EditMotelTextureChanged>(_onTextureChanged);
    on<EditMotelCommissionChanged>(_onCommissionChanged);
    on<EditMotelPriceChanged>(_onPriceChanged);
    on<EditMotelAddressChanged>(_onAddressChanged);
    on<EditMotelElectricityChanged>(_onElectricityChanged);
    on<EditMotelWaterChanged>(_onWaterChanged);
    on<EditMotelNoteChanged>(_onNoteChanged);
    on<EditMotelExtensionsUpdated>(_onExtensionsUpdated);
    on<EditMotelCustomFeeAdded>(_onCustomFeeAdded);
    on<EditMotelCustomFeeRemoved>(_onCustomFeeRemoved);
    on<EditMotelImagesUpdated>(_onImagesUpdated);
    on<EditMotelMainImageChanged>(_onMainImageChanged);
    on<EditMotelSubmitted>(_onSubmitted);
    on<EditMotelDeleted>(_onDeleted);
  }

  void _onInitialized(
      EditMotelInitialized event, Emitter<EditMotelState> emit) {
    final motel = event.motel;
    // Extract electricity and water values safely
    String getFeeValue(String name) {
      final fee = motel.fees.firstWhere(
        (f) => f['name'] == name,
        orElse: () => {},
      );
      if (fee.isEmpty) return '';
      final priceRaw = fee['price']?.toString() ?? '';
      return priceRaw.replaceAll(RegExp(r'[^\d]'), '');
    }

    // Initialize custom fees, excluding electricity and water
    final initialCustomFees = motel.fees
        .where((fee) => !['Điện', 'Nước'].contains(fee['name']))
        .map((fee) => Map<String, dynamic>.from(fee))
        .toList();

    emit(state.copyWith(
      initialMotel: motel,
      name: motel.name,
      roomCode: motel.roomCode,
      type: motel.type,
      texture: motel.texture,
      commission: motel.commission,
      price: motel.price.toStringAsFixed(0),
      address: motel.address,
      electricity: getFeeValue('Điện'),
      water: getFeeValue('Nước'),
      note: motel.note.join('\n'),
      extensions: List<String>.from(motel.extensions),
      customFees: initialCustomFees,
      images: List<String>.from(motel.images),
      mainImage: motel.thumbnail,
      status: EditMotelStatus.initial, // Reset status on re-initialization
    ));
  }

  void _onNameChanged(EditMotelNameChanged event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(name: event.name));
  }

  void _onRoomCodeChanged(
      EditMotelRoomCodeChanged event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(roomCode: event.roomCode));
  }

  void _onTypeChanged(EditMotelTypeChanged event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(type: event.type));
  }

  void _onTextureChanged(
      EditMotelTextureChanged event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(texture: event.texture));
  }

  void _onCommissionChanged(
      EditMotelCommissionChanged event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(commission: event.commission));
  }

  void _onPriceChanged(EditMotelPriceChanged event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(price: event.price));
  }

  void _onAddressChanged(
      EditMotelAddressChanged event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(address: event.address));
  }

  void _onElectricityChanged(
      EditMotelElectricityChanged event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(electricity: event.electricity));
  }

  void _onWaterChanged(EditMotelWaterChanged event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(water: event.water));
  }

  void _onNoteChanged(EditMotelNoteChanged event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(note: event.note));
  }

  void _onExtensionsUpdated(
      EditMotelExtensionsUpdated event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(extensions: event.extensions));
  }

  void _onCustomFeeAdded(
      EditMotelCustomFeeAdded event, Emitter<EditMotelState> emit) {
    final updatedCustomFees =
        List<Map<String, dynamic>>.from(state.customFees);
    updatedCustomFees.add({
      'name': event.name,
      'price': int.tryParse(event.price) ?? 0,
      'unit': event.unit,
    });
    emit(state.copyWith(customFees: updatedCustomFees));
  }

  void _onCustomFeeRemoved(
      EditMotelCustomFeeRemoved event, Emitter<EditMotelState> emit) {
    final updatedCustomFees =
        List<Map<String, dynamic>>.from(state.customFees);
    if (event.index >= 0 && event.index < updatedCustomFees.length) {
      updatedCustomFees.removeAt(event.index);
    }
    emit(state.copyWith(customFees: updatedCustomFees));
  }

  void _onImagesUpdated(
      EditMotelImagesUpdated event, Emitter<EditMotelState> emit) {
    // Ensure images are not empty before setting mainImage
    final newMainImage = event.images.isNotEmpty ? event.images.first : '';
    emit(state.copyWith(images: event.images, mainImage: newMainImage));
  }

  void _onMainImageChanged(
      EditMotelMainImageChanged event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(mainImage: event.mainImage));
  }

  Future<void> _onSubmitted(
      EditMotelSubmitted event, Emitter<EditMotelState> emit) async {
    emit(state.copyWith(status: EditMotelStatus.loading));

    if (state.name.isEmpty || state.address.isEmpty) {
      emit(state.copyWith(
          status: EditMotelStatus.failure,
          errorMessage: 'Vui lòng nhập đầy đủ tên căn hộ và địa chỉ!'));
      return;
    }

    try {
      final updatedFees = [
        {
          'name': 'Điện',
          'price': int.tryParse(state.electricity) ?? 0,
          'unit': 'số'
        },
        {
          'name': 'Nước',
          'price': int.tryParse(state.water) ?? 0,
          'unit': 'người'
        },
        ...state.customFees,
      ];

      final updatedMotel = Motel(
        id: state.initialMotel!.id, // Use the ID from the initial motel
        name: state.name,
        roomCode: state.roomCode,
        type: state.type,
        texture: state.texture,
        commission: state.commission,
        price: double.tryParse(state.price) ?? 0,
        address: state.address,
        note: state.note.split('\n'),
        extensions: state.extensions,
        fees: updatedFees,
        images: state.images,
        thumbnail: state.mainImage,
        geoPoint: state.initialMotel!.geoPoint, // Preserve original GeoPoint
        status: state.initialMotel!.status, // Preserve original status
        marker: state.mainImage, // marker should be thumbnail URL
      );

      final error = await _motelsService.updateMotelWithImages(updatedMotel);

      if (error == null) {
        ReloadService.setHomeNeedsReload();
        emit(state.copyWith(status: EditMotelStatus.success));
      } else {
        emit(state.copyWith(
            status: EditMotelStatus.failure, errorMessage: error));
      }
    } catch (e) {
      emit(state.copyWith(
          status: EditMotelStatus.failure, errorMessage: 'Có lỗi xảy ra: $e'));
    }
  }

  Future<void> _onDeleted(
      EditMotelDeleted event, Emitter<EditMotelState> emit) async {
    emit(state.copyWith(status: EditMotelStatus.deleting));
    if (state.initialMotel == null) {
      emit(state.copyWith(
          status: EditMotelStatus.failure,
          errorMessage: 'Không tìm thấy căn hộ để xóa.'));
      return;
    }

    try {
      final error = await _motelsService.deleteMotel(state.initialMotel!.id);
      if (error == null) {
        ReloadService.setHomeNeedsReload();
        emit(state.copyWith(status: EditMotelStatus.success)); // Dùng success để biểu thị xóa thành công và quay về
      } else {
        emit(state.copyWith(
            status: EditMotelStatus.failure, errorMessage: error));
      }
    } catch (e) {
      emit(state.copyWith(
          status: EditMotelStatus.failure, errorMessage: 'Có lỗi xảy ra: $e'));
    }
  }
}