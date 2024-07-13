// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_mart/activity/load_indicator.dart';
import 'package:phone_mart/activity/product/product_manage.dart';
import 'package:phone_mart/activity/unauth_activifty.dart';
import 'package:phone_mart/helpers/number_helper.dart';
import 'package:phone_mart/models/product_model.dart';
import 'package:phone_mart/models/user_model.dart';
import 'package:phone_mart/models/void_error.dart';
import 'package:phone_mart/settings/app_settings.dart';
import 'package:phone_mart/style/font_style.dart';

class MyProduct extends StatefulWidget {
  const MyProduct({super.key});

  @override
  State<MyProduct> createState() => _MyProductState();
}

class _MyProductState extends State<MyProduct> {
  bool isLoad = false;
  User? user;
  List<FuncError> err = [];
  List<ProductModel> product = [];

  getUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      if (!mounted) return;
      setState(() {
        user = _user;
      });
    });
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  getMyPrduct() async {
    if (!mounted) return;
    setState(() {
      isLoad = true;
    });
    var snapshot = await firestore
        .collection(ProductFirebase().collection)
        .where(ProductFirebase().active, isEqualTo: true)
        .where(ProductFirebase().sellerId, isEqualTo: user!.uid)
        .get();

    product.clear();
    for (var element in snapshot.docs) {
      product.add(ProductModel.fromSnapshot(element));
    }

    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
  }

  UserModel userDetail = UserModel(addresses: []);
  getUserDetail() async {
    var snapshotUserDetail = await firestore
        .collection(UserModelName().collection)
        .doc(user!.uid)
        .get();

    userDetail = UserModel.fromSnapshot(snapshotUserDetail);
    if (!mounted) return;
    setState(() {});
  }

  getUserAddresses() async {
    var snapshotAddresses = await firestore
        .collection(UserModelName().collection)
        .doc(user!.uid)
        .collection(UserModelName().addresses.collection)
        .get();

    userDetail.addresses!.clear();
    for (var element in snapshotAddresses.docs) {
      userDetail.addresses!.add(UserAdressesModel.fromSnapshot(element));
    }

    if (!mounted) return;
    setState(() {});
  }

  void start() async {
    setState(() {
      isLoad = true;
    });
    await getUser();
    if (user != null) {
      await getUserDetail();
      await getUserAddresses();
      await getMyPrduct();
    }
    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
    //Jika err akan mencoba dipanggil kembali
    for (var error in err) {
      error.func();
      print('${error.error} called again');
    }
  }

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Produk saya',
          style: fontStyleTitleAppbar(context),
        ),
        actions: [
          Visibility(
            visible: user != null,
            child: IconButton(
                onPressed: () async {
                  if (userDetail.addresses!.length > 0 &&
                      userDetail.addressId != '') {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductManage(),
                        ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      "Kamu harus memiliki 1 alamat minimal, dan jadikan sebagai alamat toko",
                    )));
                  }
                  if (!mounted) return;
                  setState(() {
                    getMyPrduct();
                  });
                },
                icon: const Icon(Icons.add)),
          )
        ],
      ),
      body: isLoad
          ? loadIndicator()
          : user == null
              ? unAuth(context)
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenSetting().paddingScreen),
                    child: Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isPotrait ? 2 : 4),
                          itemCount: product.length,
                          itemBuilder: (context, index) {
                            var i = product[index];
                            return InkWell(
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductManage(
                                        productKey: i.id,
                                      ),
                                    ));
                                if (!mounted) return;
                                setState(() {
                                  getMyPrduct();
                                });
                              },
                              child: Card(
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        i.imgUrl![0],
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                          "${AssetsSetting().imagePath}err.png",
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        i.name ?? '-',
                                        style:
                                            fontStyleSubtitleSemiBoldDefaultColor(
                                                context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            NumberHelper.convertToIdrWithSymbol(
                                                count: i.price,
                                                decimalDigit: 0),
                                            style:
                                                fontStyleSubtitleSemiBoldPrimaryColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${i.soldCount} terjual',
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${i.stock} tersisa',
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
