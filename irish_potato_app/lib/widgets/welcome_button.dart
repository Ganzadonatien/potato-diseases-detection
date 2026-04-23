import 'package:flutter/material.dart';
import 'package:irish_potato_app/screens/signup_screen.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({super.key, this.buttonText, this.onTap, this.color, this.textColor});
  final String? buttonText;
  final Widget? onTap;
  final Color? color; 
final Color? textColor;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (e) => onTap!,
            ),
        );
      },
      child: SizedBox(
        height: 55,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color!,
          borderRadius: BorderRadius.all( Radius.circular(50)),
        ),
        child: Text(
          buttonText!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor!,
            fontSize: 16, 
            fontWeight: FontWeight.bold),
        ),
      ),
      )
    );
  }
}
