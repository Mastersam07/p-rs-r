class AppConstants {
  static final regexParser = RegExp(
    r'^(?:\u200E|\u200F)*\[?(\d{1,4}[-/.] ?\d{1,4}[-/.] ?\d{1,4})[,.]? \D*?(\d{1,2}[.:]\d{1,2}(?:[.:]\d{1,2})?)(?: ([ap]\.?\s?m\.?))?\]?(?: -|:)? (.+?): ([^]*)',
    caseSensitive: false,
  );
  static final regexParserSystem = RegExp(
    r'^(?:\u200E|\u200F)*\[?(\d{1,4}[-/.] ?\d{1,4}[-/.] ?\d{1,4})[,.]? \D*?(\d{1,2}[.:]\d{1,2}(?:[.:]\d{1,2})?)(?: ([ap]\.?\s?m\.?))?\]?(?: -|:)? ([^]+)',
    caseSensitive: false,
  );
  static final regexSplitDate = RegExp(
    r'[-/.] ?',
    caseSensitive: false,
  );
  static final regexAttachment = RegExp(
    r'<.+:(.+)>|([A-Z\d-]+\.\w+)\s\(.+\)',
    caseSensitive: false,
  );
}
