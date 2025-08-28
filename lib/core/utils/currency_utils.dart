
// core/utils/currency_utils.dart
import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatAmount(double amount, [String symbol = '\$', int decimals = 2]) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
    );
    return formatter.format(amount);
  }

  static String formatAmountWithoutSymbol(double amount, [int decimals = 2]) {
    final formatter = NumberFormat('#,##0.${'0' * decimals}');
    return formatter.format(amount);
  }

  static double parseAmount(String amountString) {
    // Remove currency symbols and thousands separators
    String cleanAmount = amountString
        .replaceAll(RegExp(r'[^\d.-]'), '')
        .trim();
    
    return double.tryParse(cleanAmount) ?? 0.0;
  }

  static String formatCompactAmount(double amount, [String symbol = '\$']) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatAmount(amount, symbol);
    }
  }
}
