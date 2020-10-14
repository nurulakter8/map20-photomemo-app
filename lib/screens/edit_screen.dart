import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photomemo/controller/firebasecontroller.dart';
import 'package:photomemo/model/photomemo.dart';
import 'package:photomemo/screens/views/mydialog.dart';
import 'package:photomemo/screens/views/myimageview.dart';

class EditScreen extends StatefulWidget {
  static const routeName = '/detailedScreen/editScreen';
  @override
  State<StatefulWidget> createState() {
    return _EditState();
  }
}

class _EditState extends State<EditScreen> {
  _Controller con;
  PhotoMemo photoMemo;
  FirebaseUser user;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args['user']; // can't have any typo
    photoMemo ??= args['photoMemo'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit PhotoMemo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: con.save,
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                // using stack to lay multiple things
                children: <Widget>[
                  Container(
                    // loads the current null image
                    width: MediaQuery.of(context).size.width,
                    child: con.imageFile == null
                        ? MyImageView.network(
                            imageUrl: photoMemo.photoURL, context: context)
                        : Image.file(
                            con.imageFile,
                            fit: BoxFit.fill,
                          ),
                  ),
                  Positioned(
                    // wrap with postioned widget to postion the button
                    right: 0,
                    bottom: 0,
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
                                Text('Camera'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'Gallery',
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.photo_library),
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
                // edit title
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Title',
                ),
                initialValue: photoMemo.title,
                autocorrect: true,
                validator: con.validatorTitle,
                onSaved: con.onSavedTitle,
              ),
              TextFormField(
                // edit memo
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter Memo',
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 7,
                initialValue: photoMemo.memo,
                autocorrect: true,
                validator: con.validatorMemo,
                onSaved: con.onSavedMemo,
              ),
              TextFormField(
                // edit shared with
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Shared With',
                ),
                initialValue: photoMemo.sharedWith.join(','),
                autocorrect: false,
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                validator: con.validatorSharedWith,
                onSaved: con.onSavedSharedWith,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _EditState _state;
  File imageFile; // thats when we retrive from camera or gallery
  _Controller(this._state);

  void save() async {
    if (!_state.formKey.currentState.validate()) return;

    _state.formKey.currentState.save();

    //1. if image has been changed, update Storage
    try {
      if (imageFile != null) {
        // esistance photo will be uploaded
        Map<String, String> photo = await FirebaseController.uploadStorage(
          image: imageFile,
          uid: _state.user.uid,
          sharedWith: _state.photoMemo.sharedWith,
          listner: null,
        );
        _state.photoMemo.photoPath = photo['path'];
        _state.photoMemo.photoURL = photo['url'];

        // Image labeler ML
        List<String> labels = await FirebaseController.getImageLabels(imageFile);
        _state.photoMemo.imageLabels = labels;
      }else{
        // no image chage 
      }

      await FirebaseController.updatePhotoMemo(_state.photoMemo);  // updates and saves 
      Navigator.pop(_state.context); // will go back to detailed view
    } catch (e) {

    }
    //2. save document in FireStore
  }

  String validatorSharedWith(String value) {
    if (value.trim().length == 0)
      return null; // don't want to share with anything else

    List<String> emailList = value.split(',').map((e) => e.trim()).toList();
    for (String email in emailList) {
      if (!(email.contains('@') && email.contains('.'))) {
        return 'Comma(,) separeted email list';
      }
    }
    return null;
  }

  void onSavedSharedWith(String value) {
    if (value.trim().length != 0) {
      _state.photoMemo.sharedWith =
          value.split('.').map((e) => e.trim()).toList();
    }
  }

  String validatorMemo(String value) {
    if (value.length < 3) {
      return 'Min 3 chars';
    } else {
      return null;
    }
  }

  void onSavedMemo(String value) {
    _state.photoMemo.memo = value; // change existing tittle
  }

  String validatorTitle(String value) {
    if (value.length < 2) {
      return 'Min 2 chars';
    } else {
      return null;
    }
  }

  void onSavedTitle(String value) {
    _state.photoMemo.title = value; // change existing tittle
  }

  void getPicture(String src) async {
    // uploads either a picture or takes a picture using camera
    try {
      PickedFile _imageFile;
      if (src == 'camera') {
        // pick either one
        _imageFile = await ImagePicker().getImage(source: ImageSource.camera);
      } else {
        _imageFile = await ImagePicker().getImage(source: ImageSource.gallery);
      }
      _state.render(() {
        imageFile = File(_imageFile.path);
      });
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'getPicture from Camera/gallery error',
        content: e.message ?? e.toString(),
      );
    }
  }
}
