import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddScreen extends StatefulWidget {
  static const routeName = '/home/addScreen';

  @override
  State<StatefulWidget> createState() {
    return _AddState();
  }
}

class _AddState extends State<AddScreen> {
  _Controller con; // state object
  File image; // variable to upload images
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }
  void render(fn)=> setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new Photo Demo'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.check), onPressed: con.save),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context)
                      .size
                      .width, // utilize full width screeen
                  child: image == null
                      ? Icon(
                          Icons.photo_library,
                          size: 300,
                        )
                      : Image.file(image, fit: BoxFit.fill),
                ),
                Positioned(
                  right: 0.0,
                  bottom: 0.0,
                  child: Container(
                    color: Colors.blue[200],
                    child: PopupMenuButton<String>(
                      onSelected: con.getPicture,
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          value: 'camera',
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.photo_camera),
                              Text('camera'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'gallery',
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.photo_album),
                              Text('Gallery'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

  void save() async{
    
  }

  void getPicture(String src) async {
    try {
      PickedFile _imageFile;
      if (src == 'camera') {
        _imageFile = await ImagePicker().getImage(source: ImageSource.camera);
      } else {
        _imageFile = await ImagePicker().getImage(source: ImageSource.gallery);
      }
      _state.render((){
        _state.image = File(_imageFile.path);
      });
    } catch (e) {}
  }

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
    if (value.trim().length != 0) {
      this.sharedWith = value.split('.').map((e) => e.trim()).toList();
    }
  }
}
