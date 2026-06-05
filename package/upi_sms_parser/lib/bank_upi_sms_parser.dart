library bank_upi_sms_parser;

import 'src/models/upi_transaction.dart';
import 'src/regex_engine.dart';

export 'src/models/upi_transaction.dart';
export 'src/regex_engine.dart';

class UpiSmsParser {
  UpiSmsParser._();

  static UpiTransaction? parse(String smsBody, {String? sender}) {
    if (smsBody.trim().isEmpty) return null;
    return RegexEngine.tryParse(smsBody, sender: sender);
  }
}
