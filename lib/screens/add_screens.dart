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
      body: Text('body'),
    );
  }
}


class _Controller {
  _AddState _state;
  _Controller (this._state);

}
