import 'models/upi_transaction.dart';
import 'patterns/pnb_patterns.dart';
import 'patterns/icici_patterns.dart';

class RegexEngine {
  static UpiTransaction? tryParse(String sms, {String? sender}) {
    final s = sms.toLowerCase();

    if (sender != null) {
      if (sender.contains('PNB') || sender.contains('PUNBNK')) {
        return _tryPnb(sms);
      }
      if (sender.contains('ICICIB') || sender.contains('ICICI')) {
        return _tryIcici(sms);
      }
    }

    if (s.contains('-pnb') || s.contains('a/c x')) return _tryPnb(sms);
    if (s.contains('icici bank') || s.contains('icici')) return _tryIcici(sms);

    return null;
  }

  static UpiTransaction? _tryPnb(String sms) {
    final debitMatch = PnbPatterns.debit.firstMatch(sms);
    if (debitMatch != null) {
      return UpiTransaction(
        accountLast4: debitMatch.group(1),
        amount: _parseAmount(debitMatch.group(2)!),
        type: TransactionType.debit,
        bank: Bank.pnb,
        payee: _cleanName(debitMatch.group(5)),
        balance: _parseAmount(debitMatch.group(6)!),
        timestamp:
            _parsePnbDateTime(debitMatch.group(3)!, debitMatch.group(4)!),
        rawSms: sms,
      );
    }

    final creditMatch = PnbPatterns.credit.firstMatch(sms);
    if (creditMatch != null) {
      return UpiTransaction(
        accountLast4: creditMatch.group(1),
        amount: _parseAmount(creditMatch.group(2)!),
        type: TransactionType.credit,
        bank: Bank.pnb,
        payee: _cleanName(creditMatch.group(5)),
        balance: _parseAmount(creditMatch.group(6)!),
        timestamp:
            _parsePnbDateTime(creditMatch.group(3)!, creditMatch.group(4)!),
        rawSms: sms,
      );
    }

    return null;
  }

  static UpiTransaction? _tryIcici(String sms) {
    final debitMatch = IciciPatterns.debit.firstMatch(sms);
    if (debitMatch != null) {
      return UpiTransaction(
        accountLast4: debitMatch.group(1),
        amount: _parseAmount(debitMatch.group(2)!),
        type: TransactionType.debit,
        bank: Bank.icici,
        payee: _cleanName(debitMatch.group(4)),
        balance: null,
        timestamp: _parseIciciDate(debitMatch.group(3)!),
        rawSms: sms,
      );
    }

    final creditMatch = IciciPatterns.credit.firstMatch(sms);
    if (creditMatch != null) {
      return UpiTransaction(
        accountLast4: creditMatch.group(1),
        amount: _parseAmount(creditMatch.group(2)!),
        type: TransactionType.credit,
        bank: Bank.icici,
        payee: _cleanName(creditMatch.group(4)),
        balance: null,
        timestamp: _parseIciciDate(creditMatch.group(3)!),
        rawSms: sms,
      );
    }
    return null;
  }

  static double _parseAmount(String raw) =>
      double.tryParse(raw.replaceAll(',', '')) ?? 0.0;

  static String? _cleanName(String? raw) {
    if (raw == null) return null;
    return raw
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) {
          if (w.isEmpty) return '';
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        })
        .where((w) => w.isNotEmpty)
        .join(' ');
  }

  static DateTime _parsePnbDateTime(String date, String time) {
    final parts = date.split('-');
    final timeParts = time.split(':');
    if (parts.length != 3 || timeParts.length != 3) return DateTime.now();
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    var year = int.parse(parts[2]);
    if (year < 100) year += 2000;
    return DateTime(year, month, day, int.parse(timeParts[0]),
        int.parse(timeParts[1]), int.parse(timeParts[2]));
  }

  static DateTime _parseIciciDate(String date) {
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final parts = date.split('-');
    if (parts.length != 3) return DateTime.now();
    final day = int.parse(parts[0]);
    final month = months[parts[1].toLowerCase()] ?? 1;
    var year = int.parse(parts[2]);
    if (year < 100) year += 2000;
    return DateTime(year, month, day);
  }
}
