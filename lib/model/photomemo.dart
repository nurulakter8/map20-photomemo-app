
class PhotoMemo {
// field name for firestore documents
  static const COLLECTION = 'photoMemos';
  static const IMAGE_FOLDER = 'photoMemoPictures'; // for the folder name and path vid 19
  static const TITLE = 'title';
  static const MEMO = 'memo';
  static const CREATED_BY = 'createdBy';
  static const PHOTO_URL = 'photoURL';
  static const PHOTO_PATH = 'photoPath';
  static const UPDATED_AT = 'updatedAt';

  String docId; // firebase doc id
  String createdBy;
  String title;
  String memo;
  String
      photoPath; // path to cloud store will be stored here, firebase storage, image file name
  String photoURL; // fire base storage; image URL for internet access
  DateTime updatedAt; // created or revised time

  PhotoMemo({
    // defult constructor
    this.docId,
    this.createdBy,
    this.title,
    this.memo,
    this.photoPath,
    this.photoURL,
    this.updatedAt,
  });
// conver dart object to firestore document
  Map<String, dynamic> serialized() {
    // transfer it to map data
    return <String, dynamic>{
      TITLE: title,
      CREATED_BY: createdBy,
      MEMO: memo,
      PHOTO_PATH: photoPath,
      PHOTO_URL: photoURL,
      UPDATED_AT: updatedAt,
    };
  }
  //convert firestore doc to dart object
  static PhotoMemo deserialize(Map<String, dynamic> data, String docId){
    return PhotoMemo(
      docId: docId,
      createdBy: data[PhotoMemo.CREATED_BY],
      title: data[PhotoMemo.TITLE],
      memo: data[PhotoMemo.MEMO],
      photoPath: data[PhotoMemo.PHOTO_PATH],
      photoURL: data[PhotoMemo.PHOTO_URL],
      updatedAt: data[PhotoMemo.UPDATED_AT] != null ?
        DateTime.fromMillisecondsSinceEpoch(data[PhotoMemo.UPDATED_AT].millisecondsSinceEpoch): null,
    );
  }

  @override
  String toString(){
    return '$docId $createdBy $title $memo /n $photoURL'; // to print after sign on pressed from signIn screen class
  }
}
