import 'package:find_motel/common/models/user_profile.dart';

abstract class IUserDataService {
  Future<({UserProfile? userProfile, String? error})> getUserProfileByEmail(String email);
}
