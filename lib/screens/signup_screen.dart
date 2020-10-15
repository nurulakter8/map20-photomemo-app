import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget{
  static const routeName = '/signInScreen/signUpScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignUpState();

  }

}

class _SignUpState extends State <SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create an account'),
      ),
    );
  }

}