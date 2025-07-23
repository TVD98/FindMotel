// lib/modules/motel_manager/detail/motel_detail_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/common/models/user_profile.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/services/motel/motels_service.dart';

import 'motel_detail_event.dart'; // Đổi import
import 'motel_detail_state.dart'; // Đổi import

class MotelDetailBloc extends Bloc<MotelDetailEvent, MotelDetailState> { 
  final IMotelsService _motelsService;

  MotelDetailBloc({ 
    required Motel initialMotelDetail,
    required IMotelsService motelsService,
  })  : _motelsService = motelsService,
        super(MotelDetailLoaded( 
          motelDetail: initialMotelDetail,
          currentMainImage: initialMotelDetail.thumbnail,
          isCanEdit: AppDataManager().currentUserProfile?.role == UserRole.admin,
        )) {
    on<MotelDetailInitialLoad>(_onMotelDetailInitialLoad); 
    on<MotelDetailUpdateMainImage>(_onMotelDetailUpdateMainImage); 
    on<MotelDetailMotelUpdated>(_onMotelDetailMotelUpdated); 
  }

  Future<void> _onMotelDetailInitialLoad( 
    MotelDetailInitialLoad event, 
    Emitter<MotelDetailState> emit, 
  ) async {
    emit(MotelDetailLoading()); 

    try {
      final result = await _motelsService.getMotelById(event.motelId);
      if (result.motel != null) {
        final currentMainImage = result.motel!.thumbnail;
        final isCanEdit = AppDataManager().currentUserProfile?.role == UserRole.admin;
        emit(MotelDetailLoaded( 
          motelDetail: result.motel!,
          currentMainImage: currentMainImage,
          isCanEdit: isCanEdit,
        ));
      } else {
        emit(MotelDetailError(result.error ?? 'Không tìm thấy thông tin phòng.'));
      }
    } catch (e) {
      emit(MotelDetailError('Lỗi tải chi tiết phòng: $e')); 
    }
  }

  void _onMotelDetailUpdateMainImage( 
    MotelDetailUpdateMainImage event, 
    Emitter<MotelDetailState> emit, 
  ) {
    if (state is MotelDetailLoaded) { 
      final currentState = state as MotelDetailLoaded; 
      emit(currentState.copyWith(currentMainImage: event.newImageUrl));
    }
  }

  Future<void> _onMotelDetailMotelUpdated( 
    MotelDetailMotelUpdated event, 
    Emitter<MotelDetailState> emit, 
  ) async {
    if (state is MotelDetailLoaded) { 
      final currentMotelId = (state as MotelDetailLoaded).motelDetail.id; 
      emit(MotelDetailLoading()); 

      try {
        final result = await _motelsService.getMotelById(currentMotelId);
        if (result.motel != null) {
          final newMotel = result.motel!;
          final currentMainImage = newMotel.thumbnail;
          final isCanEdit = AppDataManager().currentUserProfile?.role == UserRole.admin;
          emit(MotelDetailLoaded( 
            motelDetail: newMotel,
            currentMainImage: currentMainImage,
            isCanEdit: isCanEdit,
            needsReloadHome: true,
          ));
        } else {
          emit(MotelDetailError(result.error ?? 'Không thể tải lại thông tin phòng sau khi cập nhật.')); 
        }
      } catch (e) {
        emit(MotelDetailError('Lỗi khi tải lại chi tiết phòng: $e'));
      }
    }
  }
}