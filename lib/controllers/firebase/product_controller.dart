import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:phone_mart/models/product_model.dart';
import 'package:phone_mart/models/response_model.dart';

class ProductController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  get user => auth.currentUser;

  Future<Response?> deleteProduct({
    required String productId,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = {ProductFirebase().active: false};
    try {
      var ref = FirebaseFirestore.instance
          .collection(ProductFirebase().collection)
          .doc(productId)
          .update(newData);

      res.message = "Berhasil menghapus produk";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> addProduct({
    String? productId,
    List<File>? imageFile,
    required ProductModel product,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = product.toMap();
    try {
      imageFile ??= [];
      if (imageFile.isNotEmpty) {
        for (var element in imageFile) {
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

          UploadTask uploadTask = storageReference.putFile(element);
          await uploadTask.whenComplete(() => print('File Uploaded'));
          String imageUrl = await storageReference.getDownloadURL();
          product.imgUrl!.add(imageUrl);
        }
      }

      if (productId != null) {
        var ref = FirebaseFirestore.instance
            .collection(ProductFirebase().collection)
            .doc(productId);

        await ref.update(newData);
      } else {
        var ref = FirebaseFirestore.instance
            .collection(ProductFirebase().collection)
            .doc();

        await ref.set(newData);
      }
      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }
}
