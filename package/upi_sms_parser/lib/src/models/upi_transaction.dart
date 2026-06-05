enum Bank { pnb, icici, unknown }

enum TransactionType { debit, credit }

class UpiTransaction {
  final double amount;
  final TransactionType type;
  final Bank bank;
  final String? payee; // who you paid or received from
  final String? accountLast4; // e.g. "0298" from X0298
  final double? balance; // available balance after transaction
  final DateTime timestamp;
  final String rawSms;

  const UpiTransaction({
    required this.amount,
    required this.type,
    required this.bank,
    this.payee,
    this.accountLast4,
    this.balance,
    required this.timestamp,
    required this.rawSms,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'type': type.name,
        'bank': bank.name,
        'payee': payee,
        'accountLast4': accountLast4,
        'balance': balance,
        'timestamp': timestamp.toIso8601String(),
        'rawSms': rawSms,
      };

  factory UpiTransaction.fromJson(Map<String, dynamic> json) => UpiTransaction(
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.values.byName(json['type']),
        bank: Bank.values.byName(json['bank']),
        payee: json['payee'],
        accountLast4: json['accountLast4'],
        balance: json['balance'] != null
            ? (json['balance'] as num).toDouble()
            : null,
        timestamp: DateTime.parse(json['timestamp']),
        rawSms: json['rawSms'],
      );
}
