import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../presentation/screens/home_shell.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    final status = await Permission.sms.request();

    if (status.isGranted) {
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
      }
    } else {
      // Permission denied — still let them in, they can use the app
      // with manually-synced data later or just see empty states
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sms_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Read your bank SMS',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We read SMS from your bank to track UPI transactions automatically. '
                'Your messages never leave your phone — everything is processed locally.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _requestPermission(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Grant SMS Access'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
