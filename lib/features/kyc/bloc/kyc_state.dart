import 'package:equatable/equatable.dart';

abstract class KycState extends Equatable {
  @override
  List<Object> get props => [];
}

class KycInitial extends KycState {}

class KycLoading extends KycState {}

class KycSuccess extends KycState {
  final String kycUrl;

  KycSuccess(this.kycUrl);

  @override
  List<Object> get props => [kycUrl];
}

class KycError extends KycState {
  final String message;

  KycError(this.message);

  @override
  List<Object> get props => [message];
}