import 'package:find_motel/common/models/motel_index.dart';
import 'package:find_motel/common/models/user_profile.dart';

abstract class IUserDataService {
  Future<({UserProfile? userProfile, String? error})> getUserProfileByEmail(String email);
  Future<({MotelIndex? motelIndex, String? error})> getMotelIndex();
}
