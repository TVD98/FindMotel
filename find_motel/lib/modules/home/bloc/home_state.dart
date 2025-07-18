import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/user_profile.dart';

class HomeState extends Equatable {
  final int selectedIndex;
  final UserProfile? userProfile;

  const HomeState({this.selectedIndex = 0, this.userProfile});

  HomeState copyWith({int? selectedIndex, UserProfile? userProfile}) {
    return HomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      userProfile: userProfile ?? this.userProfile,
    );
  }

  @override
  List<Object?> get props => [selectedIndex, userProfile];
}
