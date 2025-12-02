part of 'abcl_bloc.dart';

abstract class AbclEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AbclSaveFormEvent extends AbclEvent {
  final String motherName, purpose, address, pinCode;
  final String? gender, marital, applicantType, employmentType;

  AbclSaveFormEvent({
    required this.motherName,
    required this.purpose,
    required this.address,
    required this.pinCode,
    this.gender,
    this.marital,
    this.applicantType,
    this.employmentType,
  });
}

class AbclSubmitConcernEvent extends AbclEvent {}
