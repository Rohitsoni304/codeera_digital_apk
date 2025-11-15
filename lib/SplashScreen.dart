import 'dart:async';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';



class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 🎬 Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // 🔹 Slide animation (bottom → center)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutExpo,
      ),
    );

    // 🔹 Scale animation (small → normal)
    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    // 🔹 Fade animation (transparent → visible)
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // ▶️ Start animation after small delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });

    // ⏰ Navigate to next screen after 3 seconds
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginWithOtpScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 240, 240, 1.0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌄 Background image

          // ✨ Animated content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: child,
                  ),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🖼 Logo
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container( height: size.height * 0.1,width:size.width*0.2 ,
                      child: Image.asset(
                        "assets/images/codeera-logo.png",

                      ),
                    ),

                    Text("CODEERA TECHNOLOGY",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
                  ],
                ),
                const SizedBox(height: 30),

                // 📝 Text
        AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'INNOVATE | AUTOMATE | SUCCEED',
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              speed: const Duration(milliseconds: 90),
              textAlign: TextAlign.center,
            ),
          ],
          totalRepeatCount: 1,
          pause: const Duration(milliseconds: 500),
          displayFullTextOnTap: true,
          stopPauseOnTap: true,
        ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}