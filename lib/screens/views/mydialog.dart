import 'package:flutter/material.dart';

class MyDialog { // to show dialog error better way

  static void circularPrpgressStart(BuildContext context){
    showDialog(context: context, builder: (context) => Center(child: CircularProgressIndicator()));
  }

  static void circularProgressEnd(BuildContext context){
    Navigator.pop(context);
  }
  
  static void info({BuildContext context, String title, String content}) {
    showDialog(
        barrierDismissible:
            false, // dialog box cannot be clicked outside to dispose
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }
}
