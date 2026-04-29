import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
// ignore: unused_import
import 'package:irish_potato_app/screens/dashboard.dart';
import 'package:irish_potato_app/screens/forgot_password.dart';
import 'package:irish_potato_app/screens/signup_screen.dart';
import 'package:irish_potato_app/widgets/custom_scaffold.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {


  final _formKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  bool isLoading = false;

  final email = TextEditingController();
  final password = TextEditingController();


  signin() async{
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      print('Attempting login with email: ${email.text.trim()}');
      
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );
      
      print('Login successful: ${credential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      print('Error during login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 10, 
              )
              ),
              Expanded(
                flex: 6,
                child: Container(
                
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)
                  )
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(
                          height: 60,
                        ),
                  
                     TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Email';
                      }
                      return null;
                    },
                    controller: email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter Email',
                      labelStyle: TextStyle(color: Colors.black),
                      hintStyle: TextStyle(color: Colors.black26),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(
                          height: 20,
                           ),
                  TextFormField(
                    obscureText: true,
                    obscuringCharacter: '*',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Password';
                      }
                      return null;
                    },
                    controller: password,
                    decoration: InputDecoration(
                      label: Text('Password'),
                      hintText: 'Enter Password',
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(
                        height: 20,
                     ),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         Checkbox(
                           value: rememberPassword,
                           onChanged: (bool? value) {
                             setState(() {
                               rememberPassword = value!;
                             });
                           },
                           
                         ),
                         const Text('Remember Password',
                         style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                         ),),
                  
                         GestureDetector(
                        onTap: () {
                           Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                       ],
                     ),
                     SizedBox(
                        height: 20,
                     ),
                    SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: isLoading ? null : () {
      if (_formKey.currentState!.validate()) {
        signin();
      }
    },
    child: isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Text('Sign In'),
   
  ),
),

SizedBox(
                        height: 20,
                     ),

                     Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Expanded(
      child: Divider(
        color: Colors.black26,
        thickness: 1,
      ),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: const Text(
        'OR Sign In with',
        style: TextStyle(
          color: Colors.black26,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    const Expanded(
      child: Divider(
        color: Colors.black26,
        thickness: 1,
      ),
    ),
  ],
),
SizedBox(
        height: 15,
        ),

     Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Brand(
      Brands.google,
      size: 40,
    ),
  ],
),
SizedBox(
        height: 20,
        ),

        Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text(
      'Don\'t have an account?',
      style: TextStyle(
        color: Colors.black45,
      ),
    ),
    const SizedBox(width: 8), 
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignUpScreen(),
          ),
        );
      },
      child: const Text(
        'Sign Up',
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
              ))
        ],
      )
    );
  }
}