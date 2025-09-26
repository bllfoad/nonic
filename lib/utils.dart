import 'package:intl/intl.dart';

String money0(num value) {
  return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value);
}


