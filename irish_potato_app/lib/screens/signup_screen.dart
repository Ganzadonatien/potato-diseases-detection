import 'package:flutter/material.dart';
import 'package:irish_potato_app/screens/login.dart';
import 'package:irish_potato_app/widgets/custom_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irish_potato_app/screens/dashboard.dart';
import 'package:irish_potato_app/models/location.dart';
import 'package:irish_potato_app/models/user_profile.dart';
import 'package:irish_potato_app/services/firestore_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  bool isLoading = false;

  TextEditingController fullname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  String selectedRole = 'farmer';
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSector;

  Future<void> signup() async {
    if (!_formKey.currentState!.validate() || !agreePersonalData) return;

    setState(() => isLoading = true);

    try {
      print('=== SIGNUP START ===');
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.text.trim(),
            password: password.text,
          );
      print('Auth user created: ${credential.user!.uid}');

      await credential.user?.updateDisplayName(fullname.text.trim());
      print('Display name updated');

      final userId = credential.user!.uid;
      final profile = UserProfile(
        uid: userId,
        fullName: fullname.text.trim(),
        email: email.text.trim(),
        role: selectedRole,
        approved: selectedRole != 'agronomist',
        province: selectedProvince ?? '',
        district: selectedDistrict ?? '',
        sector: selectedSector ?? '',
        createdAt: DateTime.now().toUtc(),
      );
      print('Profile object created: ${profile.toJson()}');
      
      await FirestoreService().saveUserProfile(profile);
      print('Firestore save completed successfully');

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainDashboard()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e, stackTrace) {
      print('ERROR during signup: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
          Expanded(flex: 2, child: SizedBox()),

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
                        controller: fullname,
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
                        controller: email,
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
                        controller: password,
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

                      const SizedBox(height: 15),

                      /// ROLE
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: InputDecoration(
                          labelText: "Role",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'farmer',
                            child: Text('Farmer'),
                          ),
                          DropdownMenuItem(
                            value: 'agronomist',
                            child: Text('Agronomist'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value ?? 'farmer';
                          });
                        },
                      ),

                      if (selectedRole == 'agronomist') ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Agronomist accounts require admin approval before full access.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 15),

                      /// PROVINCE DROPDOWN
                      DropdownButtonFormField<String>(
                        initialValue: selectedProvince,
                        decoration: InputDecoration(
                          labelText: "Province",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: LocationData.getProvinces().map((province) {
                          return DropdownMenuItem(
                            value: province,
                            child: Text(province),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProvince = value;
                            selectedDistrict = null;
                            selectedSector = null;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Select a Province";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      /// DISTRICT DROPDOWN
                      DropdownButtonFormField<String>(
                        initialValue: selectedDistrict,
                        decoration: InputDecoration(
                          labelText: "District",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: selectedProvince != null
                            ? LocationData.getDistrictsByProvince(
                                selectedProvince!,
                              ).map((district) {
                                return DropdownMenuItem(
                                  value: district,
                                  child: Text(district),
                                );
                              }).toList()
                            : [],
                        onChanged: selectedProvince != null
                            ? (value) {
                                setState(() {
                                  selectedDistrict = value;
                                  selectedSector = null;
                                });
                              }
                            : null,
                        validator: (value) {
                          if (selectedProvince != null &&
                              (value == null || value.isEmpty)) {
                            return "Select a District";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      /// SECTOR DROPDOWN
                      DropdownButtonFormField<String>(
                        initialValue: selectedSector,
                        decoration: InputDecoration(
                          labelText: "Sector",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items:
                            selectedProvince != null && selectedDistrict != null
                            ? LocationData.getSectorsByDistrict(
                                selectedProvince!,
                                selectedDistrict!,
                              ).map((sector) {
                                return DropdownMenuItem(
                                  value: sector,
                                  child: Text(sector),
                                );
                              }).toList()
                            : [],
                        onChanged:
                            selectedProvince != null && selectedDistrict != null
                            ? (value) {
                                setState(() {
                                  selectedSector = value;
                                });
                              }
                            : null,
                        validator: (value) {
                          if (selectedDistrict != null &&
                              (value == null || value.isEmpty)) {
                            return "Select a Sector";
                          }
                          return null;
                        },
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
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate() &&
                                      agreePersonalData) {
                                    signup();
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
                              : const Text("Sign Up"),
                          //child : const Text("Sign Up"),
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
                          Icon(
                            Icons.g_mobiledata,
                            size: 40,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(color: Colors.black45),
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
                      ),
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
