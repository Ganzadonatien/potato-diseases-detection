import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set the color of the back button icon
        ),
        backgroundColor: Colors.transparent,
         elevation: 0
         ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/irishbg.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
           SafeArea(
            child: child!,
            ),
        ],
      ),
    );
    ;
  }
}
