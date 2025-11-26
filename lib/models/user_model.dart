import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String phoneNumber;
  final String role; // 'customer' or 'provider'
  final String name;
  final String email;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Provider-specific fields
  final List<String>? skills;
  final double? rating;
  final int? completedJobs;
  final bool? isAvailable;
  final String? bio;
  final List<String>? verifications;

  // Customer-specific fields
  final String? address;
  final List<String>? emergencyContacts;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    required this.role,
    this.name = '',
    this.email = '',
    this.photoURL,
    this.createdAt,
    this.updatedAt,
    this.skills,
    this.rating,
    this.completedJobs,
    this.isAvailable,
    this.bio,
    this.verifications,
    this.address,
    this.emergencyContacts,
  });

  // Factory constructor from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      phoneNumber: data['phoneNumber'] ?? '',
      role: data['role'] ?? 'customer',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      skills: (data['skills'] as List<dynamic>?)?.cast<String>(),
      rating: (data['rating'] as num?)?.toDouble(),
      completedJobs: data['completedJobs'] as int?,
      isAvailable: data['isAvailable'] as bool?,
      bio: data['bio'] as String?,
      verifications: (data['verifications'] as List<dynamic>?)?.cast<String>(),
      address: data['address'] as String?,
      emergencyContacts: (data['emergencyContacts'] as List<dynamic>?)
          ?.cast<String>(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> data = {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'role': role,
      'name': name,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (photoURL != null) data['photoURL'] = photoURL;
    if (createdAt != null) data['createdAt'] = Timestamp.fromDate(createdAt!);

    // Provider fields
    if (skills != null) data['skills'] = skills;
    if (rating != null) data['rating'] = rating;
    if (completedJobs != null) data['completedJobs'] = completedJobs;
    if (isAvailable != null) data['isAvailable'] = isAvailable;
    if (bio != null) data['bio'] = bio;
    if (verifications != null) data['verifications'] = verifications;

    // Customer fields
    if (address != null) data['address'] = address;
    if (emergencyContacts != null)
      data['emergencyContacts'] = emergencyContacts;

    return data;
  }

  // Copy with method for immutability
  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? role,
    String? name,
    String? email,
    String? photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? skills,
    double? rating,
    int? completedJobs,
    bool? isAvailable,
    String? bio,
    List<String>? verifications,
    String? address,
    List<String>? emergencyContacts,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      skills: skills ?? this.skills,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      isAvailable: isAvailable ?? this.isAvailable,
      bio: bio ?? this.bio,
      verifications: verifications ?? this.verifications,
      address: address ?? this.address,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

  // Check if user is a customer
  bool get isCustomer => role == 'customer';

  // Check if user is a provider
  bool get isProvider => role == 'provider';

  @override
  String toString() {
    return 'UserModel(uid: $uid, phoneNumber: $phoneNumber, role: $role, name: $name)';
  }
}
