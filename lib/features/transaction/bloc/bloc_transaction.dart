import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/core/utils/enums.dart';

part 'event_transaction.dart';
part 'state_transaction.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(const TransactionState()) {}
}
