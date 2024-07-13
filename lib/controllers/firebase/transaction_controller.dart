import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:phone_mart/models/order_firebase.dart';
import 'package:phone_mart/models/product_model.dart';
import 'package:phone_mart/models/response_model.dart';
import 'package:phone_mart/models/transaction_model.dart';
import 'package:phone_mart/models/user_model.dart';

class TransactionController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  get user => auth.currentUser;

  Future<Response?> order({
    required TransactionModel order,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = order.toMap();
    try {
      var ref = FirebaseFirestore.instance.collection('transaction').doc();
      var refuser = FirebaseFirestore.instance
          .collection(UserModelName().collection)
          .doc(order.uid);
      var refProduct = FirebaseFirestore.instance
          .collection(ProductFirebase().collection)
          .doc(order.productId);

      var user = await refuser.get();
      var product = await refProduct.get();

      await refuser.update({
        UserModelName().balance:
            user.get(UserModelName().balance) - order.finalPrice
      });
      await refProduct.update({
        ProductFirebase().stock:
            product.get(ProductFirebase().stock) - order.amount,
        ProductFirebase().soldCount:
            product.get(ProductFirebase().soldCount) + order.amount
      });

      await ref.set(newData);

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> orderReject({
    required TransactionModel transaction,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = {
      'status': OrderFirebase().statusReject,
      'note': transaction.note
    };

    try {
      var ref = FirebaseFirestore.instance
          .collection('transaction')
          .doc(transaction.id);
      var refuser = FirebaseFirestore.instance
          .collection(UserModelName().collection)
          .doc(transaction.uid);

      var user = await refuser.get();

      await refuser.update({
        UserModelName().balance:
            user.get(UserModelName().balance) + transaction.finalPrice
      });

      await ref.update(newData);

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> orderDone({
    required TransactionModel transaction,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = {
      'status': OrderFirebase().statusDone,
    };

    try {
      var ref = FirebaseFirestore.instance
          .collection('transaction')
          .doc(transaction.id);
      var refuser = FirebaseFirestore.instance
          .collection(UserModelName().collection)
          .doc(transaction.sellerId);

      var user = await refuser.get();

      await refuser.update({
        UserModelName().balance:
            user.get(UserModelName().balance) + transaction.price
      });

      await ref.update(newData);

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> orderAcc({
    required TransactionModel transaction,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = {
      'status': OrderFirebase().statusDelivery,
      'note': transaction.note,
      'resi': transaction.resi,
    };
    try {
      var ref = FirebaseFirestore.instance
          .collection('transaction')
          .doc(transaction.id);

      await ref.update(newData);

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }
}
