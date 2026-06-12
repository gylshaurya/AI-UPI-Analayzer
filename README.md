# AI UPI Analyzer

A Flutter app that reads UPI transaction SMS from your bank, shows your spending in a dashboard, and lets you ask an AI questions about your money.

## What it does

- Reads bank SMS messages (currently supports PNB and ICICI)
- Pulls out the amount, payee, balance, and date from each message
- Shows a dashboard with total spent, received, and current balance
- Lets you filter and view all transactions
- Shows weekly spending charts and your top payees
- Has an AI chat where you can ask things like "how much did I spend this week?"

## Project structure

This is a monorepo with two parts:

```
/app       - the Flutter app
/package   - the bank_upi_sms_parser package (published separately)
```

The app uses the package to parse SMS messages. The package itself has no dependency on the app and can be used in any Flutter or Dart project.

## The package

`bank_upi_sms_parser` parses bank SMS strings into structured transaction objects. It's published on pub.dev:

https://pub.dev/packages/bank_upi_sms_parser

It has its own tests and README inside `/package/upi_sms_parser`.

## Tech used

- Flutter + Dart
- flutter_bloc for state management
- Hive for local storage
- flutter_sms_inbox to read SMS
- Gemini API for AI insights
- fl_chart for graphs

## How to run

```bash
cd app
flutter pub get
flutter run
```

You'll need to add your own Gemini API key in a `.env` file inside `/app`:

```
API_KEY=your_key_here
```

## Notes

- SMS reading only works on a real Android device, not on emulator
- On first launch, grant SMS permission and tap the sync button to load your transactions
- Currently supports PNB and ICICI SMS formats. Other banks can be added by writing new regex patterns in the package

## Demo

Video link: [[Demo Video](https://drive.google.com/file/d/1nYWj2IYjj1TumiWvIScevuT7Ef-vCVl7/view?usp=sharing)]