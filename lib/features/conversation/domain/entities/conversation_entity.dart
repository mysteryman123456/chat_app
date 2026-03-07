import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String type;
  final String createdBy;
  final String? groupName;
  final List<String> participants;

  const ConversationEntity({
    required this.id,
    required this.type,
    required this.createdBy,
    this.groupName,
    required this.participants,
  });

  @override
  List<Object?> get props => [id, type, createdBy, groupName, participants];
}
