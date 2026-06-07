abstract class TransactionEvent {}

// Called on app start — load what's already in Hive
class LoadTransactions extends TransactionEvent {}

// Called when user taps sync — re-read SMSes
class SyncTransactions extends TransactionEvent {}

// Called when user changes filter
class FilterTransactions extends TransactionEvent {
  final String? type; // 'debit', 'credit', or null (all)
  final String? bank; // 'pnb', 'icici', or null (all)
  final DateTime? from;
  final DateTime? to;

  FilterTransactions({this.type, this.bank, this.from, this.to});
}
