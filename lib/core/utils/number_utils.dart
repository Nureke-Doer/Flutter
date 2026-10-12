/// Разбирает число, введённое пользователем.
///
/// Понимает разные записи: «2,5» и «2.5», «300 000», «1,000,000»,
/// «1.000.000,5». Возвращает `null`, если это не число.
double? parseNumber(String text) {
  var s = text.replaceAll(RegExp(r'[\s  ]'), '');
  final lastComma = s.lastIndexOf(',');
  final lastDot = s.lastIndexOf('.');
  if (lastComma != -1 && lastDot != -1) {
    // Есть оба знака: последний — десятичный, другой — разделитель тысяч.
    final decimal = lastComma > lastDot ? ',' : '.';
    final thousands = decimal == ',' ? '.' : ',';
    s = s.replaceAll(thousands, '').replaceAll(decimal, '.');
  } else if (','.allMatches(s).length > 1) {
    s = s.replaceAll(',', ''); // «1,000,000»
  } else if ('.'.allMatches(s).length > 1) {
    s = s.replaceAll('.', ''); // «1.000.000»
  } else {
    s = s.replaceAll(',', '.'); // «2,5»
  }
  return double.tryParse(s);
}

/// Число для поля ввода: без разделителей тысяч и лишних нулей
/// (300000, 2.5), чтобы его можно было отредактировать и снова разобрать.
String formatInput(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();
