import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/transaction_hive_model.dart';
import 'data/repositories/transaction_repository.dart';
import 'bloc/transaction/transaction_bloc.dart';
import 'bloc/transaction/transaction_event.dart';
import 'bloc/insights/insights_bloc.dart';

import 'presentation/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionHiveModelAdapter());
  await Hive.openBox<TransactionHiveModel>('transactions');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              TransactionBloc(TransactionRepository())..add(LoadTransactions()),
        ),
        BlocProvider(create: (_) => InsightsBloc()),
      ],
      child: MaterialApp(
        title: 'UPI Analyzer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
          useMaterial3: true,
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}
