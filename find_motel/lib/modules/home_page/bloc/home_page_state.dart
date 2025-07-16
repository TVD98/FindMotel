import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/common/models/user_profile.dart';

class HomePageState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<Motel>? motels;
  final UserProfile? userProfile;

  const HomePageState({
    this.isLoading = false,
    this.errorMessage,
    this.motels,
    this.userProfile,
  });

  // Factory constructors for different states
  factory HomePageState.initial() => const HomePageState();

  factory HomePageState.loading() => const HomePageState(isLoading: true);

  factory HomePageState.error(String message) => 
      HomePageState(errorMessage: message);

  // Copy with method
  HomePageState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Motel>? motels,
    UserProfile? userProfile,
  }) {
    return HomePageState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      motels: motels ?? this.motels,
      userProfile: userProfile ?? this.userProfile,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, motels, userProfile];

  // Helper getters
  bool get hasError => errorMessage != null;
  bool get hasMotels => motels != null && motels!.isNotEmpty;
  bool get hasUserProfile => userProfile != null;
}
