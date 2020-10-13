import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/controller/firebasecontroller.dart';
import 'package:photomemo/model/photomemo.dart';
import 'package:photomemo/screens/add_screens.dart';
import 'package:photomemo/screens/detailed_screen.dart';
import 'package:photomemo/screens/signin_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/signInScreen/homeScreen';

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomeScreen> {
  _Controller con;
  FirebaseUser user;
  List<PhotoMemo> photoMemos;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    user ??= arg['user'];
    photoMemos ??= arg['photoMemoList'];

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
          appBar: AppBar(
            title: Text('Home'),
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(user.displayName ?? 'N/A'),
                  accountEmail: Text(user.email),
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Sign out'),
                  onTap: con.signOut,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: con.addButton,
            child: Icon(Icons.add),
          ),
          body: photoMemos.length == 0
              ? Text('No Photo Memo', style: TextStyle(fontSize: 30.0))
              : ListView.builder(
                  itemCount: photoMemos.length,
                  itemBuilder: (BuildContext context, int index) => ListTile(
                    leading: Image.network(photoMemos[index].photoURL),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    title: Text(photoMemos[index].title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Created by: ${photoMemos[index].createdBy}'),
                        Text('Shared With: ${photoMemos[index].sharedWith}'),
                        Text('Updated at: ${photoMemos[index].updatedAt}'),
                        Text(photoMemos[index].memo),
                      ],
                    ),
                    onTap: () => con.onTap(index),
                  ),
              
                )),
    );
  }
}

class _Controller {
  _HomeState _state;
  _Controller(this._state);

  void onTap(int index){ // have to have index to know which one we are pressing.
   // print ('++++++ $index');
   Navigator.pushNamed(_state.context, DetailedScreen.routeName,
   arguments: {'user': _state.user, 'PhotoMemo': _state.photoMemos[index]});

  }

  void addButton() async{
    // navigate to add screen
   await Navigator.pushNamed(_state.context, AddScreen.routeName,
        arguments: {'user': _state.user, 'photoMemoList': _state.photoMemos});

        _state.render((){}); // redraw the screen
  }

  void signOut() async {
    try {
      await FirebaseController.signOut();
    } catch (e) {
      print('signOut exception: ${e.message}');
    }
    Navigator.pushReplacementNamed(_state.context, SignInScreen.routeName);
  }
}
