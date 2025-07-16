import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:octo_image/octo_image.dart';
import '../../../rehmat.dart';

class Onboarding extends StatefulWidget {
  
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {

  Widget? background;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          OctoImage(
            image: AssetImage('assets/images/onboarding-light.jpg'),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            imageBuilder: (context, child) {
              return Stack(
                children: [
                  child,
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.black.withValues(alpha: 0)],
                          stops: [0.4, 0.65]
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstOut,
                      child: child
                    )
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black
                        ],
                        stops: [
                          0, 1
                        ]
                      )
                    ),
                  )
                ],
              );
            },
          ),
          if (app.remoteConfig.enableAnonymousLogin) Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                right: 6
              ),
              child: Button(
                onPressed: () async {
                  try {
                    await AuthState.of(context).signInAnonymously();
                  } catch (e) {
                    Alerts.dialog(
                      context,
                      title: 'Error',
                      content: 'There was an error signing in. Please try again later'
                    );
                  }
                },
                autoLoading: true,
                child: Text('Skip'),
                backgroundColor: Colors.transparent,
                textColor: Colors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6
                ),
              ),
            ),
          ),
          Column(
            children: [
              Spacer(),
              Text(
                'Render Studio',
                style: GoogleFonts.instrumentSerif(
                  fontSize: 48,
                  color: Colors.white,
                  height: 0.77
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18
                ),
                child: Text(
                  'Create beautifully designed social media posts, stories, and more with AI powered design tools',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontFamily: 'SF Pro Rounded'
                  ),
                ),
              ),
              buttonBuilder(
                label: 'Continue with Apple',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                icon: RenderIcons.apple,
                onPressed: () async {
                  try {
                    await AuthState.of(context).signInWithApple();
                  } catch (e) {
                    Alerts.dialog(
                      context,
                      title: 'Error',
                      content: 'There was an error signing in. Please try again later'
                    );
                  }
                }
              ),
              SizedBox(
                height: 12
              ),
              buttonBuilder(
                label: 'Continue with Google',
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                icon: RenderIcons.google,
                onPressed: () async {
                  try {
                    await AuthState.of(context).signInWithGoogle();
                  } catch (e) {
                    Alerts.dialog(
                      context,
                      title: 'Unable to sign in',
                      content: 'There was an error signing in with Google. Please try again later'
                    );
                  }
                },
              ),
              SizedBox(
                height: 12
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24
                ),
                child: Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontFamily: 'SF Pro Rounded'
                  ),
                ),
              ),
              SizedBox(
                height: Constants.of(context).bottomPadding
              ),
            ],
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
    );
  }

  Widget buttonBuilder({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
    required void Function() onPressed
  }) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 12
    ),
    child: Row(
      children: [
        Expanded(
          child: RawButton(
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: textColor,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(label),
              ],
            ),
            backgroundColor: backgroundColor,
            textColor: textColor,
            autoLoading: true,
          ),
        )
      ],
    ),
  );

}