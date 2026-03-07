import 'package:equatable/equatable.dart';

enum SettingStatus { initial, loading, success, error }

class SettingState extends Equatable {
  final SettingStatus status;
  final String? error;
  final bool isLoggedOut;

  const SettingState({
    this.status = SettingStatus.initial,
    this.error,
    this.isLoggedOut = false,
  });

  SettingState copyWith({
    SettingStatus? status,
    String? error,
    bool? isLoggedOut,
  }) {
    return SettingState(
      status: status ?? this.status,
      error: error,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
    );
  }

  @override
  List<Object?> get props => [status, error, isLoggedOut];
}
