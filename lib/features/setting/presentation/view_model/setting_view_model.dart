import 'package:chat_app/core/services/storage/user_session_service.dart';
import 'package:chat_app/features/auth/data/repository/auth_repository.dart';
import 'package:chat_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chat_app/features/setting/presentation/state/setting_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/upload_profile_image_usecase.dart';
import 'dart:io';

final settingViewModelProvider = NotifierProvider<SettingViewModel, SettingState>(SettingViewModel.new);

class SettingViewModel extends Notifier<SettingState> {
  late final UpdateProfileUseCase _updateProfileUseCase;
  late final UpdatePasswordUseCase _updatePasswordUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final UploadProfileImageUseCase _uploadProfileImageUseCase;
  late final UserSessionService _userSessionService;

  @override
  SettingState build() {
    final authRepository = ref.read(authRepositoryProvider);
    _updateProfileUseCase = UpdateProfileUseCase(repository: authRepository);
    _updatePasswordUseCase = UpdatePasswordUseCase(repository: authRepository);
    _logoutUseCase = LogoutUseCase(repository: authRepository);
    _uploadProfileImageUseCase = UploadProfileImageUseCase(repository: authRepository);
    _userSessionService = ref.read(userSessionServiceProvider);
    
    return SettingState(
      username: _userSessionService.getCurrentUsername() ?? 'User',
      email: _userSessionService.getCurrentUserEmail() ?? '',
      profileImage: _userSessionService.getCurrentUserProfilePicture(),
    );
  }

  void refreshUserInfo() {
    state = state.copyWith(
      username: _userSessionService.getCurrentUsername() ?? 'User',
      email: _userSessionService.getCurrentUserEmail() ?? '',
      profileImage: _userSessionService.getCurrentUserProfilePicture(),
    );
  }

  Future<bool> updateProfile(String username, {File? profileImage}) async {
    state = state.copyWith(status: SettingStatus.loading);
    final userId = _userSessionService.getCurrentUserId() ?? '';
    
    String? profileImageUrl;
    if (profileImage != null) {
      final uploadResult = await _uploadProfileImageUseCase(profileImage);
      uploadResult.fold(
        (failure) {
          state = state.copyWith(status: SettingStatus.error, error: failure.message);
        },
        (url) {
          profileImageUrl = url;
        },
      );
      if (profileImageUrl == null && profileImage != null && state.status == SettingStatus.error) return false;
    }
    
    final payload = <String, dynamic>{
      'username': username,
    };
    if (profileImageUrl != null) {
      payload['profile_image'] = profileImageUrl;
    }

    final result = await _updateProfileUseCase(userId, payload);

    return result.fold(
      (failure) {
        state = state.copyWith(status: SettingStatus.error, error: failure.message);
        return false;
      },
      (success) {
        // Now that the session is updated in RemoteDataSource, refresh our state info
        refreshUserInfo();
        state = state.copyWith(status: SettingStatus.success, error: null);
        return true;
      },
    );
  }

  Future<bool> updatePassword(String oldPassword, String newPassword, String confirmPassword) async {
    state = state.copyWith(status: SettingStatus.loading);
    
    final result = await _updatePasswordUseCase(oldPassword, newPassword, confirmPassword);

    return result.fold(
      (failure) {
        state = state.copyWith(status: SettingStatus.error, error: failure.message);
        return false;
      },
      (success) async {
        await logout();
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: SettingStatus.loading);
    
    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(status: SettingStatus.error, error: failure.message);
      },
      (success) {
        state = state.copyWith(status: SettingStatus.success, isLoggedOut: true);
      },
    );
  }
}
