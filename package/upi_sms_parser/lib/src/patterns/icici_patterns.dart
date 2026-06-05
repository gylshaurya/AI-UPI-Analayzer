class IciciPatterns {
  // Captures: (acct) (amount) (date) (payee)
  static final debit = RegExp(
    r'Acct\s+XX(\d+)\s+debited\s+for\s+Rs\s+([\d,]+\.?\d*)\s+on\s+(\d{2}-[A-Za-z]{3}-\d{2,4});\s*(.+?)\s+credited\.',
    caseSensitive: false,
  );

  static final credit = RegExp(
    r'Acct\s+XX(\d+)\s+is\s+credited\s+with\s+Rs\s+([\d,]+\.?\d*)\s+on\s+(\d{2}-[A-Za-z]{3}-\d{2,4})\s+from\s+(.+?)\.\s+UPI',
    caseSensitive: false,
  );
}
