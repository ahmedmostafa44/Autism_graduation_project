import 'package:equatable/equatable.dart';

enum ResourceType { article, document, guide, resource }

class ResourceModel extends Equatable {
  final String id;
  final String title;
  final String author;
  final String tag;
  final ResourceType type;
  final bool isLiked;

  const ResourceModel({
    required this.id,
    required this.title,
    required this.author,
    required this.tag,
    required this.type,
    this.isLiked = false,
  });

  ResourceModel copyWith({bool? isLiked}) => ResourceModel(
        id: id,
        title: title,
        author: author,
        tag: tag,
        type: type,
        isLiked: isLiked ?? this.isLiked,
      );

  @override
  List<Object?> get props => [id, title, author, tag, type, isLiked];
}
