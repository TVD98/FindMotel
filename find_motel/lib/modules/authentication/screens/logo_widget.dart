import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/logo.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          Positioned(
            bottom: 0,
            child: Image.asset(
              'assets/logowelcom.png',
              width: 191,
              height: 48,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}
