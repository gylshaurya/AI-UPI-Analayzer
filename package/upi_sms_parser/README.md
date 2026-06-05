# bank_upi_sms_parser

A Dart package to parse UPI transaction SMS messages into clean, structured Dart objects.

Instead of dealing with messy SMS strings, you get a simple `UpiTransaction` object with the amount, payee, transaction type, timestamp, and balance — ready to use in your app.

Currently supports **Punjab National Bank (PNB)** and **ICICI Bank**.

---

## What it does

Banks send an SMS every time a UPI transaction happens. These messages look something like this:

```
A/c X0298 debited INR 80.00 Dt 20-05-26 21:25:48 to VARISH thru UPI:650693182061.Bal INR 165.00 Not u?Fwd this SMS to 9264092640 to block UPI.-PNB
```

This package reads that string and gives you back:

```dart
UpiTransaction(
  amount: 80.0,
  type: TransactionType.debit,
  bank: Bank.pnb,
  payee: 'Varish',
  accountLast4: '0298',
  balance: 165.0,
  timestamp: DateTime(2026, 5, 20, 21, 25, 48),
)
```

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  upi_sms_parser: ^0.1.0
```

Then run:

```
dart pub get
```

---

## Usage

```dart
import 'package:upi_sms_parser/upi_sms_parser.dart';

void main() {
  const sms = 'A/c X0298 debited INR 80.00 Dt 20-05-26 21:25:48 to VARISH thru UPI:650693182061.Bal INR 165.00 Not u?Fwd this SMS to 9264092640 to block UPI.-PNB';

  final tx = UpiSmsParser.parse(sms);

  if (tx != null) {
    print(tx.amount);    // 80.0
    print(tx.type);      // TransactionType.debit
    print(tx.payee);     // Varish
    print(tx.balance);   // 165.0
    print(tx.bank);      // Bank.pnb
  }
}
```

You can also pass the SMS sender ID as a hint for faster and more accurate detection:

```dart
final tx = UpiSmsParser.parse(sms, sender: 'PNB');
```

If the SMS is not a UPI transaction (e.g. an OTP or promotional message), `parse()` returns `null`.

---

## The `UpiTransaction` model

| Field | Type | Description |
|---|---|---|
| `amount` | `double` | Transaction amount in INR |
| `type` | `TransactionType` | `debit` or `credit` |
| `bank` | `Bank` | Which bank sent the SMS |
| `payee` | `String?` | Name of who you paid or received from |
| `accountLast4` | `String?` | Last 4 digits of your account number |
| `balance` | `double?` | Account balance after the transaction (if available) |
| `timestamp` | `DateTime` | Date and time of the transaction |
| `rawSms` | `String` | The original SMS string |

`UpiTransaction` also has `toJson()` and `fromJson()` if you need to store or send it somewhere.

---

## Supported banks and SMS formats

### PNB — Debit
```
A/c X0298 debited INR 141.50 Dt 28-05-26 00:51:33 to ABHISHEK PANWA thru UPI:002507445616.Bal INR 263.50 ...-PNB
```

### PNB — Credit
```
A/c X0298 credited for INR 593.00 on 30-05-26 19:01:10 by ABHISHEK PANWA thru UPI.AvlBal INR 856.50...-PNB
```

### ICICI — Debit
```
ICICI Bank Acct XX280 debited for Rs 598.10 on 02-Jun-26; Dominos Pizza credited. UPI:207554339160...
```

### ICICI — Credit
```
Dear Customer, Acct XX280 is credited with Rs 21000.00 on 04-May-26 from ASHISH MAHENDRA. UPI:122599212796-ICICI Bank.
```

---

## Bank detection

You don't need to tell the package which bank the SMS is from. It figures it out on its own by looking at the sender ID and the SMS content. But if you already have the sender ID (which most SMS APIs give you), passing it in makes detection faster:

```dart
UpiSmsParser.parse(sms, sender: 'ICICIB');  // ICICI
UpiSmsParser.parse(sms, sender: 'PUNBNK');  // PNB
```

---

## Adding more banks

The package is structured so that adding a new bank is straightforward, just add a new patterns file under `lib/src/patterns/` and register it in the `RegexEngine`. PRs are welcome.

---

## Contributing

Found a bank SMS format that doesn't parse correctly? Open an issue with the (redacted) SMS text and the bank name. Please remove your account number and any personal details before sharing.

---

## License

MIT

Made by Shaurya(Maverick)