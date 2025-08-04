import 'package:bloc/bloc.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:find_motel/services/motel/motels_service.dart';

import 'edit_motel_event.dart';
import 'edit_motel_state.dart';

class EditMotelBloc extends Bloc<EditMotelEvent, EditMotelState> {
  final IMotelsService _motelsService;

  EditMotelBloc({IMotelsService? motelsService})
    : _motelsService = motelsService ?? FirestoreService(),
      super(const EditMotelState()) {
    on<EditMotelInitialized>(_onInitialized);
    on<EditMotelTypeChanged>(_onTypeChanged);
    on<EditMotelTextureChanged>(_onTextureChanged);
    on<EditMotelCommissionChanged>(_onCommissionChanged);
    on<EditMotelPriceChanged>(_onPriceChanged);
    on<EditMotelAddressChanged>(_onAddressChanged);
    on<EditMotelNoteChanged>(_onNoteChanged);
    on<EditMotelPhoneNumbersChanged>(_onPhoneNumbersChanged);
    on<EditMotelExtensionsUpdated>(_onExtensionsUpdated);
    on<EditMotelFeeUpdated>(_onFeeUpdated);
    on<EditMotelFeeAdded>(_onFeeAdded);
    on<EditMotelFeeDeleted>(_onFeeDeleted);
    on<EditMotelImagesUpdated>(_onImagesUpdated);
    on<EditMotelSubmitted>(_onSubmitted);
    on<EditMotelDeleted>(_onDeleted);
    on<EditMotelLocationUpdated>(_onLocationUpdated);
  }

  void _onInitialized(
    EditMotelInitialized event,
    Emitter<EditMotelState> emit,
  ) {
    final motel = event.motel;

    emit(
      state.copyWith(
        initialMotel: motel,
        name: motel.name,
        roomCode: motel.roomCode,
        type: motel.type,
        texture: motel.texture,
        commission: motel.commission,
        price: motel.price.toStringAsFixed(0),
        address: motel.address,
        note: motel.note.join('\n'),
        phoneNumbers: List<String>.from(motel.phoneNumbers),
        extensions: List<String>.from(motel.extensions),
        customFees: motel.fees,
        images: List<String>.from(motel.images),
        status: EditMotelStatus.initial,
        location: motel.geoPoint,
      ),
    );
  }

  void _onTypeChanged(
    EditMotelTypeChanged event,
    Emitter<EditMotelState> emit,
  ) {
    emit(state.copyWith(type: event.type));
  }

  void _onTextureChanged(
    EditMotelTextureChanged event,
    Emitter<EditMotelState> emit,
  ) {
    emit(state.copyWith(texture: event.texture));
  }

  void _onCommissionChanged(
    EditMotelCommissionChanged event,
    Emitter<EditMotelState> emit,
  ) {
    emit(state.copyWith(commission: event.commission));
  }

  void _onPriceChanged(
    EditMotelPriceChanged event,
    Emitter<EditMotelState> emit,
  ) {
    emit(state.copyWith(price: event.price.replaceAll(RegExp(r'[^0-9]'), '')));
  }

  void _onAddressChanged(
    EditMotelAddressChanged event,
    Emitter<EditMotelState> emit,
  ) {
    emit(state.copyWith(address: event.address));
  }

  void _onNoteChanged(
    EditMotelNoteChanged event,
    Emitter<EditMotelState> emit,
  ) {
    emit(state.copyWith(note: event.note));
  }

  void _onExtensionsUpdated(
    EditMotelExtensionsUpdated event,
    Emitter<EditMotelState> emit,
  ) {
    emit(state.copyWith(extensions: event.extensions));
  }

  void _onFeeUpdated(EditMotelFeeUpdated event, Emitter<EditMotelState> emit) {
    final updatedFees = state.customFees.map((fee) {
      if (fee.name == event.fee.name) {
        return event.fee;
      }
      return fee;
    }).toList();
    emit(state.copyWith(customFees: updatedFees));
  }

  void _onFeeAdded(EditMotelFeeAdded event, Emitter<EditMotelState> emit) {
    emit(state.copyWith(customFees: [...state.customFees, event.fee]));
  }

  void _onFeeDeleted(EditMotelFeeDeleted event, Emitter<EditMotelState> emit) {
    final updatedFees = state.customFees
        .where((fee) => fee.name != event.fee.name)
        .toList();
    emit(state.copyWith(customFees: updatedFees));
  }

  void _onImagesUpdated(
    EditMotelImagesUpdated event,
    Emitter<EditMotelState> emit,
  ) {
    emit(state.copyWith(images: event.images));
  }

  void _onLocationUpdated(
    EditMotelLocationUpdated event,
    Emitter<EditMotelState> emit,
  ) {
    emit(state.copyWith(location: event.location));
  }

  void _onPhoneNumbersChanged(
    EditMotelPhoneNumbersChanged event,
    Emitter<EditMotelState> emit,
  ) {
    emit(state.copyWith(phoneNumbers: event.phoneNumbers));
  }

  Future<void> _onSubmitted(
    EditMotelSubmitted event,
    Emitter<EditMotelState> emit,
  ) async {
    emit(state.copyWith(status: EditMotelStatus.loading));

    if (state.address.isEmpty) {
      emit(
        state.copyWith(
          status: EditMotelStatus.failure,
          errorMessage: 'Vui lòng nhập địa chỉ!',
        ),
      );
      return;
    }

    try {
      final updatedMotel = state.initialMotel!.copyWith(
        name: state.name,
        type: state.type,
        texture: state.texture,
        commission: state.commission,
        price: double.tryParse(state.price) ?? 0,
        address: state.address,
        note: state.note.split('\n'),
        extensions: state.extensions,
        fees: state.customFees,
        images: state.images,
        phoneNumbers: state.phoneNumbers,
        thumbnail: state.images.isNotEmpty ? state.images.first : '',
        geoPoint: state.location ?? state.initialMotel!.geoPoint,
        marker: state.images.isNotEmpty
            ? state.images.first
            : '', // marker should be thumbnail URL
      );

      final ({String? error, Motel? motel}) result;
      if (updatedMotel.createdAt == null) {
        result = await _motelsService.addMotelWithImages(updatedMotel);
      } else {
        result = await _motelsService.updateMotelWithImages(updatedMotel);
      }

      if (result.error == null) {
        emit(
          state.copyWith(
            status: EditMotelStatus.success,
            updatedMotel: result.motel,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: EditMotelStatus.failure,
            errorMessage: result.error,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: EditMotelStatus.failure,
          errorMessage: 'Có lỗi xảy ra: $e',
        ),
      );
    }
  }

  Future<void> _onDeleted(
    EditMotelDeleted event,
    Emitter<EditMotelState> emit,
  ) async {
    emit(state.copyWith(status: EditMotelStatus.deleting));
    if (state.initialMotel == null) {
      emit(
        state.copyWith(
          status: EditMotelStatus.failure,
          errorMessage: 'Không tìm thấy căn hộ để xóa.',
        ),
      );
      return;
    }

    try {
      final error = await _motelsService.deleteMotel(state.initialMotel!.id);
      if (error == null) {
        emit(
          state.copyWith(status: EditMotelStatus.success, updatedMotel: null),
        ); // Dùng success để biểu thị xóa thành công và quay về
      } else {
        emit(
          state.copyWith(status: EditMotelStatus.failure, errorMessage: error),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: EditMotelStatus.failure,
          errorMessage: 'Có lỗi xảy ra: $e',
        ),
      );
    }
  }
}
