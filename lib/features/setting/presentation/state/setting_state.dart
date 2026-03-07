import 'package:equatable/equatable.dart';

enum SettingStatus { initial, loading, success, error }

class SettingState extends Equatable {
  final SettingStatus status;
  final String? error;
  final bool isLoggedOut;
  final String username;
  final String? profileImage;
  final String email;

  const SettingState({
    this.status = SettingStatus.initial,
    this.error,
    this.isLoggedOut = false,
    this.username = '',
    this.profileImage,
    this.email = '',
  });

  SettingState copyWith({
    SettingStatus? status,
    String? error,
    bool? isLoggedOut,
    String? username,
    String? profileImage,
    String? email,
  }) {
    return SettingState(
      status: status ?? this.status,
      error: error,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [status, error, isLoggedOut, username, profileImage, email];
}
