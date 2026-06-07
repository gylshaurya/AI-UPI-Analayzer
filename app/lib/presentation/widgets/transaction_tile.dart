import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_hive_model.dart';
import 'transaction_detail_sheet.dart';

class TransactionTile extends StatelessWidget {
  final TransactionHiveModel tx;

  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isDebit = tx.type == 'debit';
    final color = isDebit ? Colors.red : Colors.green;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(
          isDebit ? Icons.arrow_upward : Icons.arrow_downward,
          color: color,
          size: 18,
        ),
      ),
      title: Text(tx.payee ?? 'Unknown'),
      subtitle: Text(DateFormat('dd MMM, hh:mm a').format(tx.timestamp)),
      trailing: Text(
        '${isDebit ? '-' : '+'}₹${tx.amount.toStringAsFixed(2)}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => TransactionDetailSheet(tx: tx),
        );
      },
    );
  }
}
