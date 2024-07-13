import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phone_mart/models/product_model.dart';

class TransactionModel {
  String? id;
  ProductModel? produk;
  String? address;
  int? amount;
  String? cityId;
  String? courierCode;
  String? courierService;
  String? courierServiceDesc;
  int? finalPrice;
  int? ongkir;
  int? price;
  String? name;
  String? phone;
  String? productId;
  String? sellerId;
  String? status;
  String? uid;
  String? resi;
  String? note;
  int? weightTotal;

  TransactionModel({
    this.address,
    this.amount,
    this.cityId,
    this.courierCode,
    this.courierService,
    this.courierServiceDesc,
    this.finalPrice,
    this.ongkir,
    this.id,
    this.resi,
    this.note,
    this.name,
    this.produk,
    this.phone,
    this.price,
    this.productId,
    this.weightTotal,
    this.sellerId,
    this.status,
    this.uid,
  });

//Untuk kebutuhan get
  factory TransactionModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    String id = snapshot.id;

    return TransactionModel(
      id: id,
      sellerId: data['sellerId'],
      address: data['address'],
      amount: data['amount'],
      cityId: data['city_id'],
      courierCode: data['courier_code'],
      courierService: data['courier_service'],
      courierServiceDesc: data['courier_service_desc'],
      finalPrice: data['final_price'],
      ongkir: data['ongkir'],
      name: data['name'],
      phone: data['phone'],
      price: data['price'],
      productId: data['productId'],
      status: data['status'],
      uid: data['uid'],
      resi: data['resi'],
      note: data['note'],
      weightTotal: data['weightTotal'],
    );
  }

  //untuk kebutuhan post
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'amount': amount,
      'city_id': cityId,
      'courier_code': courierCode,
      'courier_service': courierService,
      'courier_service_desc': courierServiceDesc,
      'final_price': finalPrice,
      'name': name,
      'phone': phone,
      'ongkir': ongkir,
      'price': price,
      'resi': resi,
      'note': note,
      'productId': productId,
      'sellerId': sellerId,
      'status': status,
      'uid': uid,
      'weightTotal': weightTotal,
    };
  }
}
