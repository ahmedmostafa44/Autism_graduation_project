import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String parentName;
  final String childName;
  final int childAge;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastActive;

  const UserModel({
    required this.uid,
    required this.email,
    required this.parentName,
    required this.childName,
    required this.childAge,
    this.photoUrl,
    required this.createdAt,
    this.lastActive,
  });

  // ── Firestore serialization ──────────────────────────────────────────────

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String,
      parentName: data['parentName'] as String,
      childName: data['childName'] as String,
      childAge: data['childAge'] as int? ?? 6,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: data['lastActive'] != null
          ? (data['lastActive'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'parentName': parentName,
        'childName': childName,
        'childAge': childAge,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastActive': FieldValue.serverTimestamp(),
      };

  // ── Helpers ──────────────────────────────────────────────────────────────

  UserModel copyWith({
    String? uid,
    String? email,
    String? parentName,
    String? childName,
    int? childAge,
    String? photoUrl,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        parentName: parentName ?? this.parentName,
        childName: childName ?? this.childName,
        childAge: childAge ?? this.childAge,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt,
        lastActive: lastActive,
      );
}
