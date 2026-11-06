import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _rupiahFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String formatRupiah(int amount) {
    return _rupiahFormatter.format(amount);
  }

  static String formatCompactRupiah(int amount) {
    if (amount >= 1000000) {
      final val = amount / 1000000;
      return 'Rp ${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)} Jt';
    }
    if (amount >= 1000) {
      final val = amount / 1000;
      return 'Rp ${val.toStringAsFixed(0)}k';
    }
    return 'Rp $amount';
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy • HH:mm').format(dateTime.toLocal());
  }

  static String formatDateShort(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime.toLocal());
  }
}

