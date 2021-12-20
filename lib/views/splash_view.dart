import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_chat_parser/main.dart';
import 'package:flutter_whatsapp_chat_parser/utils/size_config.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    if (mounted) {
      Future.delayed(Duration(seconds: 2), () async {
        animationController.forward().then((value) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MyHomePage()));
          });
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/parserlogo.png'),
              width: SizeConfig.width(100),
            ),
            SizedBox(
              height: SizeConfig.height(32),
            ),
            SizeTransition(
              sizeFactor: animation,
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Whatsapp',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: SizeConfig.textSize(20),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.height(16),
                    ),
                    Text(
                      'Chat parser',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF999999),
                        fontWeight: FontWeight.w400,
                        fontSize: SizeConfig.textSize(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
