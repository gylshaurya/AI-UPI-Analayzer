import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../bloc/insights/insights_bloc.dart';
import '../../bloc/insights/insights_event.dart';
import '../../bloc/insights/insights_state.dart';
import '../../data/models/transaction_hive_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];

  String _buildContext(List<TransactionHiveModel> txs) {
    final recent = txs.take(30);
    final buffer = StringBuffer();
    for (final tx in recent) {
      final date = DateFormat('dd MMM').format(tx.timestamp);
      buffer.writeln(
        '$date: ${tx.type == 'debit' ? 'Spent' : 'Received'} ₹${tx.amount.toStringAsFixed(2)} '
        '${tx.type == 'debit' ? 'to' : 'from'} ${tx.payee ?? 'Unknown'}',
      );
    }
    return buffer.toString();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final txState = context.read<TransactionBloc>().state;
    if (txState is! TransactionLoaded || txState.all.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync your transactions first')),
      );
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });

    context.read<InsightsBloc>().add(
      AskQuestion(text, _buildContext(txState.all)),
    );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Insights')),
      body: Column(
        children: [
          Expanded(
            child: BlocListener<InsightsBloc, InsightsState>(
              listener: (context, state) {
                if (state is InsightsAnswered) {
                  setState(() {
                    _messages.add(
                      _ChatMessage(text: state.answer, isUser: false),
                    );
                  });
                } else if (state is InsightsError) {
                  setState(() {
                    _messages.add(
                      _ChatMessage(
                        text: 'Error: ${state.message}',
                        isUser: false,
                        isError: true,
                      ),
                    );
                  });
                }
              },
              child: _messages.isEmpty
                  ? _buildSuggestions(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) => _buildBubble(_messages[i]),
                    ),
            ),
          ),
          BlocBuilder<InsightsBloc, InsightsState>(
            builder: (context, state) {
              if (state is InsightsLoading) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask about your spending...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final suggestions = [
      'How much did I spend this week?',
      'Who do I send money to most?',
      'Any unusual spending recently?',
      'How can I save more money?',
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Ask me about your finances',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: suggestions.map((s) {
              return ActionChip(
                label: Text(s, style: const TextStyle(fontSize: 12)),
                onPressed: () {
                  _controller.text = s;
                  _send();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isUser
              ? Colors.blue.shade100
              : (msg.isError ? Colors.red.shade50 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg.text),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}
