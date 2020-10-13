import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/model/photomemo.dart';

class DetailedScreen extends StatefulWidget {
  static const routeName = '/homeScreen/detailedScreen';
  @override
  State<StatefulWidget> createState() {
    return _DetailedState();
  }
}

class _DetailedState extends State<DetailedScreen> {
  _Controller con;
  FirebaseUser user;
  PhotoMemo photoMemo;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {

    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args['user'];
    photoMemo ??= args['photoMemo'];
    

    return Scaffold( 
      appBar: AppBar(
        title: Text('Detailed View'),
      ),
      body: Text('body'),
    );
  }
}

class _Controller {
  _DetailedState _state;
  _Controller(this._state);
}
