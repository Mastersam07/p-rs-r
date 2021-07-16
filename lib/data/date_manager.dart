import 'package:intl/intl.dart';

import 'constants.dart';

class DateManager {
  List<String?> _monthList = [];
  List<String?> _dateList = [];
  static bool _isFirstMonthType = false;
  String dateFormat() =>
      _isFirstMonthType ? 'yyyy-DD-MM HH:mm' : 'yyyy-MM-DD HH:mm';

  DateTime normalizeDate(List<String?> splitRegexMessage) {
    String? pm = splitRegexMessage[3];
    String getDateFormat = dateFormat();
    List<String>? date = splitRegexMessage[1]!
        .split(AppConstants.regexSplitDate)
        .reversed
        .toList();
    date.add(' ${splitRegexMessage[2]}');
    splitRegexMessage.forEach((element) {
      //  print(element);
    });
    if (date[0].length < 4) {
      date[0] = '${(int.tryParse(date[0])! + 2000)}';
    }
    if (pm != null) {
      date[1] = date[1].padLeft(2, '0');
      date[2] = date[2].padLeft(2, '0');
    }
    if (date.length == 4) {
      String year = date.sublist(0, 3).join('-');
      String time = date.last;
      if (pm != null && pm == 'PM') {
        List<String> timeSplit = time.split(':');
        timeSplit[0] = '${int.tryParse(timeSplit[0])! + 12}';
        time = timeSplit.join(':');
        return DateFormat(getDateFormat).parse(year.trim() + ' ' + time.trim());
      } else if (pm != null && pm == 'AM') {
        List<String> timeSplit = time.split(':');
        if (timeSplit[0].trim() == '12') {
          timeSplit[0] = '00';
        } else if (int.tryParse(timeSplit[0])! < 10) {
          timeSplit[0] = timeSplit[0].trim().padLeft(2, '0');
        }
        time = timeSplit.join(':');
        return DateFormat(getDateFormat).parse(year.trim() + ' ' + time.trim());
      }
      return DateFormat(getDateFormat).parse(year + time);
    }
    //Todo Handle abnormality
    return DateTime.now();
  }

  void checkDateFormat(List<String> allMergedMessages) {
    allMergedMessages.forEach((element) {
      final chatRegex = AppConstants.regexParser.allMatches(element);
      RegExpMatch chatMatch;
      if (chatRegex.isNotEmpty) {
        chatMatch = chatRegex.first;
      } else {
        return;
      }

      final listOfSplitString = chatMatch
          .groups(List<int>.generate(chatMatch.groupCount, (index) => index));
      List<String>? dateAndTimeList =
          listOfSplitString[1]!.split(AppConstants.regexSplitDate).toList();
      _dateList.add(dateAndTimeList.first);
      _monthList.add(dateAndTimeList[1]);
    });
    _isFirstMonthType =
        _monthList.any((element) => int.tryParse(element!)! > 12);
  }
}
