import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../data/models/transaction_hive_model.dart';
import '../widgets/empty_state.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  // Group transactions by week (last 6 weeks), summing debits
  Map<String, double> _weeklySpend(List<TransactionHiveModel> all) {
    final now = DateTime.now();
    final Map<String, double> result = {};

    for (int i = 5; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + i * 7));
      final label = '${weekStart.day}/${weekStart.month}';
      result[label] = 0;
    }

    for (final tx in all) {
      if (tx.type != 'debit') continue;
      final daysAgo = now.difference(tx.timestamp).inDays;
      final weekIndex = (daysAgo / 7).floor();
      if (weekIndex > 5) continue;

      final weekStart = now.subtract(
        Duration(days: now.weekday - 1 + weekIndex * 7),
      );
      final label = '${weekStart.day}/${weekStart.month}';
      result[label] = (result[label] ?? 0) + tx.amount;
    }

    return result;
  }

  // Top 5 payees by total amount sent
  List<MapEntry<String, double>> _topPayees(List<TransactionHiveModel> all) {
    final Map<String, double> totals = {};
    for (final tx in all) {
      if (tx.type != 'debit' || tx.payee == null) continue;
      totals[tx.payee!] = (totals[tx.payee!] ?? 0) + tx.amount;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is! TransactionLoaded || state.all.isEmpty) {
            return const EmptyState(
              icon: Icons.bar_chart_outlined,
              title: 'No data yet',
              subtitle:
                  'Sync your transactions from the Home tab to see analytics.',
            );
          }

          final weekly = _weeklySpend(state.all);
          final topPayees = _topPayees(state.all);
          final maxWeekly = weekly.values.isEmpty
              ? 100.0
              : weekly.values.reduce((a, b) => a > b ? a : b);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Weekly Spending',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: maxWeekly == 0 ? 100 : maxWeekly * 1.2,
                    barGroups: weekly.entries.toIndexedList(
                      (i, e) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: e.value,
                            color: Theme.of(context).colorScheme.primary,
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final keys = weekly.keys.toList();
                            final i = value.toInt();
                            if (i < 0 || i >= keys.length)
                              return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                keys[i],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Top Payees',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (topPayees.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No payee data yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: topPayees.map((e) {
                      return ListTile(
                        title: Text(e.key),
                        trailing: Text(
                          '₹${e.value.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

extension _IndexedList<T> on Iterable<T> {
  List<R> toIndexedList<R>(R Function(int index, T item) f) {
    final list = toList();
    return List.generate(list.length, (i) => f(i, list[i]));
  }
}
