import 'package:flutter/material.dart';
import 'package:photomemo/controller/firebasecontroller.dart';
import 'package:photomemo/screens/views/mydialog.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signInScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>(); // form key

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: SingleChildScrollView(
        child: Form(
          // form widget, need to set up a form key, "formKey"
          key: formKey, // thats the key we set up
          child: Column(
            children: <Widget>[
              Stack(
                // stacking widgeds to have it lay top of each other
                children: <Widget>[
                  // add images top of text form
                  Image.asset('assets/images/postit.jpeg'),
                  // additional custom text
                  Positioned( // wrap with widget then type Positioned to position it correctly
                  top: 150,
                  left: 110,
                    child: Text(
                      "PhotoMemo",
                      style: TextStyle(
                          color: Colors.blue[600],
                          fontFamily: 'JosefinSans',
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              TextFormField(
                // text field form for email
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: con.validatorEmail, // function
                onSaved: con.onSavedEmail, // function
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
                obscureText: true, // sucures text
                autocorrect: false,
                validator: con.validatorPassword, // function
                onSaved: con.onSavedPassword, // function
              ),
              RaisedButton(
                child: Text(
                  "Sign In",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                color: Colors.blue,
                onPressed: con.signIn, // function
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignInState _state;
  _Controller(this._state);
  String email; // valided ones will be there
  String password;

  Future<void> signIn() async {
    // when sign in is pressed
    if (!_state.formKey.currentState.validate()) {
      return; // if not valid then just return
    }

    _state.formKey.currentState
        .save(); // saves email and password by calling save function
    print('=== email: $email    password:   $password');

    try {
      var user = await FirebaseController.signIn(email, password);
      print("user: $user");
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Sign in Error',
        content: e.message ?? e.toString(),
      );
    }
  }

  String validatorEmail(String value) {
    // validating email
    if (value == null || !value.contains('@') || !value.contains('.')) {
      return 'Invalid email address';
    } else {
      return null;
    }
  }

  void onSavedEmail(String value) {
    email = value; // save it to valid variables
  }

  String validatorPassword(String value) {
    if (value == null || value.length < 6) {
      return 'Password min 6 chard';
    } else {
      return null;
    }
  }

  void onSavedPassword(String value) {
    password = value;
  }
}
