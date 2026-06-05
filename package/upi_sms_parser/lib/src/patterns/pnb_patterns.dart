class PnbPatterns {
  // acc amount date time payee balance
  static final debit = RegExp(
    r'A/c\s+X(\d+)\s+debited\s+INR\s+([\d,]+\.?\d*)\s+Dt\s+(\d{2}-\d{2}-\d{2})\s+([\d:]+)\s+to\s+([A-Z][A-Z\s]+?)\s+thru\s+UPI.*?Bal\s+INR\s+([\d,]+\.?\d*)',
    caseSensitive: false,
  );

  static final credit = RegExp(
    r'A/c\s+X(\d+)\s+credited\s+for\s+INR\s+([\d,]+\.?\d*)\s+on\s+(\d{2}-\d{2}-\d{2})\s+([\d:]+)\s+by\s+([A-Z][A-Z\s]+?)\s+thru\s+UPI.*?AvlBal\s+INR\s+([\d,]+\.?\d*)',
    caseSensitive: false,
  );
}
