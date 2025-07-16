import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/extensions/string_extensions.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/modules/import_motels/bloc/import_motels_event.dart';
import 'package:find_motel/modules/import_motels/bloc/import_motels_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:find_motel/services/motel/motels_service.dart';

class ImportMotelsBloc extends Bloc<ImportMotelsEvent, ImportMotelsState> {
  final IMotelsService _motelsService;
  ImportMotelsBloc({IMotelsService? motelsService})
    : _motelsService = motelsService ?? FirestoreService(),
      super(const ImportMotelsState()) {
    on<HandleFileEvent>((event, emit) {
      final motels = _parseMotels(event.data);
      emit(state.copyWith(motels: motels));
    });

    on<SaveMotelsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        for (final motel in event.motels) {
          final result = await _motelsService.addMotel(motel);
          if (result.error != null) {
            emit(state.copyWith(isLoading: false, error: result.error));
            return;
          }
        }
        emit(state.copyWith(isLoading: false, isSaved: true));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }

  List<Motel> _parseMotels(List<List<String>> data) {
    final motelIndex = AppDataManager().motelIndex;
    final maxFields = motelIndex?.maxFields();
    final maxColumn = data
        .map((e) => e.length)
        .toList()
        .reduce((a, b) => a > b ? a : b);
    final maxRow = data.length;
    if (motelIndex == null ||
        motelIndex.start == null ||
        motelIndex.start! > maxRow ||
        maxFields == null ||
        maxFields > maxColumn) {
      return [];
    }
    final numberIndex = motelIndex.number?.toIndex() ?? 0;
    final streetIndex = motelIndex.street?.toIndex() ?? 0;
    final wardIndex = motelIndex.ward?.toIndex() ?? 0;
    final priceIndex = motelIndex.price?.toIndex() ?? 0;
    final nameIndex = motelIndex.name?.toIndex() ?? 0;
    final typeIndex = motelIndex.type?.toIndex() ?? 0;
    final roomCodeIndex = motelIndex.roomCode?.toIndex() ?? 0;
    final elevatorIndex = motelIndex.elevator?.toIndex() ?? 0;
    final commissionIndex = motelIndex.commission?.toIndex() ?? 0;
    final electricityIndex = motelIndex.electricity?.toIndex() ?? 0;
    final waterIndex = motelIndex.water?.toIndex() ?? 0;
    final otherIndex = motelIndex.other?.toIndex() ?? 0;
    final carIndex = motelIndex.car?.toIndex() ?? 0;
    final noteIndex = motelIndex.note?.toIndex() ?? 0;
    final geoPointIndex = motelIndex.geoPoint?.toIndex() ?? 0;
    final textureIndex = motelIndex.texture?.toIndex() ?? 0;
    final imagesIndex = motelIndex.images?.toIndex() ?? 0;

    List<Motel> motelList = [];
    for (int i = motelIndex.start! - 1; i < maxRow; i++) {
      final rowData = data[i];
      final motelJson = {
        'number': rowData[numberIndex],
        'street': rowData[streetIndex],
        'ward': rowData[wardIndex],
        'price': rowData[priceIndex],
        'name': rowData[nameIndex],
        'type': rowData[typeIndex],
        'commission': rowData[commissionIndex],
        'geoPoint': rowData[geoPointIndex],
        'roomCode': rowData[roomCodeIndex],
        'elevator': rowData[elevatorIndex],
        'electricity': rowData[electricityIndex],
        'water': rowData[waterIndex],
        'other': rowData[otherIndex],
        'car': rowData[carIndex],
        'note': rowData[noteIndex],
        'texture': rowData[textureIndex],
        'images': rowData[imagesIndex],
      };
      motelList.add(_motelFromJson(motelJson));
    }
    return motelList;
  }

  Motel _motelFromJson(Map<String, dynamic> json) {
    final name = '${json['name']}';
    final number = '${json['number']}';
    final street = '${json['street']}';
    final ward = '${json['ward']}';
    final address = '$number $street, $ward';
    final List<String> keywords =
        number.generateKeywords() +
        street.generateKeywords() +
        ward.generateKeywords() +
        name.generateKeywords();
    final carDeposit = (json['car'] as String).toPrice();
    final images = (json['images'] as String)
        .split(',')
        .map((e) => e.trim().toImageUrl())
        .toList();
    final electricityPrice = (json['electricity'] as String).toPrice();
    final waterPrice = (json['water'] as String).toPrice();
    final otherPrice = (json['other'] as String).toPrice();
    final List<String> extensions = [];
    final List<Map<String, dynamic>> fees = [
      {'name': 'Điện', 'price': electricityPrice, 'unit': 'số'},
      {'name': 'Nước', 'price': waterPrice, 'unit': 'người'},
      {'name': 'Phí dịch vụ', 'price': otherPrice, 'unit': 'người'},
    ];
    if ((json['elevator'] as String).toBoolean()) extensions.add('Thang máy');
    if (carDeposit == 0) {
      extensions.add('Xe');
    } else {
      fees.add({'name': 'Xe', 'price': carDeposit, 'unit': 'người'});
    }

    return Motel(
      id: '',
      name: name,
      address: address,
      price: (json['price'] as String).toPrice(),
      type: json['type'] as String,
      commission: json['commission'] as String,
      geoPoint: (json['geoPoint'] as String).toGeoPoint(),
      roomCode: json['roomCode'] as String,
      extensions: extensions,
      fees: fees,
      note: [json['note'] as String],
      status: RentalStatus.empty,
      images: images,
      marker: images.first,
      thumbnail: images.first,
      texture: json['texture'] as String,
      keywords: keywords,
    );
  }
}
