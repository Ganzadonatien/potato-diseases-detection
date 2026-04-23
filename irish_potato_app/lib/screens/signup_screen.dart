import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:irish_potato_app/screens/login.dart';
import 'package:irish_potato_app/widgets/custom_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool agreePersonalData = true;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(),
          ),

          Expanded(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.all(25.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),

              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      /// TITLE
                      const Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// FULL NAME
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// EMAIL
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// PASSWORD
                      TextFormField(
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Password";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// CHECKBOX
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              "I agree to the processing of Personal data",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// SIGN UP BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Account Created"),
                                ),
                              );
                            }
                          },
                          child: const Text("Sign Up"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// DIVIDER
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Sign up with"),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 10),

                      
                      Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Brand(
      Brands.google,
      size: 40,
    ),
  ],
),
const SizedBox(height: 10),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text(
      'Already have an account?',
      style: TextStyle(
        color: Colors.black45,
      ),
    ),
    const SizedBox(width: 8), // spacing
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ),
        );
      },
      child: const Text(
        'Sign In',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
)

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}