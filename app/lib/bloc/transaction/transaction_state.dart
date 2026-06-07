import '../../data/models/transaction_hive_model.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionHiveModel> all; // full unfiltered list
  final List<TransactionHiveModel> filtered; // what UI shows
  final double totalDebit;
  final double totalCredit;
  final double? latestBalance;

  TransactionLoaded({
    required this.all,
    required this.filtered,
    required this.totalDebit,
    required this.totalCredit,
    this.latestBalance,
  });
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}
