import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_hive_model.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repo;

  TransactionBloc(this._repo) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoad);
    on<SyncTransactions>(_onSync);
    on<FilterTransactions>(_onFilter);
  }

  Future<void> _onLoad(LoadTransactions event, Emitter emit) async {
    emit(TransactionLoading());
    try {
      final transactions = _repo.getStored();
      emit(_buildLoaded(transactions, transactions));
    } catch (e) {
      emit(TransactionError('Failed to load transactions'));
    }
  }

  Future<void> _onSync(SyncTransactions event, Emitter emit) async {
    emit(TransactionLoading());
    try {
      final transactions = await _repo.syncFromSms();
      emit(_buildLoaded(transactions, transactions));
    } catch (e) {
      emit(TransactionError('Failed to sync SMS: ${e.toString()}'));
    }
  }

  Future<void> _onFilter(FilterTransactions event, Emitter emit) async {
    final current = state;
    if (current is! TransactionLoaded) return;

    var filtered = current.all.where((t) {
      if (event.type != null && t.type != event.type) return false;
      if (event.bank != null && t.bank != event.bank) return false;
      if (event.from != null && t.timestamp.isBefore(event.from!)) return false;
      if (event.to != null && t.timestamp.isAfter(event.to!)) return false;
      return true;
    }).toList();

    emit(_buildLoaded(current.all, filtered));
  }

  TransactionLoaded _buildLoaded(
    List<TransactionHiveModel> all,
    List<TransactionHiveModel> filtered,
  ) {
    final debits = all.where((t) => t.type == 'debit');
    final credits = all.where((t) => t.type == 'credit');

    // Latest balance = most recent transaction that has a balance field
    final withBalance = all.where((t) => t.balance != null);
    final latestBalance = withBalance.isNotEmpty
        ? withBalance.first.balance
        : null;

    return TransactionLoaded(
      all: all,
      filtered: filtered,
      totalDebit: debits.fold(0, (sum, t) => sum + t.amount),
      totalCredit: credits.fold(0, (sum, t) => sum + t.amount),
      latestBalance: latestBalance,
    );
  }
}
