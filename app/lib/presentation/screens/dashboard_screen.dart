import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/empty_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Analyzer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () =>
                context.read<TransactionBloc>().add(SyncTransactions()),
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Something went wrong',
              subtitle: state.message,
              action: FilledButton(
                onPressed: () =>
                    context.read<TransactionBloc>().add(LoadTransactions()),
                child: const Text('Retry'),
              ),
            );
          }

          if (state is TransactionLoaded) {
            if (state.all.isEmpty) {
              return EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No transactions yet',
                subtitle:
                    'Tap the sync button above to read your bank SMS messages.',
                action: FilledButton.icon(
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync now'),
                  onPressed: () =>
                      context.read<TransactionBloc>().add(SyncTransactions()),
                ),
              );
            }

            final recent = state.all.take(5).toList();
            final net = state.totalCredit - state.totalDebit;

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<TransactionBloc>().add(SyncTransactions()),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      SummaryCard(
                        label: 'Spent',
                        amount: state.totalDebit,
                        color: Colors.red,
                        icon: Icons.arrow_upward,
                      ),
                      SummaryCard(
                        label: 'Received',
                        amount: state.totalCredit,
                        color: Colors.green,
                        icon: Icons.arrow_downward,
                      ),
                      SummaryCard(
                        label: 'Net',
                        amount: net,
                        color: net >= 0 ? Colors.green : Colors.red,
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      SummaryCard(
                        label: 'Balance',
                        amount: state.latestBalance ?? 0,
                        color: Colors.blue,
                        icon: Icons.savings_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: recent
                          .map((tx) => TransactionTile(tx: tx))
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
