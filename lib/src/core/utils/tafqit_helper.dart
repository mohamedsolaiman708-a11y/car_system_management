class TafqitHelper {
  static const List<String> _ones = ["", "واحد", "اثنان", "ثلاثة", "أربعة", "خمسة", "ستة", "سبعة", "ثمانية", "تسعة", "عشرة"];
  static const List<String> _teens = ["عشرة", "إحدى عشر", "اثنا عشر", "ثلاثة عشر", "أربعة عشر", "خمسة عشر", "ستة عشر", "سبعة عشر", "ثمانية عشر", "تسعة عشر"];
  static const List<String> _tens = ["", "عشرة", "عشرون", "ثلاثون", "أربعون", "خمسون", "ستون", "سبعون", "ثمانون", "تسعون"];
  static const List<String> _hundreds = ["", "مائة", "مائتان", "ثلاثمائة", "أربعمائة", "خمسمائة", "ستمائة", "سبعمائة", "ثمانمائة", "تسعمائة"];

  static String convert(double amount, {String currency = "ريال سعودي"}) {
    if (amount == 0) return "صفر ريال";
    
    int integerPart = amount.toInt();
    int decimalPart = ((amount - integerPart) * 100).round();

    String result = _convertGroup(integerPart);
    result += " " + currency;

    if (decimalPart > 0) {
      result += " و " + _convertGroup(decimalPart) + " هللة";
    }

    return result + " لا غير";
  }

  static String _convertGroup(int number) {
    if (number == 0) return "";
    if (number < 11) return _ones[number];
    if (number < 20) return _teens[number - 10];
    if (number < 100) {
      int ten = number ~/ 10;
      int one = number % 10;
      return (one > 0 ? _ones[one] + " و " : "") + _tens[ten];
    }
    if (number < 1000) {
      int hundred = number ~/ 100;
      int rest = number % 100;
      return _hundreds[hundred] + (rest > 0 ? " و " + _convertGroup(rest) : "");
    }
    if (number < 1000000) {
      int thousand = number ~/ 1000;
      int rest = number % 1000;
      String thStr = thousand == 1 ? "ألف" : (thousand == 2 ? "ألفان" : _convertGroup(thousand) + " آلاف");
      return thStr + (rest > 0 ? " و " + _convertGroup(rest) : "");
    }
    return number.toString(); // تبسيط للمبالغ الضخمة جداً
  }
}
