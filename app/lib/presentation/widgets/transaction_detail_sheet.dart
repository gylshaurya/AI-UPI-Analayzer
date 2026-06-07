import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_hive_model.dart';

class TransactionDetailSheet extends StatelessWidget {
  final TransactionHiveModel tx;

  const TransactionDetailSheet({super.key, required this.tx});

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDebit = tx.type == 'debit';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${isDebit ? '-' : '+'}₹${tx.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: isDebit ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _row('Type', isDebit ? 'Debit' : 'Credit'),
          _row('To/From', tx.payee ?? 'Unknown'),
          _row('Bank', tx.bank.toUpperCase()),
          _row('Date', DateFormat('dd MMM yyyy, hh:mm a').format(tx.timestamp)),
          if (tx.accountLast4 != null)
            _row('Account', 'XXXX${tx.accountLast4}'),
          if (tx.balance != null)
            _row('Balance after', '₹${tx.balance!.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text(
              'Original SMS',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            children: [Text(tx.rawSms, style: const TextStyle(fontSize: 12))],
          ),
        ],
      ),
    );
  }
}
