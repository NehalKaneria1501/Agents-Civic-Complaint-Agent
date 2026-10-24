import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_state.dart';

// ==========================================
// CUBIT: CITIZEN PROFILE CUBIT
// Manages citizen profile credentials, ward preferences & avatar photo
// ==========================================

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  void updateProfile({
    String? name,
    String? phone,
    String? ward,
    String? address,
    String? email,
  }) {
    emit(state.copyWith(
      name: name,
      phone: phone,
      ward: ward,
      address: address,
      email: email,
    ));
  }

  void updatePhoto(String photoPath) {
    emit(state.copyWith(photoPath: photoPath));
  }

  void removePhoto() {
    emit(state.copyWith(clearPhoto: true));
  }
}
