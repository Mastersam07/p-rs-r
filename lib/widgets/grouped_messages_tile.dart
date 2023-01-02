import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat_message.dart';
import '../utils/utilities.dart';
import 'chat_bubble.dart';

class GroupedMessagesTile extends StatelessWidget {
  const GroupedMessagesTile({
    Key? key,
    required this.date,
    required this.messages,
  }) : super(key: key);

  final String date;
  final Iterable<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    List<MessageBubble> buildMessages(List<ChatMessage> allMessages) {
      List<MessageBubble> allChatBubbles = [];
      //HANDLE FIRST WHERE
      if (allMessages.isNotEmpty) {
        String firstAuthor = allMessages
            .firstWhere((element) => element.sender == MessageSender.user)
            .userName!;
        String? cacheAuthor;
        allMessages.forEach((chatMessage) {
          if (cacheAuthor != chatMessage.userName) {
            cacheAuthor = chatMessage.userName;
            allChatBubbles.add(MessageBubble(
              message: chatMessage,
              isRight: firstAuthor == chatMessage.userName,
              showAuthor: true,
            ));
          } else {
            allChatBubbles.add(MessageBubble(
              message: chatMessage,
              isRight: firstAuthor == chatMessage.userName,
              showAuthor: false,
            ));
          }
        });
        return allChatBubbles;
      }
      return [];
    }

    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          DateFormatter()
              .getVerboseDateTimeRepresentation(DateFormat.yMMMd().parse(date)),
        ),
        SizedBox(height: 12),
        ...buildMessages(messages.toList()),
      ],
    );
  }
}
