import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pms_frontend/pages/passwordrecovery.dart';
import '../theme/colors.dart';
import '../theme/themedata.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.white,
      body: Center( // Center everything on the screen
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
          children: [
            Image.asset(
              'lib/assets/images/Straw_innovations_small2.png',
              width: 300,
            ),
            const Padding(
              padding: EdgeInsets.all(3.0),
              child: Text(
                "Sign In",
                style: TextStyle(
                  color: ThemeColor.secondaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: SizedBox(
                width: 635,
                height: 75,
                child: TextField(
                  style: const TextStyle(
                    color: ThemeColor.primaryColor,
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    hintText: "Username",
                    hintStyle: const TextStyle(
                      color: ThemeColor.grey,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: ThemeColor.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: SizedBox(
                width: 635,
                height: 75,
                child: TextField(
                  obscureText: true,
                  style: const TextStyle(
                    color: ThemeColor.primaryColor,
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: const TextStyle(
                      color: ThemeColor.grey,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: ThemeColor.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(ThemeColor.secondaryColor),
                foregroundColor: MaterialStateProperty.all(ThemeColor.white),
                minimumSize: MaterialStateProperty.all(const Size(635, 75)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              child: const Text(
                "Register",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(45.0),
              child: Text.rich(
                TextSpan(
                  text: "Forget Password?",
                  style: const TextStyle(
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    color: ThemeColor.primaryColor,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PasswordrecoveryForm(),
                        ),
                      );
                    },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
