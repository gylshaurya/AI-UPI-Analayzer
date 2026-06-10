import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/empty_state.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _typeFilter; // null, 'debit', 'credit'
  String? _bankFilter; // null, 'pnb', 'icici'

  void _applyFilter(BuildContext context) {
    context.read<TransactionBloc>().add(
      FilterTransactions(type: _typeFilter, bank: _bankFilter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All', _typeFilter == null, () {
                    setState(() => _typeFilter = null);
                    _applyFilter(context);
                  }),
                  _filterChip('Debit', _typeFilter == 'debit', () {
                    setState(() => _typeFilter = 'debit');
                    _applyFilter(context);
                  }),
                  _filterChip('Credit', _typeFilter == 'credit', () {
                    setState(() => _typeFilter = 'credit');
                    _applyFilter(context);
                  }),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 24, color: Colors.grey.shade300),
                  const SizedBox(width: 8),
                  _filterChip('PNB', _bankFilter == 'pnb', () {
                    setState(
                      () => _bankFilter = _bankFilter == 'pnb' ? null : 'pnb',
                    );
                    _applyFilter(context);
                  }),
                  _filterChip('ICICI', _bankFilter == 'icici', () {
                    setState(
                      () =>
                          _bankFilter = _bankFilter == 'icici' ? null : 'icici',
                    );
                    _applyFilter(context);
                  }),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is! TransactionLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.filter_alt_off_outlined,
                    title: 'No transactions found',
                    subtitle: 'Try changing or clearing your filters.',
                  );
                }

                return ListView.builder(
                  itemCount: state.filtered.length,
                  itemBuilder: (context, i) =>
                      TransactionTile(tx: state.filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
