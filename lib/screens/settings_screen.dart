import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photomemo/controller/firebasecontroller.dart';
import 'package:photomemo/screens/views/mydialog.dart';
import 'package:photomemo/screens/views/myimageview.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/homeScreen/settignsScreen';
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<SettingsScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();
  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    user ??= ModalRoute.of(context).settings.arguments; // firebase user
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
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
              Text(
                'Change Profile Picture',
                style: TextStyle(fontSize: 20),
              ),
              Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: con.imageFile == null
                        ? MyImageView.network(
                            imageUrl: user.photoUrl, context: context)
                        : Image.file(
                            con.imageFile,
                            fit: BoxFit.fill,
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
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
                            value: 'gallery',
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
              con.progressMessage == null
                  ? SizedBox(
                      height: 1,
                    )
                  : Text(con.progressMessage, style: TextStyle(fontSize: 20)),
              TextFormField(
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Display Name',
                ),
                initialValue: user.displayName ?? 'N/A',
                autocorrect: false,
                validator: con.validatorDisplayName,
                onSaved: con.onSavesDisplayName,
              ),
              TextFormField(
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Bio',
                ),
                //initialValue: user.displayBio?? 'Bio..',
                autocorrect: false,
                validator: con.validatorDisplayBio,
                onSaved: con.onSavesDisplayBio,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SettingsState _state;

  String progressMessage;

  String displayName;
  String displayBio;
  File imageFile;
   File _cropped; // for cropped image
  _Controller(this._state);

  void save() async {
    if (!_state.formKey.currentState.validate()) return;

    _state.formKey.currentState.save();

    try {
      await FirebaseController.updateProfile(
        image: imageFile,
        displayName: displayName,
        displayBio: displayBio,
        user: _state.user,
        progressListner: (double percentage) {
          _state.render(() {
            progressMessage = 'Uploding ${percentage.toStringAsFixed(1)}';
          });
        },
      );
      Navigator.pop(_state.context);
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'profile update error',
        content: e.message ?? e.toString(),
      );
    }
  }

  void getPicture(String src) async {
    try {
      PickedFile _image;
      if (src == 'camera') {
        _image = await ImagePicker().getImage(source: ImageSource.camera);
      } else
        _image = await ImagePicker().getImage(source: ImageSource.gallery);
        if (_image != null){
           _cropped = await ImageCropper.cropImage(
          sourcePath: _image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarColor: Colors.deepOrange,
              toolbarTitle: 'Image Cropper',
              statusBarColor: Colors.blue,
              backgroundColor: Colors.white),
        );
        }
      _state.render(() => imageFile = File(_cropped.path));
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Image capture error',
        content: e.message ?? e.toString(),
      );
    }
  }

  String validatorDisplayName(String value) {
    if (value.length < 2)
      return 'min 2 chars';
    else
      return null;
  }

  void onSavesDisplayName(String value) {
    this.displayName = value;
  }
  String validatorDisplayBio(String value) {
    if (value.length < 2)
      return 'min 2 chars';
    else
      return null;
  }

  void onSavesDisplayBio(String value) {
    this.displayBio = value;
  }
}
