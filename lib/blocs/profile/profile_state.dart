import 'package:equatable/equatable.dart';

// ==========================================
// BLOC STATE: CITIZEN PROFILE
// ==========================================

class ProfileState extends Equatable {
  final String name;
  final String ward;
  final String phone;
  final String email;
  final String address;
  final String? photoPath;
  final int trustScore;

  const ProfileState({
    this.name = 'Nehal Kaneria',
    this.ward = 'Ward 4 (Navrangpura/Central District, AMC)',
    this.phone = '+91 98765 43210',
    this.email = 'nehal.kaneria@ahmedabadcity.gov.in',
    this.address = 'Navrangpura CG Road & Vastrapur',
    this.photoPath,
    this.trustScore = 4,
  });

  ProfileState copyWith({
    String? name,
    String? ward,
    String? phone,
    String? email,
    String? address,
    String? photoPath,
    bool clearPhoto = false,
    int? trustScore,
  }) {
    return ProfileState(
      name: name ?? this.name,
      ward: ward ?? this.ward,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      trustScore: trustScore ?? this.trustScore,
    );
  }

  @override
  List<Object?> get props => [name, ward, phone, email, address, photoPath, trustScore];
}
