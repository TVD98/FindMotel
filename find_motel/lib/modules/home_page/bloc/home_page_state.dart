import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/common/models/user_profile.dart';

class HomePageState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<Motel>? motels;
  final UserProfile? userProfile;

  const HomePageState({
    this.isLoading = false,
    this.isLoadingMore = false,
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
    bool? isLoadingMore,
    String? errorMessage,
    List<Motel>? motels,
  }) {
    return HomePageState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      motels: motels ?? this.motels,
    );
  }

  @override
  List<Object?> get props => [isLoading, isLoadingMore, errorMessage, motels];

  // Helper getters
  bool get hasError => errorMessage != null;
  bool get hasMotels => motels != null && motels!.isNotEmpty;
  bool get hasUserProfile => userProfile != null;
}
