import 'package:find_motel/common/models/motel_index.dart';
import 'package:find_motel/common/models/user_profile.dart';

abstract class IUserDataService {
  Future<({UserProfile? userProfile, String? error})> getUserProfileByEmail(String email);
  Future<({MotelIndex? motelIndex, String? error})> getMotelIndex();
  Future<({List<UserProfile>? users, String? error})> getAllUsers();

  /// Returns `true` if the update was successful, `false` otherwise.
  Future<bool> updateUserRole({
    required String userId,
    required UserRole newRole,
  });

  /// Delete a user account.
  /// 
  /// Returns `true` if the deletion was successful, `false` otherwise.
  Future<bool> deleteUser(String userId);

  Future<bool> updateUserProfile({
    required String userId,
    required String name,
    required String avatar
  });
}
