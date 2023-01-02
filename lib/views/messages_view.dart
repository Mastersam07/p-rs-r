import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../utils/size_config.dart';
import '../view_models/parser_view_model.dart';
import '../widgets/grouped_messages_tile.dart';
import '../widgets/view_state_builder.dart';

class MessagesView extends StatefulWidget {
  MessagesView({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MessagesViewState createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ParserViewModel>.value(
      value: ParserViewModel.instance,
      child: Consumer<ParserViewModel>(
        builder: (_, provider, __) {
          return Scaffold(
            backgroundColor: provider.appState == ViewState.done
                ? Color(0xFF00C263)
                : Colors.white,
            body: ViewStateBuilder(
              state: provider.appState,
              loadingWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.width(32),
                    ),
                    child: LinearProgressIndicator(
                      backgroundColor: Color(0xFFFCFCFC),
                      minHeight: SizeConfig.height(12),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.height(48),
                  ),
                  Text(
                    "Chat Parsing...",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: SizeConfig.textSize(24),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.height(8),
                  ),
                  Text(
                    "Please wait while your chat is being parsed",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Color(0xFF808080),
                      fontWeight: FontWeight.w500,
                      fontSize: SizeConfig.textSize(14),
                    ),
                  ),
                ],
              ),
              errorWidget: Column(
                children: [],
              ),
              successWidget: SafeArea(
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: Image(
                      image: AssetImage('assets/images/whatsappbg.png'),
                      fit: BoxFit.cover,
                    )),
                    ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      itemBuilder: (context, index) {
                        final item =
                            provider.allMessages.entries.elementAt(index);
                        return GroupedMessagesTile(
                          date: item.key,
                          messages: item.value,
                        );
                      },
                    ),
                  ],
                ),
              ),
              initialWidget: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage('assets/images/messageicon.png'),
                        width: SizeConfig.width(92),
                      ),
                      SizedBox(
                        height: SizeConfig.height(48),
                      ),
                      Text(
                        "No Conversations Yet",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                            text:
                                "You have not added any conversations yet. Tap the add icon to add a conversation in ",
                            style: GoogleFonts.poppins(
                              color: Color(0xFF808080),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: ' .TXT ',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: 'format or a',
                                style: GoogleFonts.poppins(
                                  color: Color(0xFF808080),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: ' ZIP ',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: 'file.',
                                style: GoogleFonts.poppins(
                                  color: Color(0xFF808080),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ]),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: provider.appState == ViewState.busy
                ? null
                : FloatingActionButton(
                    backgroundColor: Color(0xFF00E676),
                    onPressed: () => provider.parseInit(),
                    tooltip: 'Add txt or zip file',
                    child: Icon(
                      Icons.add_circle_outline_outlined,
                      size: 32,
                    ),
                  ), // This trailing comma makes auto-formatting nicer for build methods.
          );
        },
      ),
    );
  }
}
