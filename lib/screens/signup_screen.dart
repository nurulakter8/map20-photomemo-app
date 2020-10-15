import 'package:flutter/material.dart';
import 'package:photomemo/controller/firebasecontroller.dart';
import 'package:photomemo/screens/views/mydialog.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signInScreen/signUpScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create an account'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              Text(
                'Create an account',
                style: TextStyle(fontSize: 25),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: con.validatorEmail,
                onSaved: con.onSavedEmail,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
                obscureText: true,
                autocorrect: false,
                validator: con.validatorPassword,
                onSaved: con.onSavedPassword,
              ),
              RaisedButton(
                  child: Text(
                    'Create',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    
                  ),
                  color: Colors.blue,
                  onPressed: con.signUp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignUpState _state;
  _Controller(this._state);
  String email;
  String password;


  void signUp() async{
    if(!_state.formKey.currentState.validate()) return;

    _state.formKey.currentState.save();

    try {
      await FirebaseController.signUp(email, password);
      MyDialog.info(
        context: _state.context,
        title: 'Successfully created',
        content: 'Your account is created! Go to to Sign In',
      );
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error',
        content: e.message ?? e.toString(),
      );
    }
  }

  String validatorEmail(String value) {
    if (value.contains('@') && value.contains('.')) return null;
    else return 'Invalied Email';
  }

  void onSavedEmail(String value) {
    this.email = value;
  }

  String validatorPassword(String value) {
    if(value.length < 6) return 'min 6 chars';
    else return null;
  }

  void onSavedPassword(String value) {
    this.password = value;
  }
}
