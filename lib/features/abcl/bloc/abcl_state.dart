part of 'abcl_bloc.dart';

class AbclState extends Equatable {
  final String? motherName, gender, marital, applicantType, employmentType,
      purpose, address, pinCode;

  final bool loader;
  final bool success;
  final String? error;

  const AbclState({
    this.motherName,
    this.gender,
    this.marital,
    this.applicantType,
    this.employmentType,
    this.purpose,
    this.address,
    this.pinCode,
    this.success = false,
    this.loader = false,
    this.error,
  });

  AbclState copyWith({
    String? motherName,
    String? gender,
    String? marital,
    String? applicantType,
    String? employmentType,
    String? purpose,
    String? address,
    String? pinCode,
    bool? loader,
    bool? success,
    String? error,
  }) {
    return AbclState(
      motherName: motherName ?? this.motherName,
      gender: gender ?? this.gender,
      marital: marital ?? this.marital,
      applicantType: applicantType ?? this.applicantType,
      employmentType: employmentType ?? this.employmentType,
      purpose: purpose ?? this.purpose,
      address: address ?? this.address,
      pinCode: pinCode ?? this.pinCode,
      loader: loader ?? this.loader,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        motherName, gender, marital,
        applicantType, employmentType,
        purpose, address, pinCode,
        loader, success, error
      ];
}
