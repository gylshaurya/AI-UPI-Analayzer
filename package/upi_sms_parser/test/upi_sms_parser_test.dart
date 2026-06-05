import 'package:test/test.dart';
import 'package:upi_sms_parser/upi_sms_parser.dart';

void main() {
  group('PNB debit', () {
    const sms1 =
        'A/c X0298 debited INR 80.00 Dt 20-05-26 21:25:48 to VARISH thru UPI:650693182061.Bal INR 165.00 Not u?Fwd this SMS to 9264092640 to block UPI.-PNB';
    const sms2 =
        'A/c X0298 debited INR 141.50 Dt 28-05-26 00:51:33 to ABHISHEK  PANWA thru UPI:002507445616.Bal INR 263.50 Not u?Fwd this SMS to 9264092640 to block UPI.-PNB';

    test('parses amount correctly', () {
      final tx = UpiSmsParser.parse(sms1, sender: 'PNB');
      expect(tx?.amount, 80.0);
    });

    test('type is debit', () {
      expect(UpiSmsParser.parse(sms1)?.type, TransactionType.debit);
    });

    test('bank is pnb', () {
      expect(UpiSmsParser.parse(sms1)?.bank, Bank.pnb);
    });

    test('parses payee name (single word)', () {
      final tx = UpiSmsParser.parse(sms1);
      expect(tx?.payee, 'Varish');
    });

    test('parses payee name (multi word)', () {
      final tx = UpiSmsParser.parse(sms2);
      expect(tx?.payee, 'Abhishek Panwa');
    });

    test('parses balance', () {
      expect(UpiSmsParser.parse(sms1)?.balance, 165.0);
    });

    test('parses timestamp', () {
      final tx = UpiSmsParser.parse(sms1);
      expect(tx?.timestamp.day, 20);
      expect(tx?.timestamp.month, 5);
      expect(tx?.timestamp.year, 2026);
    });

    test('parses account last 4', () {
      expect(UpiSmsParser.parse(sms1)?.accountLast4, '0298');
    });
  });

  group('PNB credit', () {
    const sms =
        'A/c X0298 credited for INR 593.00 on 30-05-26 19:01:10 by ABHISHEK  PANWA thru UPI.AvlBal INR 856.50(UPI:615053084186).-PNB';

    test('type is credit', () {
      expect(UpiSmsParser.parse(sms)?.type, TransactionType.credit);
    });

    test('parses amount', () {
      expect(UpiSmsParser.parse(sms)?.amount, 593.0);
    });

    test('parses payee', () {
      expect(UpiSmsParser.parse(sms)?.payee, 'Abhishek Panwa');
    });
  });

  group('ICICI debit', () {
    const sms =
        'ICICI Bank Acct XX280 debited for Rs 598.10 on 02-Jun-26; Dominos Pizza credited. UPI:207554339160. Call 18002662 for dispute. SMS BLOCK 280 to 9215676766.';

    test('parses amount', () {
      expect(UpiSmsParser.parse(sms)?.amount, 598.10);
    });

    test('type is debit', () {
      expect(UpiSmsParser.parse(sms)?.type, TransactionType.debit);
    });

    test('bank is icici', () {
      expect(UpiSmsParser.parse(sms)?.bank, Bank.icici);
    });

    test('parses payee', () {
      expect(UpiSmsParser.parse(sms)?.payee, 'Dominos Pizza');
    });

    test('parses date', () {
      final tx = UpiSmsParser.parse(sms);
      expect(tx?.timestamp.day, 2);
      expect(tx?.timestamp.month, 6);
    });
  });

  group('Edge cases', () {
    test('returns null for OTP SMS', () {
      expect(UpiSmsParser.parse('Your OTP is 123456. Do not share.'), isNull);
    });

    test('returns null for empty string', () {
      expect(UpiSmsParser.parse(''), isNull);
    });

    test('works without sender hint', () {
      const sms =
          'A/c X0298 debited INR 80.00 Dt 20-05-26 21:25:48 to VARISH thru UPI:650693182061.Bal INR 165.00 Not u?Fwd this SMS to 9264092640 to block UPI.-PNB';
      expect(UpiSmsParser.parse(sms), isNotNull); // infers PNB from body
    });
  });

  group('ICICI credit', () {
    const sms =
        'Dear Customer, Acct XX280 is credited with Rs 21000.00 on 04-May-26 from ASHISH MAHENDRA. UPI:122599212796-ICICI Bank.';

    test('type is credit', () {
      expect(UpiSmsParser.parse(sms)?.type, TransactionType.credit);
    });

    test('parses amount', () {
      expect(UpiSmsParser.parse(sms)?.amount, 21000.0);
    });

    test('parses payee', () {
      expect(UpiSmsParser.parse(sms)?.payee, 'Ashish Mahendra');
    });

    test('bank is icici', () {
      expect(UpiSmsParser.parse(sms)?.bank, Bank.icici);
    });
  });
}
