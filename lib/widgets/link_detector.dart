import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkDetectorText extends StatelessWidget {
  final String? message;
  final _linkRegex = RegExp(
      r'[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false);
  LinkDetectorText({Key? key, this.message}) : super(key: key);
  TextSpan text() {
    if (message != null) {
      List<TextSpan> textSpans = [];
      List<String> allWords = message!.split(' ');
      allWords.forEach((element) {
        if (_linkRegex.hasMatch(element)) {
        } else {
          textSpans.add(TextSpan(
            text: element,
            style: TextStyle(
              color: Colors.blue,
            ),
            recognizer: (TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse(element.trim()));
              }),
          ));
        }
      });
      return TextSpan(
        children: textSpans,
      );
    } else {
      return TextSpan(text: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text.rich(text()),
    );
  }
}
