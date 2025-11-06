import 'package:equatable/equatable.dart';

abstract class KycEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class StartKycEvent extends KycEvent {
  final String reqId;
  final String lenderCode;
  final double latitude;
  final double longitude;

  StartKycEvent({
    required this.reqId,
    required this.lenderCode,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [reqId, lenderCode, latitude, longitude];
}