import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_motel/common/models/area.dart';
import 'package:find_motel/extensions/string_extensions.dart';
import 'package:find_motel/services/catalog/catalog_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/services/motel/motels_service.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:find_motel/constants/firestore_paths.dart';

/// Service that fetches motel data from Firebase Cloud Firestore.
class FirestoreService implements IMotelsService, ICatalogService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Upload a new motel to Firestore.
  Future<({String? id, String? error})> addMotel(Motel motel) async {
    try {
      final docRef = await _firestore
          .collection(FirestorePaths.motelsCollection)
          .add(motel.toMap());
      return (id: docRef.id, error: null);
    } catch (e) {
      return (id: null, error: e.toString());
    }
  }

  /// Fetch motels from Firestore applying both server-side and local filters.
  ///
  /// Filters that can be translated to Firestore queries (e.g. price range,
  /// address keywords, etc.) are applied on the server to reduce network load.
  /// Filters that require client-side data (e.g. distance from the current
  /// location) are applied locally after the documents are downloaded.
  @override
  Future<({List<Motel>? motels, String? error})> getMotels({
    MotelsFilter? filter,
    int limit = 100,
  }) async {
    try {
      // 1. Build the base query.
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestorePaths.motelsCollection)
          .limit(limit);

      // 2. Apply Firestore-side filters if present.
      if (filter?.roomCode != null) {
        query = filter!.roomCode!.applyWhereEqualTo(query, 'room_code');
      }

      // 2. Apply Firestore-side filters if present.
      if (filter?.priceRange != null) {
        query = filter!.priceRange!.apply(query);
      }
      if (filter?.address != null) {
        query = filter!.address!.apply(query);
      }
      // NOTE: Amenities / status arrays cannot be indexed easily without
      // composite indexes. Skip them for now or adjust according to your
      // Firestore index setup.

      // 3. Execute the query.
      final snapshot = await query.get();

      // 4. Map Firestore docs -> Motel models.
      final List<Motel> fetchedMotels = snapshot.docs
          .where((doc) => doc.data().isNotEmpty)
          .map(_motelFromDoc)
          .toList();

      // 5. Apply local-only filters (e.g. distance).
      List<Motel> resultMotels = fetchedMotels;
      if (filter?.distanceRange != null) {
        resultMotels = resultMotels
            .where((motel) => filter!.distanceRange!.checkCondition(motel))
            .toList();
      }

      if (filter?.amenities != null) {
        resultMotels = resultMotels
            .where(
              (motel) => motel.extensions.any(
                (extension) => filter!.amenities!.contains(extension),
              ),
            )
            .toList();
      }

      if (filter?.status != null) {
        resultMotels = resultMotels
            .where((motel) => filter!.status!.contains(motel.status.name))
            .toList();
      }

      return (motels: resultMotels, error: null);
    } catch (e) {
      return (motels: null, error: e.toString());
    }
  }

  // Helper: convert Firestore document to [Motel] model.
  Motel _motelFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final geoPoint = data['geo_point'] as GeoPoint? ?? const GeoPoint(0, 0);

    return Motel(
      id: doc.id,
      address: data['address'] as String? ?? '',
      commission: data['commission']?.toString() ?? '',
      extensions: List<String>.from(data['extensions'] ?? const []),
      fees: List<Map<String, dynamic>>.from(data['fees'] ?? const []),
      geoPoint: LatLng(geoPoint.latitude, geoPoint.longitude),
      name: data['name'] as String? ?? '',
      note: List<String>.from(data['note'] ?? const []),
      price: (data['price'] as num?)?.toDouble() ?? 0,
      roomCode: data['room_code'] as String? ?? '',
      type: data['type'] as String? ?? '',
      status: _statusFromString(data['status'] as String?),
      images: List<String>.from(data['images'] ?? const []),
      marker: data['marker'] as String? ?? '',
      thumbnail: data['thumbnail'] as String? ?? '',
    );
  }

  /// Convert Firestore string status to [RentalStatus] enum.
  RentalStatus _statusFromString(String? value) {
    switch (value) {
      case 'deposit':
        return RentalStatus.deposit;
      case 'rented':
        return RentalStatus.rented;
      default:
        return RentalStatus.empty;
    }
  }

  // ----------------------------
  // Update methods
  // ----------------------------

  @override
  Future<String?> updateMotel(String motelId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(FirestorePaths.motelsCollection)
          .doc(motelId)
          .update(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> updateMotelField(
    String motelId,
    String field,
    dynamic value,
  ) {
    return updateMotel(motelId, {field: value});
  }

  @override
  Future<({List<Province>? provinces, String? error})> fetchProvinces() async {
    try {
      final provinces = await _firestore
          .collection(FirestorePaths.areasCollection)
          .get()
          .then((value) => value.docs.map((e) => _provinceFromDoc(e)).toList());
      return (provinces: provinces, error: null);
    } catch (e) {
      return (provinces: null, error: e.toString());
    }
  }

  Province _provinceFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return Province(
      id: doc.id,
      name: data['name'] as String? ?? '',
      wards: List<String>.from(data['wards'] ?? const []),
    );
  }
}
