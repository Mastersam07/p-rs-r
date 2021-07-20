import 'dart:math';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import '../models/chat_message.dart';
import 'app_audio_player.dart';
import 'app_video_player.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.message, this.isRight = false, this.showAuthor = false});
  final ChatMessage message;
  final bool isRight;
  final bool showAuthor;
  final List<Color> authorColors = [
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.blue,
  ];

  Widget buildUserMessageChatBubbleInterface() {
    final bubbleMargin = EdgeInsets.only(
      top: !showAuthor ? 3 : 15,
      left: isRight ? 50 : 0,
      right: isRight ? 0 : 50,
    );
    if (message.hasFileAttached) {
      if (message.attachmentType == AttachmentType.image) {
        return Container(
          margin: bubbleMargin,
          decoration: BoxDecoration(
            color: isRight ? Colors.teal[300] : Colors.teal[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Image.file(message.attachedFile!),
              Text(
                message.message ?? '',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      } else if (message.attachmentType == AttachmentType.audio) {
        return Container(
          margin: bubbleMargin,
          child: AppAudioPlayer(
            audioFile: message.attachedFile!,
          ),
        );
      } else if (message.attachmentType == AttachmentType.video) {
        return Container(
          margin: bubbleMargin,
          decoration: BoxDecoration(
            color: isRight ? Colors.teal[300] : Colors.teal[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppVideoPlayer(
                videoFile: message.attachedFile!,
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                message.message ?? '',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      } else {
        return GestureDetector(
          onTap: () {
            OpenFile.open(message.attachedFile?.path);
          },
          child: Container(
            margin: bubbleMargin,
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.teal[800],
            ),
            child: Text(
              message.attachedFileName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    } else {
      return Container(
        margin: bubbleMargin,
        decoration: BoxDecoration(
          color: isRight ? Colors.teal[300] : Colors.teal[800],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            showAuthor
                ? Text(
                    message.userName ?? '',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: authorColors[Random().nextInt(3)]),
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: 4,
            ),
            Text(
              message.message ?? '',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              message.iNTLNormalizedTime,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return message.sender == MessageSender.system
        ? Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.teal,
              ),
              child: Text(
                message.message ?? '',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          )
        : Align(
            alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
            child: buildUserMessageChatBubbleInterface());
  }
}
