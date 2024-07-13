import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phone_mart/activity/load_indicator.dart';
import 'package:phone_mart/activity/myproduct_activity.dart';
import 'package:phone_mart/activity/product/product_activity.dart';
import 'package:phone_mart/helpers/number_helper.dart';
import 'package:phone_mart/models/product_model.dart';
import 'package:phone_mart/models/void_error.dart';
import 'package:phone_mart/settings/app_settings.dart';
import 'package:phone_mart/style/font_style.dart';

class HomeActivity extends StatefulWidget {
  const HomeActivity({super.key});

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  bool isLoad = false;
  List<FuncError> err = [];

  int page = 0;

  getAll() async {
    String funcTag = 'getAll';
    print('$funcTag called');

    // var res = await GetGsmApiController().tes();

    // if (res.error == null) {
    //   if (!mounted) return;
    //   setState(() {});
    // } else {
    //   print('$funcTag error => ${res.error}');
    //   err.add(FuncError(
    //       error: funcTag,
    //       func: () {
    //         getAll();
    //       }));
    // }
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  getOnSale() async {}

  void start() async {
    setState(() {
      isLoad = true;
    });
    await getAll();
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
    //Membuat boolean yang membaca orientation device
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cari Produk",
          style: fontStyleTitleAppbar(context),
        ),
      ),
      body: isLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                child: Column(
                  children: [
                    //Rekomend 1
                    err.any((error) => error.error == 'getAll')
                        ? const SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Terjadi Kesalahan...",
                              textAlign: TextAlign.center,
                            ))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Paling Laku",
                                style: fontStyleTitleH3DefaultColor(context),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              StreamBuilder(
                                  stream: firestore
                                      .collection(ProductFirebase().collection)
                                      .where(ProductFirebase().active,
                                          isEqualTo: true)
                                      .where(ProductFirebase().soldCount,
                                          isGreaterThan: 0)
                                      .orderBy(ProductFirebase().soldCount,
                                          descending: true)
                                      // .orderBy(ProductFirebase().createdAt,
                                      //     descending: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return loadIndicator();
                                    }

                                    if (snapshot.hasError) {
                                      print(snapshot.error);
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    if (!snapshot.hasData) {
                                      return const Text('Data tidak ditemukan');
                                    }

                                    if (snapshot.data!.docs.isEmpty) {
                                      return const Center(
                                          child: Text(
                                              'Produk tidak ditemukan, atau kosong'));
                                    }

                                    // snapshot.data!.docs.sort((a, b) => b
                                    //     .get(ProductFirebase().createdAt)
                                    //     .compareTo(a
                                    //         .get(ProductFirebase().createdAt)));

                                    return CarouselSlider(
                                      options: CarouselOptions(
                                          height: 150.0,
                                          viewportFraction: 0.8,
                                          enlargeCenterPage: true,
                                          autoPlay: true,
                                          autoPlayInterval: const Duration(
                                              milliseconds: 2000)),
                                      items: snapshot.data!.docs.map((i) {
                                        ProductModel product =
                                            ProductModel.fromSnapshot(i);
                                        return Builder(
                                          builder: (BuildContext context) {
                                            return InkWell(
                                              onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductActivity(
                                                      productKey:
                                                          product.id.toString(),
                                                    ),
                                                  )),
                                              child: Card(
                                                  child: Padding(
                                                padding: EdgeInsets.all(
                                                    ScreenSetting()
                                                        .paddingScreen),
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.network(
                                                        product.imgUrl![0],
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Image.asset(
                                                          "${AssetsSetting().imagePath}err.png",
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: ScreenSetting()
                                                              .paddingScreen),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              product.name ??
                                                                  '-',
                                                              style:
                                                                  fontStyleSubtitleSemiBoldPrimaryColor(
                                                                      context),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Text(
                                                              NumberHelper.convertToIdrWithSymbol(
                                                                  count: product
                                                                      .price,
                                                                  decimalDigit:
                                                                      0),
                                                              style:
                                                                  fontStyleSubtitleSemiBoldDefaultColor(
                                                                      context),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Text(
                                                              '${product.soldCount} terjual',
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
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )),
                                            );
                                          },
                                        );
                                      }).toList(),
                                    );
                                  }),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Terbaru",
                                style: fontStyleTitleH3DefaultColor(context),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 210.0,
                                child: StreamBuilder(
                                    stream: firestore
                                        .collection(
                                            ProductFirebase().collection)
                                        .where(ProductFirebase().active,
                                            isEqualTo: true)
                                        .orderBy(ProductFirebase().createdAt,
                                            descending: true)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return loadIndicator();
                                      }

                                      if (snapshot.hasError) {
                                        print(snapshot.error);
                                        return Text('Error: ${snapshot.error}');
                                      }

                                      if (!snapshot.hasData) {
                                        return const Text(
                                            'Data tidak ditemukan');
                                      }

                                      if (snapshot.data!.docs.isEmpty) {
                                        return const Center(
                                            child: Text(
                                                'Produk tidak ditemukan, atau kosong'));
                                      }
                                      return ListView.separated(
                                        shrinkWrap: true,
                                        // physics: const NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data!.docs.length,
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return const SizedBox(
                                            height: 10,
                                          );
                                        },
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          ProductModel i =
                                              ProductModel.fromSnapshot(
                                                  snapshot.data!.docs[index]);
                                          return InkWell(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductActivity(
                                                    productKey: i.id.toString(),
                                                  ),
                                                )),
                                            child: Card(
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    ScreenSetting()
                                                        .paddingScreen),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Image.network(
                                                      i.imgUrl![0],
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      height: 100.0,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Image.asset(
                                                        "${AssetsSetting().imagePath}err.png",
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        height: 100.0,
                                                      ),
                                                    ),
                                                    Column(
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                          child: Text(
                                                            i.name ?? '-',
                                                            style:
                                                                fontStyleSubtitleSemiBoldPrimaryColor(
                                                                    context),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                          child: Text(
                                                            NumberHelper
                                                                .convertToIdrWithSymbol(
                                                                    count:
                                                                        i.price,
                                                                    decimalDigit:
                                                                        0),
                                                            style:
                                                                fontStyleSubtitleDefaultColor(
                                                                    context),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                          child: Text(
                                                            '${i.stock} tersisa',
                                                            style:
                                                                fontStyleParagraftBoldDefaultColor(
                                                                    context),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Semua Produk",
                                style: fontStyleTitleH3DefaultColor(context),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              StreamBuilder(
                                  stream: firestore
                                      .collection(ProductFirebase().collection)
                                      .where(ProductFirebase().active,
                                          isEqualTo: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return loadIndicator();
                                    }

                                    if (snapshot.hasError) {
                                      print(snapshot.error);
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    if (!snapshot.hasData) {
                                      return const Text('Data tidak ditemukan');
                                    }

                                    if (snapshot.data!.docs.isEmpty) {
                                      return const Center(
                                          child: Text(
                                              'Produk tidak ditemukan, atau kosong'));
                                    }
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.data!.docs.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount:
                                                  isPotrait ? 2 : 4),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        ProductModel i =
                                            ProductModel.fromSnapshot(
                                                snapshot.data!.docs[index]);
                                        return InkWell(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductActivity(
                                                  productKey: i.id.toString(),
                                                ),
                                              )),
                                          child: Card(
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: Image.network(
                                                    i.imgUrl![0],
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      "${AssetsSetting().imagePath}err.png",
                                                    ),
                                                  ),
                                                ),
                                                ListTile(
                                                  title: Text(
                                                    i.name ?? '-',
                                                    style:
                                                        fontStyleSubtitleSemiBoldPrimaryColor(
                                                            context),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        NumberHelper
                                                            .convertToIdrWithSymbol(
                                                                count: i.price,
                                                                decimalDigit:
                                                                    0),
                                                        style:
                                                            fontStyleSubtitleDefaultColor(
                                                                context),
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.end,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        child: Text(
                                                          '${i.stock} tersisa',
                                                          style:
                                                              fontStyleParagraftDefaultColor(
                                                                  context),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        child: Text(
                                                          '${i.soldCount} terjual',
                                                          style:
                                                              fontStyleParagraftDefaultColor(
                                                                  context),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                            ],
                          )
                  ],
                ),
              ),
            ),
    );
  }
}
