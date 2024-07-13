//Membuat controller untuk komunikasi aplikasi dengan firebase

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:phone_mart/models/response_model.dart';
import 'package:phone_mart/models/user_model.dart';

class AuthController {
//inisialisasi variable agar mempermudah

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  get user => auth.currentUser;

//disini kebanyakan fungsi bertipe Response, yang dimana Response adalah sebuah model yang saya buat untuk mempermudah memberikan pengembalian respon ketika fungsi dipanggil

  //Membuat fungsi komunikasi untuk registrasi
  Future<Response?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    Response res = Response();
    try {
      //Fungsi registrasi yang telah disediakan firebase auth
      final user = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //update username menjadi nama user yang baru
      await user.user!.updateDisplayName(name);

      //input user detail
      await firestore
          .collection(UserModelName().collection)
          .doc(user.user!.uid)
          .set(UserModel(
            addressId: '',
            balance: 0,
          ).toMap());

//Logout terlebih dahulu, lebih baik login ulang kembali
      await logOut();

//menambahkan message pada pengembalian
      res.message = 'Berhasil mendaftar, silahkan login';

//Memberikan pengembalian
      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  //Fungsi Logout
  Future logOut() async {
    await FirebaseAuth.instance.signOut();
  }

//Membuat fungsi komunikasi untuk login
  Future<Response?> login({
    required String email,
    required String password,
  }) async {
    Response res = Response();
    try {
      //Fungsi login yang telah disediakan firebase auth
      final user = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      res.message = 'Berhasil Login';

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

//Fungsi logout dengan respon
  Future<Response?> logOutRes() async {
    Response res = Response();
    try {
      await FirebaseAuth.instance.signOut();
      res.message = "Berhasil Keluar";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> sebagaiAlamatToko(String idAddress, User user) async {
    Response res = Response();
    try {
      await firestore
          .collection(UserModelName().collection)
          .doc(user.uid)
          .update({UserModelName().addressId: idAddress});

      res.message = "Berhasil menjadikan alamat toko";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> topup(int amount, User user) async {
    Response res = Response();
    try {
      var userData = await firestore
          .collection(UserModelName().collection)
          .doc(user.uid)
          .get();
      await firestore
          .collection(UserModelName().collection)
          .doc(user.uid)
          .update({
        UserModelName().balance: amount + userData.get(UserModelName().balance)
      });

      res.message = "Berhasil topup saldo";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> addAdress(UserAdressesModel address, User user) async {
    Response res = Response();
    try {
      await firestore
          .collection(UserModelName().collection)
          .doc(user.uid)
          .collection(UserAddressesModelName().collection)
          .doc()
          .set(address.toMap());

      res.message = "Berhasil menambahkan alamat toko";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  //Fungsi Update name

  Future<Response?> updateName(String name) async {
    Response res = Response();
    try {
      await auth.currentUser!.updateDisplayName(name);
      res.message = "Berhasil mengupdate nama";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

//Fungsi untuk update image saja
  Future<Response?> updateImage(File? img) async {
    Response res = Response();
    try {
      //Melakukan upload image ke storage firebase
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

      UploadTask uploadTask = storageReference.putFile(img!);
      await uploadTask.whenComplete(() => print('File Uploaded'));

//Mendapatkan url file
      String imageUrl = await storageReference.getDownloadURL();

//Update url image pada auth
      await auth.currentUser!.updatePhotoURL(imageUrl);
      res.message = "Berhasil mengupdate foto";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }
}
