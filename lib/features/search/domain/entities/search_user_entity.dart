import 'package:equatable/equatable.dart';

class SearchUserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? profileImage;

  const SearchUserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.profileImage,
  });

  @override
  List<Object?> get props => [id, username, email, profileImage];
}
