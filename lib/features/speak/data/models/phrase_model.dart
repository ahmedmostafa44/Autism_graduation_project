import 'package:equatable/equatable.dart';

class PhraseModel extends Equatable {
  final String id;
  final String text;
  final String emoji;
  final String category;
  final bool isFavorite;

  const PhraseModel({
    required this.id,
    required this.text,
    required this.emoji,
    required this.category,
    this.isFavorite = false,
  });

  PhraseModel copyWith({bool? isFavorite}) {
    return PhraseModel(
      id: id,
      text: text,
      emoji: emoji,
      category: category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, text, emoji, category, isFavorite];
}
