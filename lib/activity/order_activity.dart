import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_mart/activity/load_indicator.dart';
import 'package:phone_mart/activity/unauth_activifty.dart';
import 'package:phone_mart/controllers/firebase/transaction_controller.dart';
import 'package:phone_mart/helpers/number_helper.dart';
import 'package:phone_mart/models/order_firebase.dart';
import 'package:phone_mart/models/product_model.dart';
import 'package:phone_mart/models/transaction_model.dart';
import 'package:phone_mart/models/void_error.dart';
import 'package:phone_mart/settings/app_settings.dart';
import 'package:phone_mart/settings/theme_settings.dart';
import 'package:phone_mart/style/font_style.dart';

class OrderActivity extends StatefulWidget {
  const OrderActivity({super.key, required this.isSeller});
  final bool isSeller;

  @override
  State<OrderActivity> createState() => _OrderActivityState();
}

class _OrderActivityState extends State<OrderActivity> {
  bool isLoad = false;
  User? user;
  List<FuncError> err = [];
  List<TransactionModel> trxData = [];

  String _selectedStatus = OrderFirebase().statusProsesVerif;

  final List<Map<String, String>> _status = [
    {
      'value': OrderFirebase().statusProsesVerif,
      'display': 'Menunggu konfirmasi'
    },
    {'value': OrderFirebase().statusDelivery, 'display': 'Dalam Pengiriman'},
    {'value': OrderFirebase().statusDone, 'display': 'Produk Diterima'},
    {'value': OrderFirebase().statusReject, 'display': 'Produk Ditolak'},
  ];

  getUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      if (!mounted) return;
      setState(() {
        user = _user;
      });
    });
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  getOrderData() async {
    if (!mounted) return;
    setState(() {
      isLoad = true;
    });
    Query<Map<String, dynamic>> ref = firestore
        .collection('transaction')
        .where('status', isEqualTo: _selectedStatus);

    if (widget.isSeller) {
      ref = ref.where('sellerId', isEqualTo: user!.uid);
    } else {
      ref = ref.where('uid', isEqualTo: user!.uid);
    }

    var res = await ref.get();

    trxData.clear();
    for (var element in res.docs) {
      trxData.add(TransactionModel.fromSnapshot(element));
    }

    for (var element in trxData) {
      var productref = await firestore
          .collection(ProductFirebase().collection)
          .doc(element.productId)
          .get();
      element.produk = ProductModel.fromSnapshot(productref);
    }
    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
  }

  void start() async {
    setState(() {
      isLoad = true;
    });
    await getUser();
    if (user != null) {
      await getOrderData();
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
    return Scaffold(
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
                        SizedBox(
                          width: double.infinity,
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            onChanged: (String? newValue) async {
                              setState(() {
                                _selectedStatus = newValue!;
                                getOrderData();
                              });
                            },
                            isExpanded: true,
                            items: _status.map<DropdownMenuItem<String>>(
                                (Map<String, String> value) {
                              return DropdownMenuItem<String>(
                                value: value['value'],
                                child: Text(
                                  value['display']!,
                                  style:
                                      fontStyleParagraftDefaultColor(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: trxData.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(
                              height: 5,
                            );
                          },
                          itemBuilder: (BuildContext context, int index) {
                            var i = trxData[index];
                            TextEditingController resi =
                                TextEditingController(text: i.resi);
                            TextEditingController note =
                                TextEditingController(text: i.note);
                            return Card(
                              child: ListTile(
                                title: Text(
                                  "${i.produk!.name}",
                                  style: fontStyleSubtitleSemiBoldPrimaryColor(
                                      context),
                                ),
                                subtitle: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Jumlah: ",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${i.amount} item',
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Harga: ",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            NumberHelper.convertToIdrWithSymbol(
                                                count: i.price,
                                                decimalDigit: 0),
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Ongkir: ",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            NumberHelper.convertToIdrWithSymbol(
                                                count: i.ongkir,
                                                decimalDigit: 0),
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Row(
                                      children: [
                                        Text(
                                          "Total: ",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            NumberHelper.convertToIdrWithSymbol(
                                                count: i.finalPrice,
                                                decimalDigit: 0),
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Nama: ",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${i.name}',
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Nomor: ",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${i.phone}',
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Alamat: ",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "${i.address}",
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Kurir: ",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "${i.courierCode} - ${i.courierService} - ${i.courierServiceDesc}",
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Status: ",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "${i.status}",
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Resi: ",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${i.resi}',
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Catatan Seller: ",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${i.note}',
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Visibility(
                                      visible: !widget.isSeller &&
                                          i.status ==
                                              OrderFirebase().statusDelivery,
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      isLoad = true;
                                                    });
                                                    await TransactionController()
                                                        .orderDone(
                                                            transaction: i);
                                                    if (!mounted) return;
                                                    setState(() {
                                                      start();
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10), // <-- Radius
                                                          ),
                                                          elevation: 0,
                                                          backgroundColor:
                                                              ThemeSettings()
                                                                  .primaryColor(
                                                                      context)),
                                                  child: Text(
                                                    "konfirmasi barang diterima",
                                                    style:
                                                        fontStyleSubtitleSemiBoldWhiteColor(
                                                            context),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: i.status ==
                                              OrderFirebase()
                                                  .statusProsesVerif &&
                                          widget.isSeller,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          TextFormField(
                                            controller: resi,
                                            keyboardType: TextInputType.text,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            decoration: InputDecoration(
                                                hintText: 'resi'),
                                          ),
                                          TextFormField(
                                            controller: note,
                                            keyboardType: TextInputType.text,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            decoration: InputDecoration(
                                                hintText: 'catatan'),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    if (note.text != '-' &&
                                                        note.text != '') {
                                                      i.note = note.text;
                                                      setState(() {
                                                        isLoad = true;
                                                      });
                                                      var res =
                                                          await TransactionController()
                                                              .orderReject(
                                                                  transaction:
                                                                      i);
                                                      if (!mounted) return;
                                                      setState(() {
                                                        start();
                                                      });
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                        'isikan catatan',
                                                      )));
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10), // <-- Radius
                                                          ),
                                                          elevation: 0,
                                                          backgroundColor:
                                                              ThemeSettings()
                                                                  .errorColor(
                                                                      context)),
                                                  child: Text(
                                                    "Tolak",
                                                    style:
                                                        fontStyleSubtitleSemiBoldWhiteColor(
                                                            context),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    if (resi.text != '') {
                                                      i.note = note.text;
                                                      i.resi = resi.text;
                                                      setState(() {
                                                        isLoad = true;
                                                      });
                                                      var res =
                                                          await TransactionController()
                                                              .orderAcc(
                                                                  transaction:
                                                                      i);
                                                      if (!mounted) return;
                                                      setState(() {
                                                        start();
                                                      });
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                        'isikan resi',
                                                      )));
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10), // <-- Radius
                                                          ),
                                                          elevation: 0,
                                                          backgroundColor:
                                                              ThemeSettings()
                                                                  .primaryColor(
                                                                      context)),
                                                  child: Text(
                                                    "Terima",
                                                    style:
                                                        fontStyleSubtitleSemiBoldWhiteColor(
                                                            context),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
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
