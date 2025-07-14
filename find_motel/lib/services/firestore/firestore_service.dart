import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_motel/common/models/area.dart';
import 'package:find_motel/extensions/string_extensions.dart';
import 'package:find_motel/services/catalog/catalog_service.dart';
import 'package:find_motel/common/models/motel_index.dart';
import 'package:find_motel/services/user_data/user_data_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/services/motel/motels_service.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:find_motel/constants/firestore_paths.dart';
import 'package:find_motel/common/models/user_profile.dart';
import 'package:find_motel/common/models/deal.dart';
import 'package:find_motel/services/customer/customer_service.dart';

/// Service that fetches motel data from Firebase Cloud Firestore.
class FirestoreService
    implements
        IMotelsService,
        ICatalogService,
        IUserDataService,
        ICustomerService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Upload a new motel to Firestore.
  @override
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

      // 3. Execute the query with GetOptions to force server fetch.
      final snapshot = await query.get(const GetOptions(source: Source.server));

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
      texture: data['texture'] as String? ?? '',
      keywords: List<String>.from(data['keywords'] ?? const [])
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

  @override
  Future<({UserProfile? userProfile, String? error})> getUserProfileByEmail(
    String email,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        return (userProfile: null, error: 'User not found');
      }
      final doc = snapshot.docs.first;
      return (userProfile: _userProfileFromDoc(doc), error: null);
    } catch (e) {
      return (userProfile: null, error: e.toString());
    }
  }

  UserProfile _userProfileFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfile(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      avatar: data['avatar'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.sale,
      ),
    );
  }

  @override
  Future<({MotelIndex? motelIndex, String? error})> getMotelIndex() async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.motelIndexCollection)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        return (motelIndex: null, error: 'Motel index not found');
      }
      final doc = snapshot.docs.first;
      return (motelIndex: MotelIndex.fromJson(doc.data()), error: null);
    } catch (e) {
      return (motelIndex: null, error: e.toString());
    }
  }

  @override
  Future<({List<UserProfile>? users, String? error})> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.usersCollection)
          .limit(100)
          .get();
      return (
        users: querySnapshot.docs
            .map((doc) => _userProfileFromDoc(doc))
            .toList(),
        error: null,
      );
    } catch (e) {
      return (users: null, error: e.toString());
    }
  }

  @override
  Future<bool> updateUserRole({
    required String userId,
    required UserRole newRole,
  }) async {
    try {
      await _firestore
          .collection(FirestorePaths.usersCollection)
          .doc(userId)
          .update({'role': newRole.name});
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(FirestorePaths.usersCollection)
          .doc(userId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ICustomerService implementation
  @override
  Future<(List<Deal>?, String?)> fetchDeals({String? saleId}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestorePaths.dealsCollection)
          .orderBy('schedule', descending: false);
      if (saleId != null && saleId.isNotEmpty) {
        query = query.where('saleId', isEqualTo: saleId);
      }
      final snapshot = await query.get();
      final customers = snapshot.docs.map((doc) {
        final data = doc.data();
        return Deal(
          id: doc.id,
          name: data['name'] ?? '',
          phone: data['phone'] ?? '',
          price: data['price'] as double,
          schedule: (data['schedule'] as Timestamp).toDate(),
          saleId: data['saleId'] ?? '',
          motelId: data['motelId'] ?? '',
          motelName: data['motelName'] ?? '',
        );
      }).toList();
      return (customers, null);
    } catch (e) {
      return (null, e.toString());
    }
  }

  @override
  Future<(bool, String?)> addDeal(Deal customer) async {
    try {
      await _firestore.collection(FirestorePaths.dealsCollection).add({
        'name': customer.name,
        'phone': customer.phone,
        'price': customer.price,
        'schedule': Timestamp.fromDate(customer.schedule),
        'saleId': customer.saleId,
        'motelId': customer.motelId,
        'motelName': customer.motelName,
      });
      return (true, null);
    } catch (e) {
      return (false, e.toString());
    }
  }

  @override
  Future<(bool, String?)> deleteDeal(String id) async {
    try {
      await _firestore
          .collection(FirestorePaths.dealsCollection)
          .doc(id)
          .delete();
      return (true, null);
    } catch (e) {
      return (false, e.toString());
    }
  }

  @override
  Future<(bool, String?)> updateDeal(Deal customer) async {
    try {
      await _firestore
          .collection(FirestorePaths.dealsCollection)
          .doc(customer.id)
          .update({
            'name': customer.name,
            'phone': customer.phone,
            'price': customer.price,
            'schedule': customer.schedule,
            'saleId': customer.saleId,
            'motelId': customer.motelId,
            'motelName': customer.motelName,
          });
      return (true, null);
    } catch (e) {
      return (false, e.toString());
    }
  }

  @override
  Future<String?> deleteMotel(String motelId) async {
    try {
      await _firestore
          .collection(FirestorePaths.motelsCollection)
          .doc(motelId)
          .delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<({Motel? motel, String? error})> getMotelById(String motelId) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.motelsCollection)
          .doc(motelId)
          .get();
      if (!doc.exists) {
        return (motel: null, error: 'Motel not found');
      }
      return (motel: _motelFromDoc(doc), error: null);
    } catch (e) {
      return (motel: null, error: e.toString());
    }
  }
}
