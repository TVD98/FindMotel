import 'package:cloud_functions/cloud_functions.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/extensions/string_extensions.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/modules/import_motels/bloc/import_motels_event.dart';
import 'package:find_motel/modules/import_motels/bloc/import_motels_state.dart';
import 'package:find_motel/utilities/excel_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:find_motel/services/motel/motels_service.dart';

class ImportMotelsBloc extends Bloc<ImportMotelsEvent, ImportMotelsState> {
  final IMotelsService _motelsService;
  Map<String, List<String>> imagesList = {};
  List<Future<void>> imageFutures = [];

  ImportMotelsBloc({IMotelsService? motelsService})
    : _motelsService = motelsService ?? FirestoreService(),
      super(const ImportMotelsState()) {
    on<HandleFileEvent>((event, emit) {
      List<ExcelData> data = event.data;
      List<ImportedMotelList> sheetList = [];
      List<Motel> existingMotels = [];
      for (final sheet in data) {
        final motels = _parseMotels(sheet.data);
        existingMotels.addAll(motels);
        if (motels.isEmpty) continue;
        sheetList.add(
          ImportedMotelList(
            sheetName: sheet.sheetName,
            motels: _reorganizeMotelsById(motels, existingMotels),
          ),
        );
      }
      bool isCanImport = sheetList.every(
        (e) => e.motels.every((e) => e.isValid),
      );
      emit(state.copyWith(sheetList: sheetList, isCanImport: isCanImport));
    });

    on<FilterDuplicateEvent>((event, emit) {
      final List<ImportedMotelList> filteredMotels =
          state.sheetList
              ?.map(
                (sheet) => ImportedMotelList(
                  sheetName: sheet.sheetName,
                  motels: sheet.motels.where((motel) => motel.isValid).toList(),
                ),
              )
              .where((sheet) => sheet.motels.isNotEmpty)
              .toList() ??
          [];
      emit(state.copyWith(sheetList: filteredMotels, isCanImport: true));
    });

    on<SaveMotelsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      await Future.wait(imageFutures);
      try {
        for (final motel in event.motels) {
          List<String> images = imagesList[motel.roomCode] ?? [];
          String thumbnail = images.isEmpty ? '' : images.first;
          String marker = images.isEmpty ? '' : images.first;
          final result = await _motelsService.addMotel(
            motel.copyWith(
              images: images,
              thumbnail: thumbnail,
              marker: marker,
            ),
          );
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
    final districtIndex = motelIndex.district?.toIndex() ?? 0;
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
    final phoneNumbersIndex = motelIndex.phoneNumbers?.toIndex() ?? 0;

    List<Motel> motelList = [];
    for (int i = motelIndex.start! - 1; i < maxRow; i++) {
      final rowData = data[i];
      final motelJson = {
        'number': rowData[numberIndex],
        'street': rowData[streetIndex],
        'ward': rowData[wardIndex],
        'price': rowData[priceIndex],
        'district': rowData[districtIndex],
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
        'phone_numbers': rowData[phoneNumbersIndex],
      };
      final motel = _motelFromJson(motelJson);
      if (motel != null) {
        motelList.add(motel);
        imageFutures.add(_fetchDriveImagesAsync(motel, rowData[imagesIndex]));
      }
    }
    return motelList;
  }

  Motel? _motelFromJson(Map<String, dynamic> json) {
    final roomCode = '${json['roomCode']}';
    if (roomCode.isEmpty) return null;

    final district = '${json['district']}';
    final number = '${json['number']}';
    final street = '${json['street']}';
    final ward = 'phường ${json['ward']}';
    final address = '$number $street, $ward, $district';
    final carDeposit = json['car'];
    final images = (json['images'] as String)
        .split(',')
        .map((e) => e.trim())
        .toList();
    final phoneNumbers = (json['phone_numbers'] as String)
        .extractPhoneNumbers();
    final electricityPrice = (json['electricity'] as String).toPrice();
    final waterPrice = (json['water'] as String).toPrice();
    final otherPrice = (json['other'] as String).toPrice();
    final List<String> extensions = [];
    final List<Fee> fees = [
      Fee(name: 'Điện', price: electricityPrice, unit: 'số'),
      Fee(name: 'Nước', price: waterPrice, unit: 'người'),
      Fee(name: 'Phí dịch vụ', price: otherPrice, unit: 'người'),
    ];
    if ((json['elevator'] as String).toBoolean()) extensions.add('Thang máy');

    return Motel(
      id: '',
      name: '',
      address: address,
      price: (json['price'] as String).toPrice(),
      type: json['type'] as String,
      commission: json['commission'] as String,
      car: carDeposit,
      geoPoint: (json['geoPoint'] as String).toGeoPoint(),
      roomCode: roomCode,
      extensions: extensions,
      fees: fees,
      note: [json['note'] as String],
      status: RentalStatus.empty,
      images: images,
      marker: images.first,
      thumbnail: images.first,
      texture: json['texture'] as String,
      phoneNumbers: phoneNumbers,
    );
  }

  List<ImportedMotel> _reorganizeMotelsById(
    List<Motel> motels,
    List<Motel> existingMotels,
  ) {
    if (motels.isEmpty) {
      return [];
    }

    final Map<String, int> idCounts = {};
    for (final motel in existingMotels) {
      final id = '${motel.roomCode} - ${motel.address}';
      idCounts[id] = (idCounts[id] ?? 0) + 1;
    }

    final Set<String> duplicateIds = idCounts.entries
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key)
        .toSet();

    final List<ImportedMotel> duplicates = [];
    final List<ImportedMotel> nonDuplicates = [];

    for (final motel in motels) {
      final id = '${motel.roomCode} - ${motel.address}';
      if (duplicateIds.contains(id)) {
        duplicates.add(ImportedMotel(motel: motel, isValid: false));
      } else {
        nonDuplicates.add(ImportedMotel(motel: motel, isValid: true));
      }
    }

    duplicates.sort((a, b) => a.motel.roomCode.compareTo(b.motel.roomCode));

    return [...duplicates, ...nonDuplicates];
  }

  Future<List<String>> _processImagesCell(String imagesCell) async {
    final links = imagesCell.split(',').map((e) => e.trim()).toList();
    List<String> finalUrls = [];

    for (var link in links) {
      if (_isDriveFolderLink(link)) {
        final folderId = _extractFolderId(link);
        final driveImages = await getDriveImages(folderId);
        finalUrls.addAll(
          driveImages.map((e) => e['thumbnailLink'] ?? e['webViewLink']),
        );
      } else {
        finalUrls.add(link);
      }
    }

    return finalUrls;
  }

  Future<void> _fetchDriveImagesAsync(Motel motel, String imagesCell) async {
    final links = imagesCell.split(',').map((e) => e.trim()).toList();
    for (var link in links) {
      if (_isDriveFolderLink(link)) {
        try {
          final folderId = _extractFolderId(link);
          final driveImages = await getDriveImages(
            folderId,
          ); // gọi Firebase function
          final List<String> urls = driveImages
              .whereType<Map<String, dynamic>>()
              .map((e) {
                if (e['thumbnailLink'] != null) {
                  return e['thumbnailLink'] as String;
                }
                if (e['webViewLink'] != null) return e['webViewLink'] as String;
                return null;
              })
              .whereType<String>()
              .toList();
          imagesList[motel.roomCode] = urls;
        } catch (_) {}
      }
    }
  }

  bool _isDriveFolderLink(String url) {
    return url.contains('drive.google.com/drive/folders/');
  }

  String _extractFolderId(String url) {
    final regex = RegExp(r'folders/([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    throw Exception('Invalid Drive folder link: $url');
  }

  Future<List<Map<String, dynamic>>> getDriveImages(String folderId) async {
    final functions = FirebaseFunctions.instance;
    final result = await functions.httpsCallable('getDriveImages').call({
      'folderId': folderId,
    });

    final List<dynamic> files = result.data;
    return files.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
