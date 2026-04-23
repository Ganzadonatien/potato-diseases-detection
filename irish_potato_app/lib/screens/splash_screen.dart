// import 'package:flutter/material.dart';
// import 'dart:async';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();

//     // ⏳ Wait 3 seconds then navigate
//     Timer(const Duration(seconds: 3), () {
//       // 👉 Replace with your next screen
//       // Navigator.pushReplacement(context,
//       //   MaterialPageRoute(builder: (_) => LoginPage()));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color.fromARGB(255, 227, 255, 229),
//               Color.fromARGB(255, 7, 53, 10),
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 🌱 Image
//             Image.asset('assets/potato.png', height: 150),

//             const SizedBox(height: 30),

//             // 📝 Title
//             const Text(
//               'AI-POTATO LEAF DISEASES\nDETECTION',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.2,
//               ),
//             ),

//             const SizedBox(height: 60),

//             // 🔐 Login Button
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey,
//                 foregroundColor: Colors.black,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 80,
//                   vertical: 15,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               onPressed: () {},
//               child: const Text('Login'),
//             ),

//             const SizedBox(height: 20),

//             // ➕ Sign Up Button
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey,
//                 foregroundColor: Colors.black,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 70,
//                   vertical: 15,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               onPressed: () {},
//               child: const Text('Sign Up'),
//             ),

//             const SizedBox(height: 30),

//             // ⏳ Loading
//             const Text(
//               'Loading ...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontFamily: 'GoogleFonts.poppins',
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:irish_potato_app/screens/login.dart';
import 'package:irish_potato_app/screens/signup_screen.dart';
import 'package:irish_potato_app/widgets/custom_scaffold.dart';
import 'package:irish_potato_app/widgets/welcome_button.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
             flex: 3,
            child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 20),
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'WELCOME TO\n',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'AI-potato leaf diseases detection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],

                ),),
            ),
          ),),
        Flexible(
          flex: 3,
  child:Align(
    
    child: Padding(
      padding: EdgeInsets.only(bottom: 150),
  child: Row( 
    children: [
Expanded(
  child: Padding(
    padding: EdgeInsets.only(left: 8, right: 15, top: 18, bottom: 18),
    child: WelcomeButton(
      buttonText: 'Sign In',
      onTap: SignInScreen(),
  color: Colors.white.withValues(alpha: 0.3),
  textColor: const Color.fromARGB(255, 2, 18, 25),
    ),
  ),

),
Expanded(
  child: Padding(
    padding: EdgeInsets.only(left: 15, right: 8),
    child: WelcomeButton(
      buttonText: 'Sign up',
      onTap: SignUpScreen(),
  color: Colors.white.withValues(alpha: 0.3),
  textColor: const Color.fromARGB(255, 1, 18, 26),
    ),
  ),

),
    ],
  ),
  ),  
),
       ) ],
      )  
    );
  }
}