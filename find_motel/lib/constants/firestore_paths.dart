/// Chứa tất cả các đường dẫn Collection và Document cho Cloud Firestore.
class FirestorePaths {
  // Collections
  static const String usersCollection = 'users';
  static const String motelsCollection = 'motels';
  static const String areasCollection = 'areas';
  static const String motelIndexCollection = 'indexs';
  static const String dealsCollection = 'deals';
  static const String optionsCollection = 'options';

  // Document
  static String userDocument(String userId) {
    return '$usersCollection/$userId';
  }

  static String motelDocument(String motelId) {
    return '$motelsCollection/$motelId';
  }

  // Sub-collection
  static String roomFeesSubCollection(String motelId) {
    return '$motelsCollection/$motelId/fees';
  }
}