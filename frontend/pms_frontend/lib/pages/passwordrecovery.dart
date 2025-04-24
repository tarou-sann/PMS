import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/themedata.dart';
import 'signup.dart';

class PasswordrecoveryForm extends StatelessWidget {
  const PasswordrecoveryForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.white,
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpForm(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.secondaryColor,
                          size: 50,
                        ),
                      ),
                      const Text(
                        "Forget Password",
                        style: TextStyle(
                          color: ThemeColor.secondaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 48,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
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
                    TextButton(
                      onPressed: () {
                      Navigator.push(
                        context,
                         MaterialPageRoute(
                          builder: (context) => const SecurityModule(), // Fix the misplaced closing parenthesis
                             ),
                            );
                          },
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
                        "Confirm",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SecurityModule extends StatelessWidget {
  const SecurityModule({super.key});

  static const securityQuestion = "test question";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.white,
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PasswordrecoveryForm(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.secondaryColor,
                          size: 50,
                        ),
                      ),
                      const Text(
                        "Forget Password",
                        style: TextStyle(
                          color: ThemeColor.secondaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 48,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                      child: Container(
                        width: 635,
                        height: 60,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ThemeColor.grey,
                            width: 1.0
                          ),
                          borderRadius: BorderRadius.circular(9)
                        ),
                        child: 
                       const  Padding (
                          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(
                            securityQuestion,
                            style: TextStyle(
                              fontSize: 20,
                              color: ThemeColor.primaryColor
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 635,
                      height: 75,
                      child: TextField(
                        style: const TextStyle(
                          color: ThemeColor.primaryColor,
                          fontSize: 20,
                        ),
                        decoration: InputDecoration(
                          hintText: "Answer",
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
                        "Confirm",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
