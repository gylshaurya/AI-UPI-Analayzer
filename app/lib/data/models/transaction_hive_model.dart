import 'package:hive/hive.dart';

part 'transaction_hive_model.g.dart';

@HiveType(typeId: 0)
class TransactionHiveModel extends HiveObject {
  @HiveField(0)
  final double amount;

  @HiveField(1)
  final String type; // 'debit' or 'credit'

  @HiveField(2)
  final String bank; // 'pnb' or 'icici'

  @HiveField(3)
  final String? payee;

  @HiveField(4)
  final String? accountLast4;

  @HiveField(5)
  final double? balance;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final String rawSms;

  TransactionHiveModel({
    required this.amount,
    required this.type,
    required this.bank,
    this.payee,
    this.accountLast4,
    this.balance,
    required this.timestamp,
    required this.rawSms,
  });
}
