import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:irish_potato_app/screens/signup_screen.dart';
import 'package:irish_potato_app/theme/theme.dart';
import 'package:irish_potato_app/widgets/custom_scaffold.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool rememberPassword = true;
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
                    decoration: InputDecoration(
                      label: const Text('Password'),
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
                          // Add your "Forget password?" navigation logic here
                          print('Navigate to Forget Password screen');
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
    onPressed: () {
      if (_formKey.currentState!.validate() && rememberPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing Data'),
          ),
        );
      } else if (!rememberPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please agree to the processing of personal data.',
            ),
          ),
        );
      }
    },
    child: const Text('Sign In'),
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