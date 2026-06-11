import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bank_upi_sms_parser/bank_upi_sms_parser.dart';
import '../models/transaction_hive_model.dart';

class TransactionRepository {
  static const _boxName = 'transactions';

  List<TransactionHiveModel> getStored() {
    final box = Hive.box<TransactionHiveModel>(_boxName);
    return box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<List<TransactionHiveModel>> syncFromSms() async {
    final box = Hive.box<TransactionHiveModel>(_boxName);
    final query = SmsQuery();

    final messages = await query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 200,
    );

    int added = 0;
    for (final msg in messages) {
      final body = msg.body ?? '';
      final sender = msg.sender ?? '';

      final alreadyExists = box.values.any((t) => t.rawSms == body);
      if (alreadyExists) continue;

      final tx = UpiSmsParser.parse(body, sender: sender);
      if (tx == null) continue;

      await box.add(
        TransactionHiveModel(
          amount: tx.amount,
          type: tx.type.name,
          bank: tx.bank.name,
          payee: tx.payee,
          accountLast4: tx.accountLast4,
          balance: tx.balance,
          timestamp: tx.timestamp,
          rawSms: body,
        ),
      );
      added++;
    }

    return getStored();
  }

  Future<void> clearAll() async {
    await Hive.box<TransactionHiveModel>(_boxName).clear();
  }
}
