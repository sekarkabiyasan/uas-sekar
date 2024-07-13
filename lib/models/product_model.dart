import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFirebase {
  String collection = 'product';
  String active = 'active';
  String name = 'name';
  String price = 'price';
  String weight = 'weight';
  String desc = 'desc';
  String stock = 'stock';
  String sellerId = 'sellerId';
  String soldCount = 'soldCount';
  String createdAt = 'createdAt';
  String imgURL = 'imgURL';
}

class ProductModel {
  String? id;
  String? sellerId;
  bool? active;
  String? desc;
  List<String>? imgUrl;
  String? name;
  Timestamp? createdAt;
  int? price;
  int? stock;
  int? weight;
  int? soldCount;

  ProductModel(
      {this.active,
      this.id,
      this.sellerId,
      this.desc,
      this.imgUrl,
      this.name,
      this.price,
      this.soldCount,
      this.createdAt,
      this.stock,
      this.weight});

//Untuk kebutuhan get
  factory ProductModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    String id = snapshot.id;

    return ProductModel(
      id: id,
      sellerId: data[ProductFirebase().sellerId],
      active: data[ProductFirebase().active],
      desc: data[ProductFirebase().desc],
      imgUrl: List<String>.from(data[ProductFirebase().imgURL] ?? []),
      name: data[ProductFirebase().name],
      soldCount: data[ProductFirebase().soldCount],
      createdAt: data[ProductFirebase().createdAt],
      price: data[ProductFirebase().price],
      stock: data[ProductFirebase().stock],
      weight: data[ProductFirebase().weight],
    );
  }

//untuk kebutuhan post
  Map<String, dynamic> toMap() {
    return {
      ProductFirebase().sellerId: sellerId,
      ProductFirebase().active: active,
      ProductFirebase().desc: desc,
      ProductFirebase().imgURL: imgUrl ?? [],
      ProductFirebase().name: name,
      ProductFirebase().soldCount: soldCount,
      ProductFirebase().createdAt: createdAt,
      ProductFirebase().price: price,
      ProductFirebase().stock: stock,
      ProductFirebase().weight: weight,
    };
  }
}
