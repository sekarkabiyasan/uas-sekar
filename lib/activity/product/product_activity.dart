import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_mart/activity/load_indicator.dart';
import 'package:phone_mart/activity/navbar_activity.dart';
import 'package:phone_mart/controllers/firebase/transaction_controller.dart';
import 'package:phone_mart/controllers/rongkir_controller.dart';
import 'package:phone_mart/helpers/number_helper.dart';
import 'package:phone_mart/models/order_firebase.dart';
import 'package:phone_mart/models/product_model.dart';
import 'package:phone_mart/models/rajaongkir_model.dart';
import 'package:phone_mart/models/transaction_model.dart';
import 'package:phone_mart/models/user_model.dart';
import 'package:phone_mart/models/void_error.dart';
import 'package:phone_mart/settings/app_settings.dart';
import 'package:phone_mart/settings/theme_settings.dart';
import 'package:phone_mart/style/font_style.dart';

class ProductActivity extends StatefulWidget {
  const ProductActivity({super.key, required this.productKey});

  final String productKey;

  @override
  State<ProductActivity> createState() => _ProductActivityState();
}

class _ProductActivityState extends State<ProductActivity> {
  User? user;
  UserModel sellerDetail = UserModel(addresses: []);
  UserModel userDetail = UserModel(addresses: []);
  List<FuncError> err = [];
  ProductModel? produk;
  bool isLoad = false;

  int quanty = 0;
  int price = 0;
  int ongkir = 0;
  int finalPrice = 0;
  int weight = 0;

  getUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      if (!mounted) return;
      setState(() {
        user = _user;
      });
    });
  }

  getSellerDetail() async {
    var snapshotUserDetail = await firestore
        .collection(UserModelName().collection)
        .doc(produk!.sellerId)
        .get();

    sellerDetail = UserModel.fromSnapshot(snapshotUserDetail);
    if (!mounted) return;
    setState(() {});
  }

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

    for (var element in userDetail.addresses!) {
      CityRajaOngkir? dataDariRo;
      var res = await RajaOngkirController()
          .getCityById(cityId: element.cityId ?? '');
      if (res.error == null) {
        dataDariRo = res.data as CityRajaOngkir;
      } else {
        dataDariRo =
            CityRajaOngkir(cityId: element.cityId, cityName: '', province: '');
      }
      element.cityData = dataDariRo;
    }

    if (!mounted) return;
    setState(() {});
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  getProduct() async {
    setState(() {
      isLoad = true;
    });
    var snapshot = await firestore
        .collection(ProductFirebase().collection)
        .doc(widget.productKey)
        .get();

    produk = ProductModel.fromSnapshot(snapshot);
    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
  }

  String _selectedCourierCode = '';
  String _selectedCourierService = '';
  String _selectedCourierServiceDesc = '';
  bool isLoadPayment = false;
  UserAdressesModel selectedAddress = UserAdressesModel();

  void order() async {
    if (userDetail.balance! < finalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: const Text(
          "Saldo tidak cukup",
        ),
      ));
    } else {
      setState(() {
        isLoadPayment = true;
      });
      var res = await TransactionController().order(
          order: TransactionModel(
              price: price,
              finalPrice: finalPrice,
              amount: quanty,
              ongkir: ongkir,
              uid: user!.uid,
              weightTotal: weight,
              productId: widget.productKey,
              status: OrderFirebase().statusProsesVerif,
              sellerId: produk!.sellerId,
              name: selectedAddress.name,
              phone: selectedAddress.number,
              address: selectedAddress.address,
              cityId: selectedAddress.cityId,
              courierCode: _selectedCourierCode,
              note: '-',
              resi: '',
              courierService: _selectedCourierService,
              courierServiceDesc: _selectedCourierServiceDesc));

//menerima respon
      if (res!.error == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => NavbarActivity(),
            ),
            (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: const Text(
            "Berhasil membuat order",
          ),
        ));
      } else {
        if (!mounted) return;
        setState(() {
          isLoadPayment = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            res.error.toString(),
          ),
        ));
      }
    }
  }

  void start() async {
    setState(() {
      isLoad = true;
    });
    await getUser();
    if (user != null) {
      await getUserDetail();
      await getUserAddresses();
    }
    await getProduct();
    if (produk != null) {
      await getSellerDetail();
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

  CheckOngkirResponseList ongkirData = CheckOngkirResponseList(results: []);
  cekOngkir() async {
    setState(() {
      isLoad = true;
    });

//Mendapatkan lokasi toko
    DocumentSnapshot doc = await firestore
        .collection(UserModelName().collection)
        .doc(sellerDetail.id)
        .collection(UserModelName().addresses.collection)
        .doc(sellerDetail.addressId)
        .get();

    var result = await RajaOngkirController().checkOngkir(
        cityOriginId: doc.get(UserModelName().addresses.cityId),
        cityDestinationId: selectedAddress.cityId!,
        weight: weight.toInt(),
        courier: 'jne');

    if (result.error == null) {
      if (!mounted) return;
      setState(() {
        isLoad = false;

        //Mengupdate data ongkir dengan data dari respon
        ongkirData = result.data as CheckOngkirResponseList;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isLoad = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          result.error.toString(),
        ),
      ));
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
      appBar: AppBar(
        title: Text(
          isLoad ? "Loading..." : produk!.name ?? "",
          style: fontStyleTitleAppbar(context),
        ),
      ),
      body: isLoad
          ? loadIndicator()
          : isLoadPayment
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Memproses Pembayaran...",
                        style: fontStyleSubtitleSemiBoldDefaultColor(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "(ini hanyalah contoh demo pembayaran)",
                        style: fontStyleParagraftDefaultColor(context),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                              height: 150.0,
                              viewportFraction: 0.8,
                              enlargeCenterPage: true,
                              autoPlay: true,
                              autoPlayInterval:
                                  const Duration(milliseconds: 2000)),
                          items: produk!.imgUrl!.map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: Card(
                                    child: Image.network(i,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                  "${AssetsSetting().imagePath}err.png",
                                                )),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "${NumberHelper.convertToIdrWithSymbol(count: produk!.price, decimalDigit: 0)}",
                          style: fontStyleSubtitleSemiBoldPrimaryColor(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Jumlah terjual :",
                          style: fontStyleSubtitleSemiBoldDefaultColor(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${produk!.soldCount} terjual",
                          style: fontStyleParagraftDefaultColor(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Berat Produk :",
                          style: fontStyleSubtitleSemiBoldDefaultColor(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${produk!.weight} gram",
                          style: fontStyleParagraftDefaultColor(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Deskripsi Produk :",
                          style: fontStyleSubtitleSemiBoldDefaultColor(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${produk!.desc}",
                          style: fontStyleParagraftDefaultColor(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Stok Produk :",
                          style: fontStyleSubtitleSemiBoldDefaultColor(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        user == null
                            ? Center(
                                child: Text(
                                  "mohon login terlebih dulu",
                                  style:
                                      fontStyleParagraftDefaultColor(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : Form(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${produk!.stock} tersisa",
                                      style: fontStyleParagraftDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Jumlah Produk :",
                                          style:
                                              fontStyleSubtitleSemiBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  if (quanty > 0) {
                                                    quanty--;
                                                    price =
                                                        produk!.price! * quanty;
                                                    finalPrice = price + ongkir;
                                                    weight = produk!.weight! *
                                                        quanty;
                                                    if (ongkirData
                                                        .results!.isNotEmpty) {
                                                      cekOngkir();
                                                    }
                                                  }
                                                  setState(() {});
                                                },
                                                child: Icon(Icons.remove),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                '$quanty',
                                                style:
                                                    fontStyleSubtitleDefaultColor(
                                                        context),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (quanty < produk!.stock!) {
                                                    quanty++;
                                                    price =
                                                        produk!.price! * quanty;
                                                    finalPrice = price + ongkir;
                                                    weight = produk!.weight! *
                                                        quanty;
                                                    if (ongkirData
                                                        .results!.isNotEmpty) {
                                                      cekOngkir();
                                                    }
                                                    setState(() {});
                                                  }
                                                },
                                                child: Icon(Icons.add),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Harga Total Produk :",
                                          style:
                                              fontStyleSubtitleSemiBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${NumberHelper.convertToIdrWithSymbol(count: price, decimalDigit: 0)}',
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleSubtitleDefaultColor(
                                                    context),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Berat Total Produk :",
                                          style:
                                              fontStyleSubtitleSemiBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '$weight gram',
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleSubtitleDefaultColor(
                                                    context),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ExpansionTile(
                                      title: Text(
                                        "Pilih alamat pengiriman : ",
                                        style:
                                            fontStyleParagraftBoldDefaultColor(
                                                context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      children: [
                                        userDetail.addresses!.length <= 0
                                            ? Center(
                                                child: Text(
                                                  "Belum ada alamat yang disimpan",
                                                  style:
                                                      fontStyleParagraftDefaultColor(
                                                          context),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            : Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        "Pilih alamat pengiriman",
                                                        style:
                                                            fontStyleSubtitleSemiBoldPrimaryColor(
                                                                context),
                                                      )
                                                    ],
                                                  ),
                                                  ListView.separated(
                                                    itemCount: userDetail
                                                        .addresses!.length,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            Divider(),
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      var i = userDetail
                                                          .addresses![index];
                                                      return ListTile(
                                                        title: Text(
                                                          i.title ?? '-',
                                                          style:
                                                              fontStyleSubtitleSemiBoldPrimaryColor(
                                                                  context),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        subtitle: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${i.cityData!.cityName} (${i.cityData!.province})',
                                                              style:
                                                                  fontStyleParagraftBoldDefaultColor(
                                                                      context),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Text(
                                                              i.address ?? '',
                                                              style:
                                                                  fontStyleParagraftDefaultColor(
                                                                      context),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Text(
                                                              '${i.name} (${i.number})',
                                                              style:
                                                                  fontStyleParagraftDefaultColor(
                                                                      context),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                        trailing: Checkbox(
                                                          value: selectedAddress
                                                                  .id ==
                                                              i.id,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedAddress =
                                                                  i;
                                                              cekOngkir();
                                                            });
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                      ],
                                    ),
                                    Text(
                                      "Jasa Kirim :",
                                      style:
                                          fontStyleSubtitleSemiBoldDefaultColor(
                                              context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: ongkirData.results!.length,
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return const Divider();
                                      },
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ExpansionTile(
                                          title: Text(
                                            ongkirData.results![index].name ??
                                                "",
                                            style:
                                                fontStyleParagraftBoldDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          children: [
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: ongkirData
                                                  .results![index]
                                                  .costs!
                                                  .length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int iChild) {
                                                return Row(
                                                  children: [
                                                    Checkbox(
                                                      value: _selectedCourierCode ==
                                                              ongkirData
                                                                  .results![
                                                                      index]
                                                                  .code &&
                                                          _selectedCourierService ==
                                                              ongkirData
                                                                  .results![
                                                                      index]
                                                                  .costs![
                                                                      iChild]
                                                                  .service,
                                                      onChanged:
                                                          (bool? newValue) {
                                                        _selectedCourierCode =
                                                            ongkirData
                                                                    .results![
                                                                        index]
                                                                    .code ??
                                                                "";
                                                        _selectedCourierService =
                                                            ongkirData
                                                                    .results![
                                                                        index]
                                                                    .costs![
                                                                        iChild]
                                                                    .service ??
                                                                "";
                                                        _selectedCourierServiceDesc =
                                                            ongkirData
                                                                    .results![
                                                                        index]
                                                                    .costs![
                                                                        iChild]
                                                                    .description ??
                                                                "";
                                                        ongkir = ongkirData
                                                            .results![index]
                                                            .costs![iChild]
                                                            .cost![0]
                                                            .value!
                                                            .toInt();
                                                        finalPrice =
                                                            price + ongkir;
                                                        setState(() {});
                                                      },
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${ongkirData.results![index].costs![iChild].service} - ${ongkirData.results![index].costs![iChild].description}',
                                                          style:
                                                              fontStyleParagraftBoldDefaultColor(
                                                                  context),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          '${NumberHelper.convertToIdrWithSymbol(count: ongkirData.results![index].costs![iChild].cost![0].value, decimalDigit: 0)} | ${ongkirData.results![index].costs![iChild].cost![0].etd} hari',
                                                          style:
                                                              fontStyleParagraftBoldDefaultColor(
                                                                  context),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Ongkir :",
                                          style:
                                              fontStyleSubtitleSemiBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${NumberHelper.convertToIdrWithSymbol(count: ongkir, decimalDigit: 0)}',
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleSubtitleDefaultColor(
                                                    context),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Harga Akhir :",
                                          style:
                                              fontStyleSubtitleSemiBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${NumberHelper.convertToIdrWithSymbol(count: finalPrice, decimalDigit: 0)}',
                                            textAlign: TextAlign.end,
                                            style:
                                                fontStyleSubtitleDefaultColor(
                                                    context),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: quanty <= 0
                                            ? null
                                            : selectedAddress.id == null
                                                ? null
                                                : _selectedCourierCode == ""
                                                    ? null
                                                    : _selectedCourierService ==
                                                            ""
                                                        ? null
                                                        : user!.uid ==
                                                                produk!.sellerId
                                                            ? null
                                                            : () {
                                                                order();
                                                              },
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10), // <-- Radius
                                            ),
                                            elevation: 0,
                                            backgroundColor: ThemeSettings()
                                                .primaryColor(context)),
                                        child: Text(
                                          "Bayar dengan saldo aplikasi",
                                          style:
                                              fontStyleSubtitleSemiBoldWhiteColor(
                                                  context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
