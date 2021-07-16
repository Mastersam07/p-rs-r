import 'dart:io';

import 'package:intl/intl.dart';

class ChatMessage {
  final String? userName;
  final String? message;
  final DateTime? time;
  final MessageType? type;
  final MessageSender? sender;
  final bool containsLink;
  final bool containsFile;
  final File? attachedFile;

  ChatMessage({
    this.userName,
    this.message,
    this.time,
    this.type,
    this.sender,
    this.containsLink = false,
    this.attachedFile,
    this.containsFile = false,
  });
  final DateFormat format = DateFormat.yMMMd().add_jm();
  String get iNTLNormalizedTime {
    if (time != null) {
      return format.format(time!);
    } else {
      return 'Time';
    }
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage();
  }
}

enum MessageType { text, file }
enum MessageSender { system, user }
