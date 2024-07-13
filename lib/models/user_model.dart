import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phone_mart/models/rajaongkir_model.dart';

class UserModelName {
  String collection = 'user';
  String addressId = 'addressId';
  UserAddressesModelName addresses = UserAddressesModelName();
  String balance = 'balance';
}

class UserAddressesModelName {
  String collection = 'alamat';
  String address = 'address';
  String nama = 'nama';
  String title = 'title';
  String nomor = 'nomor';
  String cityId = 'city_id';
}

class UserModel {
  String? id;
  String? addressId;
  int? balance;
  List<UserAdressesModel>? addresses;

  UserModel({this.addressId, this.id, this.balance, this.addresses});

  //Untuk kebutuhan get
  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    String id = snapshot.id;
    List<UserAdressesModel> addresses = [];

    return UserModel(
        id: id,
        addressId: data[UserModelName().addressId],
        balance: data[UserModelName().balance],
        addresses: addresses);
  }

  Map<String, dynamic> toMap() {
    return {
      UserModelName().addressId: addressId,
      UserModelName().balance: balance,
    };
  }
}

class UserAdressesModel {
  String? id;
  String? address;
  String? cityId;
  CityRajaOngkir? cityData;
  String? title;
  String? name;
  String? number;

  UserAdressesModel({
    this.id,
    this.address,
    this.cityId,
    this.name,
    this.number,
    this.title,
    this.cityData,
  });

  //Untuk kebutuhan get
  factory UserAdressesModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    String id = snapshot.id;

    return UserAdressesModel(
      id: id,
      cityData: CityRajaOngkir(),
      address: data[UserModelName().addresses.address],
      cityId: data[UserModelName().addresses.cityId],
      title: data[UserModelName().addresses.title],
      name: data[UserModelName().addresses.nama],
      number: data[UserModelName().addresses.nomor],
    );
  }

  //untuk kebutuhan post
  Map<String, dynamic> toMap() {
    return {
      UserModelName().addresses.address: address,
      UserModelName().addresses.cityId: cityId,
      UserModelName().addresses.title: title,
      UserModelName().addresses.nama: name,
      UserModelName().addresses.nomor: number,
    };
  }
}
