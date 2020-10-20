import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/model/photomemo.dart';

class FirebaseController {
  // controller to read all the documents

  static Future signIn(String email, String password) async {
    AuthResult auth = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return auth.user;

  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    
  }

  static Future<List<PhotoMemo>> getPhotoMemos(String email) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(PhotoMemo.COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .orderBy(PhotoMemo.UPDATED_AT, descending: true)
        .getDocuments(); // this way we read all the documents from fire base

    var result =
        <PhotoMemo>[]; // get from fire store and include in list of obj
    if (querySnapshot != null && querySnapshot.documents.length != 0) {
      for (var doc in querySnapshot.documents) {
        result.add(PhotoMemo.deserialize(doc.data, doc.documentID));
      }
    }
    return result;
  }

  static Future<Map<String, String>> uploadStorage({
    @required File image,
    String filePath,
    @required String uid,
    @required List<dynamic> sharedWith,
    @required Function listner,
  }) async {
    filePath ??= '${PhotoMemo.IMAGE_FOLDER}/$uid/${DateTime.now()}';
    StorageUploadTask task =
        FirebaseStorage.instance.ref().child(filePath).putFile(image);

    task.events.listen((event) {
      double percentage = (event.snapshot.bytesTransferred.toDouble() /
              event.snapshot.totalByteCount.toDouble()) *
          100;
      listner(percentage);
    });
    var download = await task.onComplete;
    String url = await download.ref.getDownloadURL();
    return {'url': url, 'path': filePath};
  }

  static Future<String> addPhotoMemo(PhotoMemo photoMemo) async {
    photoMemo.updatedAt = DateTime.now();
    DocumentReference ref = await Firestore.instance
        .collection(PhotoMemo.COLLECTION)
        .add(photoMemo.serialized());
    return ref.documentID;
  }

  static Future<List<dynamic>> getImageLabels(File imageFile) async {
    //ML kit
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);
    ImageLabeler cloudLabeler = FirebaseVision.instance.cloudImageLabeler();
    List<ImageLabel> cloudLabels = await cloudLabeler.processImage(visionImage);

    var labels = <String>[];
    for (ImageLabel label in cloudLabels) {
      String text = label.text
          .toLowerCase(); // we can only search by lowercase case of that
      double confidence = label.confidence;
      if (confidence >= PhotoMemo.MIN_CONFIDENCE) labels.add(text);
    }
    cloudLabeler.close();
    return labels;
  }

  static Future<void> deletePhotoMemo(PhotoMemo photoMemo) async {
    // deletes from firebase storage
    await Firestore.instance
        .collection(PhotoMemo.COLLECTION)
        .document(photoMemo.docId)
        .delete();
    await FirebaseStorage.instance.ref().child(photoMemo.photoPath).delete();
  }

  static Future<List<PhotoMemo>> searchImages({
    // searches images based on labels
    @required String email,
    @required String imageLabel,
  }) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(PhotoMemo.COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .where(PhotoMemo.IMAGE_LABELS,
            arrayContains: imageLabel
                .toLowerCase()) // change to lower case as well to match search with labels
        .orderBy(PhotoMemo.UPDATED_AT, descending: true)
        .getDocuments();

    var result = <PhotoMemo>[];
    if (querySnapshot != null && querySnapshot.documents.length != 0) {
      for (var doc in querySnapshot.documents) {
        result.add(PhotoMemo.deserialize(doc.data, doc.documentID));
      }
    }
    return result;
  }

//edit photo and update on firebase storage
  static Future<void> updatePhotoMemo(PhotoMemo photoMemo) async {
    photoMemo.updatedAt = DateTime.now();
    await Firestore.instance
        .collection(PhotoMemo.COLLECTION)
        .document(photoMemo.docId)
        .setData(photoMemo.serialized());
  }

  // to share all the docs
  static Future<List<PhotoMemo>> getPhotoMemosSharedWithMe(String email) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(PhotoMemo.COLLECTION)
        .where(PhotoMemo.SHARED_WITH, arrayContains: email)
        .orderBy(PhotoMemo.UPDATED_AT, descending: true)
        .getDocuments();

    var result = <PhotoMemo>[];
    if (querySnapshot != null && querySnapshot.documents.length != 0) {
      for (var doc in querySnapshot.documents) {
        result.add(PhotoMemo.deserialize(doc.data, doc.documentID));
      }
    }
    return result;
  }

  // for sign up
  static Future<void> signUp(String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> updateProfile({
    @required File image, // null no update needed
    @required String displayName,
    @required FirebaseUser user,
    @required Function progressListner,
  }) async{
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = displayName;

    if(image!= null){
      String filePath = '${PhotoMemo.PROFILE_FOLDER}/${user.uid}/${user.uid}';
      StorageUploadTask uploadTask = 
      FirebaseStorage.instance.ref().child(filePath).putFile(image);

      uploadTask.events.listen((event) {
        double percentage = (event.snapshot.bytesTransferred.toDouble() /
        event.snapshot.totalByteCount.toDouble()) * 100;
        progressListner(percentage);

      });

      var download = await uploadTask.onComplete;
      String url = await download.ref.getDownloadURL();

      updateInfo.photoUrl = url;

    }
    await user.updateProfile(updateInfo);
  }
}
