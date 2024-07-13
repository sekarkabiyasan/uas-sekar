import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_mart/activity/load_indicator.dart';
import 'package:phone_mart/controllers/firebase/product_controller.dart';
import 'package:phone_mart/models/product_model.dart';
import 'package:phone_mart/models/void_error.dart';
import 'package:phone_mart/settings/app_settings.dart';
import 'package:phone_mart/settings/theme_settings.dart';
import 'package:phone_mart/style/font_style.dart';

class ProductManage extends StatefulWidget {
  const ProductManage({super.key, this.productKey});
  final String? productKey;

  @override
  State<ProductManage> createState() => _ProductManageState();
}

class _ProductManageState extends State<ProductManage> {
//Untuk kebutuhan update
//mengambil currentproduct
  ProductModel? currentProduct;

  void getCurrentProduct() {}

//Untuk kebutuhan textform
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController stock = TextEditingController();
  TextEditingController desc = TextEditingController();
  TextEditingController weight = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<File> _image = [];

  bool isLoad = false;

  void _showPicker(
      {required BuildContext context, int? indexImgFile, int? indexImgString}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  await _pickImageFromGallery(
                    indexImgFile: indexImgFile,
                    indexImgString: indexImgString,
                  );
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () async {
                  await _pickImageFromCamera(
                    indexImgFile: indexImgFile,
                    indexImgString: indexImgString,
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //Untuk cek apakah angka

  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return int.tryParse(str) != null;
  }

  Future<void> _pickImageFromGallery(
      {int? indexImgFile, int? indexImgString}) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _image.add(File(pickedFile.path));
        if (indexImgFile != null) {
          _image.removeAt(indexImgFile);
        }
        if (indexImgString != null) {
          currentProduct!.imgUrl!.removeAt(indexImgString);
        }
      });
    }
  }

  User? user;
  getUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      if (!mounted) return;
      setState(() {
        user = _user;
      });
    });
  }

  Future<void> _pickImageFromCamera(
      {int? indexImgFile, int? indexImgString}) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _image.add(File(pickedFile.path));
        if (indexImgFile != null) {
          _image.removeAt(indexImgFile);
        }
        if (indexImgString != null) {
          currentProduct!.imgUrl!.removeAt(indexImgString);
        }
      });
    }
  }

  void submit() async {
    currentProduct ??=
        ProductModel(imgUrl: [], soldCount: 0, createdAt: Timestamp.now());
    if (currentProduct!.imgUrl!.isNotEmpty || _image.isNotEmpty) {
      setState(() {
        isLoad = true;
      });

      var res = await ProductController().addProduct(
          productId: widget.productKey,
          imageFile: _image,
          product: ProductModel(
              sellerId: user!.uid,
              active: true,
              desc: desc.text,
              imgUrl: currentProduct!.imgUrl,
              name: name.text,
              price: int.parse(price.text),
              weight: int.parse(weight.text),
              stock: int.parse(stock.text),
              createdAt: currentProduct!.createdAt,
              soldCount: currentProduct!.soldCount));

      if (res!.error == null) {
        setState(() {
          isLoad = false;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            res.error ?? 'Berhasil mengupload produk',
          ),
        ));
      } else {
        setState(() {
          isLoad = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            res.error ?? 'Gagal mengupload produk',
          ),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Pilih minimal 1 foto',
        ),
      ));
    }
  }

  void delete() async {
    setState(() {
      isLoad = true;
    });

    var res = await ProductController().deleteProduct(
      productId: widget.productKey ?? '',
    );

    if (res!.error == null) {
      setState(() {
        isLoad = false;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          res.error ?? 'Berhasil menghapus produk',
        ),
      ));
    } else {
      setState(() {
        isLoad = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          res.error ?? 'Gagal menghapus produk',
        ),
      ));
    }
  }

  List<FuncError> err = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  getMyPrduct() async {
    setState(() {
      isLoad = true;
    });
    var snapshot = await firestore
        .collection(ProductFirebase().collection)
        .doc(widget.productKey)
        .get();

    currentProduct = ProductModel.fromSnapshot(snapshot);
    if (!mounted) return;
    setState(() {
      name.text = currentProduct!.name ?? '';
      price.text = currentProduct!.price.toString();
      stock.text = currentProduct!.stock.toString();
      weight.text = currentProduct!.weight.toString();
      desc.text = currentProduct!.desc ?? '';
      isLoad = false;
    });
  }

  void start() async {
    setState(() {
      isLoad = true;
    });
    await getUser();
    if (widget.productKey != null) {
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          isLoad
              ? "Loading..."
              : currentProduct != null
                  ? currentProduct!.name ?? '-'
                  : "Tambah Produk",
          style: fontStyleTitleAppbar(context),
        ),
      ),
      body: isLoad
          ? loadIndicator()
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      currentProduct != null &&
                              currentProduct!.imgUrl!.isNotEmpty
                          ? ListView.separated(
                              itemCount: currentProduct!.imgUrl!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 10,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () => _showPicker(
                                      context: context, indexImgString: index),
                                  child: Image.network(
                                    currentProduct!.imgUrl![index],
                                    width: MediaQuery.of(context).size.width,
                                    height: isPotrait
                                        ? MediaQuery.of(context).size.width *
                                            0.3
                                        : MediaQuery.of(context).size.height *
                                            0.3,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      "${AssetsSetting().imagePath}err.png",
                                      width: MediaQuery.of(context).size.width,
                                      height: isPotrait
                                          ? MediaQuery.of(context).size.width *
                                              0.3
                                          : MediaQuery.of(context).size.height *
                                              0.3,
                                    ),
                                  ),
                                );
                              },
                            )
                          : SizedBox(),
                      const SizedBox(
                        height: 10,
                      ),
                      _image.isNotEmpty
                          ? ListView.separated(
                              itemCount: _image.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 10,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () => _showPicker(
                                      context: context, indexImgFile: index),
                                  child: Image.file(
                                    _image[index],
                                    width: MediaQuery.of(context).size.width,
                                    height: isPotrait
                                        ? MediaQuery.of(context).size.width *
                                            0.3
                                        : MediaQuery.of(context).size.height *
                                            0.3,
                                  ),
                                );
                              },
                            )
                          : SizedBox(),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () => _showPicker(context: context),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: isPotrait
                              ? MediaQuery.of(context).size.width * 0.3
                              : MediaQuery.of(context).size.height * 0.3,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey[400]!,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Ketuk untuk upload gambar",
                              textAlign: TextAlign.center,
                              style: fontStyleParagraftDefaultColor(context),
                            ),
                          ), // Ganti dengan widget anak yang sesuai
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Nama Produk :",
                        style: fontStyleSubtitleSemiBoldDefaultColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextFormField(
                        controller: name,
                        validator: (value) =>
                            value!.isEmpty ? "isi nama produk" : null,
                        style: fontStyleParagraftDefaultColor(context),
                        decoration: InputDecoration(hintText: 'nama Produk'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Harga Produk :",
                        style: fontStyleSubtitleSemiBoldDefaultColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextFormField(
                        controller: price,
                        keyboardType: TextInputType.number,
                        validator: (value) => !isNumeric(value ?? "")
                            ? "harga produk hanya angka"
                            : null,
                        style: fontStyleParagraftDefaultColor(context),
                        decoration: InputDecoration(hintText: 'harga Produk'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Stok :",
                        style: fontStyleSubtitleSemiBoldDefaultColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextFormField(
                        controller: stock,
                        keyboardType: TextInputType.number,
                        validator: (value) => !isNumeric(value ?? "")
                            ? "stock hanya angka"
                            : null,
                        style: fontStyleParagraftDefaultColor(context),
                        decoration: InputDecoration(hintText: 'harga Produk'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Berat/gram :",
                        style: fontStyleSubtitleSemiBoldDefaultColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextFormField(
                        controller: weight,
                        keyboardType: TextInputType.number,
                        validator: (value) => !isNumeric(value ?? "")
                            ? "berat hanya angka"
                            : null,
                        style: fontStyleParagraftDefaultColor(context),
                        decoration: InputDecoration(hintText: 'harga Produk'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Deskripsi Produk :",
                        style: fontStyleSubtitleSemiBoldDefaultColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextFormField(
                        controller: desc,
                        maxLines: 4,
                        validator: (value) =>
                            value!.isEmpty ? "isi deskripsi produk" : null,
                        style: fontStyleParagraftDefaultColor(context),
                        decoration:
                            InputDecoration(hintText: 'Deskripsi Produk'),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              submit();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10), // <-- Radius
                              ),
                              elevation: 0,
                              backgroundColor:
                                  ThemeSettings().primaryColor(context)),
                          child: Text(
                            "Simpan",
                            style: fontStyleSubtitleSemiBoldWhiteColor(context),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: currentProduct != null,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              delete();
                            },
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10), // <-- Radius
                                ),
                                elevation: 0,
                                backgroundColor:
                                    ThemeSettings().backgroundGrey(context)),
                            child: Text(
                              "Hapus",
                              style:
                                  fontStyleSubtitleSemiBoldDangerColor(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
