import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/core/utils/enums.dart';

part 'event_de_pledge.dart';
part 'state_de_pledge.dart';

class DePledgeBloc extends Bloc<DePledgeEvent, DePledgeState> {
  DePledgeBloc() : super(const DePledgeState()) {}
}
