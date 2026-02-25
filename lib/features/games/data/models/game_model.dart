import 'package:equatable/equatable.dart';

class GameModel extends Equatable {
  final String id;
  final String title;
  final String category;
  final double? progress; // 0.0 to 1.0, null if locked
  final bool isLocked;
  final String emoji;

  const GameModel({
    required this.id,
    required this.title,
    required this.category,
    this.progress,
    this.isLocked = false,
    required this.emoji,
  });

  @override
  List<Object?> get props => [id, title, category, progress, isLocked, emoji];
}
