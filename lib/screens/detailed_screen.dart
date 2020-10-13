import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/model/photomemo.dart';
import 'package:photomemo/screens/views/mydialog.dart';
import 'package:photomemo/screens/views/myimageview.dart';

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack( // using stack to have multiple container, one for the image and the other one for the button
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context)
                      .size
                      .width, // uses full width image size
                  child:
                     // Image.network(photoMemo.photoURL), // picks the image url
                     MyImageView.network(imageUrl: photoMemo.photoURL, context: context),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    color: Colors.grey,
                    child: IconButton(
                      icon: Icon(Icons.label),
                      onPressed: con.showImageLabels, // calls the function 
                    ),
                  ),
                ),
              ],
            ),
            Text(
              photoMemo.title,
              style: TextStyle(fontSize: 20.0), // display title
            ),
            Text(
              photoMemo.memo,
              style: TextStyle(fontSize: 16), // display notes memo
            ),
            Text('Created By: ${photoMemo.createdBy}'),
            Text('Updated At: ${photoMemo.updatedAt}'),
            Text('Shared With: ${photoMemo.sharedWith}'),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  _DetailedState _state;
  _Controller(this._state);

  void showImageLabels() {
    MyDialog.info(
      context: _state.context,
      title: 'Image labels by ML',
      content: _state.photoMemo.imageLabels.toString(),

    );
  }
}
