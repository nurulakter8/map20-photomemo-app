import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
  static const routeName = '/home/addScreen';

  @override
  State<StatefulWidget> createState() {
    return _AddState();
  }
}

class _AddState extends State<AddScreen> {
  _Controller con; // state object
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new Photo Demo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Title',
              ),
              autocorrect: true,
              validator: con.validatorTitle,
              onSaved: con.onSavedTitle,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Memo',
              ),
              autocorrect: true,
              keyboardType: TextInputType.multiline,
              maxLines: 7,
              validator: con.validatorMemo,
              onSaved: con.onSavedMemo,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'SharedWith (comma sperated email list)',
              ),
              autocorrect: true,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              validator: con.validatorSharedWith,
              onSaved: con.onSavedSharedWith,
            ),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  _AddState _state;
  _Controller(this._state);
  String title;
  String memo;
  List<String> sharedWith = [];

  String validatorTitle(String value) {
    if (value == null || value.trim().length < 2) {
      return 'min 2 chars';
    } else {
      return null;
    }
  }

  void onSavedTitle(String value) {
    this.title = value;
  }

  String validatorMemo(String value) {
    if (value == null || value.trim().length < 3) {
      return 'min 3 chars';
    } else {
      return null;
    }
  }

  void onSavedMemo(String value) {
    this.memo = value;
  }

  String validatorSharedWith(String value) {
    if (value == null || value.trim().length == 0) return null;

    List<String> emailList = value
        .split(',')
        .map((e) => e.trim())
        .toList(); // conver one single long string sperated with comma
    for (String email in emailList) {
      if (email.contains('@') && email.contains('.'))
        continue;
      else
        return 'Comma(,) sperated email list';
    }
    return null;
  }

  void onSavedSharedWith(String value) {
    if (value.trim().length != 0){
      this.sharedWith = value.split('.').map((e) => e.trim()).toList();
    }
  }
}
