import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_chat_parser/utils/size_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';

import '../models/chat_message.dart';
import 'app_audio_player.dart';
import 'app_video_player.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({
    required this.message,
    this.isRight = false,
    this.showAuthor = false,
  });
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
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: isRight ? Color(0xFFDCF8C6) : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Image.file(
                message.attachedFile!,
              ),
              if (message.message?.isNotEmpty ?? false)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      message.message ?? '',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF4D4D4D),
                        fontSize: SizeConfig.textSize(12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
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
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: isRight ? Color(0xFFDCF8C6) : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppVideoPlayer(
                videoFile: message.attachedFile!,
              ),
              if (message.message?.isNotEmpty ?? false)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      message.message ?? '',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF4D4D4D),
                        fontSize: SizeConfig.textSize(12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
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
              color: isRight ? Color(0xFFDCF8C6) : Colors.white,
            ),
            child: Text(
              message.attachedFileName,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Color(0xFF4D4D4D),
                fontSize: SizeConfig.textSize(12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
    } else {
      return Container(
        margin: bubbleMargin,
        decoration: BoxDecoration(
          color: isRight ? Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.only(
          left: SizeConfig.width(16),
          right: SizeConfig.width(10),
          top: SizeConfig.height(8),
          bottom: SizeConfig.height(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            showAuthor
                ? Text(
                    message.userName ?? '',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: SizeConfig.textSize(14),
                        color: authorColors[Random().nextInt(3)]),
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: 4,
            ),
            Text(
              message.message ?? '',
              style: GoogleFonts.poppins(
                color: Color(0xFF4D4D4D),
                fontSize: SizeConfig.textSize(12),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              message.iNTLNormalizedTime,
              style: GoogleFonts.poppins(
                fontSize: SizeConfig.textSize(10),
                fontWeight: FontWeight.w400,
                color: Color(0xFFA7A7A7),
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
                color: Colors.white,
              ),
              child: Text(
                message.message ?? '',
                style: GoogleFonts.poppins(
                  color: Color(0xFFCCCCCC),
                  fontWeight: FontWeight.w500,
                  fontSize: SizeConfig.textSize(12),
                ),
              ),
            ),
          )
        : Align(
            alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
            child: buildUserMessageChatBubbleInterface());
  }
}
