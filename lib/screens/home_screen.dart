import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/controller/firebasecontroller.dart';
import 'package:photomemo/model/photomemo.dart';
import 'package:photomemo/screens/add_screens.dart';
import 'package:photomemo/screens/detailed_screen.dart';
import 'package:photomemo/screens/signin_screen.dart';
import 'package:photomemo/screens/views/mydialog.dart';
import 'package:photomemo/screens/views/myimageview.dart';

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
  var formKey = GlobalKey<FormState>(); // form key object

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
            actions: <Widget>[
              Container( // container to add the search form, we are not searching by title or memos
              width: 180.0,             
                child: Form(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Image search',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    autocorrect: false,
                    onSaved: con.onSavedSearchKey,
                  ),
                  key: formKey,
                ),
              ),
              con.delIndex == null
                  ? IconButton(
                      icon: Icon(Icons.search), // if null show search
                      onPressed: con.search,
                    )
                  : IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: con
                          .delete, // delete function to delete selected listtile
                    ),
            ],
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
                  itemBuilder: (BuildContext context, int index) => Container(
                    // wrapping with container for color on listtile
                    color: con.delIndex != null && con.delIndex == index
                        ? Colors.red[200]
                        : Colors
                            .white, // on long press it will turn red to delete
                    child: ListTile(
                      //leading: Image.network(photoMemos[index].photoURL),
                      leading: MyImageView.network(
                          imageUrl: photoMemos[index].photoURL,
                          context:
                              context), // progress indicator based on how big is each image.
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
                      onTap: () => con.onTap(
                          index), // on tap funtion, part of listtile. goes to detailed page
                      onLongPress: () => con.onLongPress(
                          index), // on long press we will permently delete the index
                    ),
                  ),
                )),
    );
  }
}

class _Controller {
  _HomeState _state;
  int delIndex; // index count for deleting, initially its null value
  String searchKey; // to save whatever is typed
  _Controller(this._state);

  void onSavedSearchKey(String value){
    searchKey = value;
  }
  void search() {
    _state.formKey.currentState.save(); // whatever is typed we need to save first
    //print(searchKey);
    //now we can call function 
    

  }
 
  void delete() async {
    try {
      PhotoMemo photoMemo = _state.photoMemos[delIndex];
      await FirebaseController.deletePhotoMemo(
          photoMemo); // calls firbasecontroller delete function
      _state.render(() {
        // inside render to refresh
        _state.photoMemos.removeAt(delIndex);
      });
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Delete Photomemo Error',
        content: e.message ?? e.toString(),
      );
    }
  }

  void onLongPress(int index) {
    // this state needs to be inside of render to draw and effect
    _state.render(() {
      delIndex = (delIndex == index ? null : index);
    });
  }

  void onTap(int index) {
    // have to have index to know which one we are pressing.
    // print ('++++++ $index');
    if (delIndex != null) {
      // cancel delete mode
      _state.render(() => delIndex = null);
      return;
    }
    Navigator.pushNamed(_state.context, DetailedScreen.routeName, arguments: {
      'user': _state.user,
      'photoMemo': _state.photoMemos[index]
    });
  }

  void addButton() async {
    // navigate to add screen
    await Navigator.pushNamed(_state.context, AddScreen.routeName,
        arguments: {'user': _state.user, 'photoMemoList': _state.photoMemos});

    _state.render(() {}); // redraw the screen
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
