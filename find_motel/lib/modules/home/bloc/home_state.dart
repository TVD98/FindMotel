import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/catalog.dart';
import 'package:find_motel/common/models/user_profile.dart';

class HomeState extends Equatable {
  final int selectedIndex;
  final UserProfile? userProfile;
  final Catalog? catalog;

  const HomeState({this.selectedIndex = 0, this.userProfile, this.catalog});

  HomeState copyWith({int? selectedIndex, UserProfile? userProfile, Catalog? catalog}) {
    return HomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      userProfile: userProfile ?? this.userProfile,
      catalog: catalog ?? this.catalog,
    );
  }

  @override
  List<Object?> get props => [selectedIndex, userProfile, catalog];
}
