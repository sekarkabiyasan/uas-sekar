import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_mart/activity/address_activity.dart';
import 'package:phone_mart/activity/auth/login_activity.dart';
import 'package:phone_mart/activity/load_indicator.dart';
import 'package:phone_mart/activity/topup_activity.dart';
import 'package:phone_mart/activity/unauth_activifty.dart';
import 'package:phone_mart/controllers/firebase/auth_controller.dart';
import 'package:phone_mart/controllers/rongkir_controller.dart';
import 'package:phone_mart/helpers/number_helper.dart';
import 'package:phone_mart/models/rajaongkir_model.dart';
import 'package:phone_mart/models/user_model.dart';
import 'package:phone_mart/models/void_error.dart';
import 'package:phone_mart/settings/app_settings.dart';
import 'package:phone_mart/settings/theme_settings.dart';
import 'package:phone_mart/style/font_style.dart';

class ProfileActivity extends StatefulWidget {
  const ProfileActivity({super.key});

  @override
  State<ProfileActivity> createState() => _ProfileActivityState();
}

class _ProfileActivityState extends State<ProfileActivity> {
  bool isLoad = false;
  User? user;
  UserModel userDetail = UserModel(addresses: []);
  List<FuncError> err = [];

  int page = 0;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  getUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) async {
      if (!mounted) return;

      user = _user;
      if (user != null) {
        nameCtrl.text = user!.displayName ?? "";
      }
    });
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

  void start() async {
    setState(() {
      isLoad = true;
    });
    await getUser();
    if (user != null) {
      await getUserDetail();
      await getUserAddresses();
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

  //imagepicker
  File? _imageFile;

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  _pickImageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  _pickImageFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  TextEditingController nameCtrl = TextEditingController();
  void updateUname() async {
    setState(() {
      isLoad = true;
    });
    if (nameCtrl.text == "") {
      setState(() {
        isLoad = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "nama tidak boleh kosong",
      )));
    } else {
      setState(() {
        isLoad = false;
      });
      final res = await AuthController().updateName(nameCtrl.text);
      if (res!.error == null) {
        await getUser();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          res.message ?? "-",
        )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          res.message ?? "-",
        )));
      }
    }
  }

  void logout() async {
    if (!mounted) return;
    setState(() {
      isLoad = true;
    });
    final res = await AuthController().logOutRes();
    if (res!.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        res.message ?? "",
      )));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginActivity(),
        ),
      );
    } else {
      setState(() {
        isLoad = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        res.message ?? "Terjadi kesalahan tidak diketahui",
      )));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        updateimage();
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        updateimage();
      });
    }
  }

  void updateimage() async {
    setState(() {
      isLoad = true;
    });
    final res = await AuthController().updateImage(_imageFile);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      res!.message ?? "-",
    )));
    await getUser();
    setState(() {
      isLoad = false;
    });
  }

  void addAdrress() async {
    setState(() {
      isLoad = true;
    });
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddressManageActivity(),
        ));
    if (!mounted) return;
    setState(() {
      start();
    });
  }

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: isLoad
          ? loadIndicator()
          : user == null
              ? unAuth(context)
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: InkWell(
                                    onTap: () {
                                      _showPicker(context);
                                    },
                                    child: Image.network(
                                      user!.photoURL ??
                                          'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.2,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                        "${AssetsSetting().imagePath}err.png",
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: nameCtrl,
                                        style:
                                            fontStyleSubtitleSemiBoldPrimaryColor(
                                                context),
                                        decoration:
                                            InputDecoration(hintText: 'nama'),
                                      ),
                                      Text(
                                        user!.email ?? '-',
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                    onPressed: updateUname,
                                    icon: Icon(Icons.check))
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Text(
                              "Saldo: ",
                              style: fontStyleSubtitleSemiBoldPrimaryColor(
                                  context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    NumberHelper.convertToIdrWithSymbol(
                                        count: userDetail.balance,
                                        decimalDigit: 0),
                                    textAlign: TextAlign.end,
                                    style:
                                        fontStyleSubtitleSemiBoldPrimaryColor(
                                            context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          isLoad = true;
                                        });
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TopUpActivity(),
                                            ));
                                        if (!mounted) return;
                                        setState(() {
                                          start();
                                        });
                                      },
                                      icon: Icon(Icons.add))
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ExpansionTile(
                          title: Text(
                            "Alamat Kamu : ",
                            style: fontStyleParagraftBoldDefaultColor(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          children: [
                            userDetail.addresses!.length <= 0
                                ? Center(
                                    child: Text(
                                      "Belum ada alamat yang disimpan",
                                      style: fontStyleParagraftDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Sebagai Alamat Toko",
                                            style:
                                                fontStyleSubtitleSemiBoldPrimaryColor(
                                                    context),
                                          )
                                        ],
                                      ),
                                      ListView.separated(
                                        itemCount: userDetail.addresses!.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        separatorBuilder: (context, index) =>
                                            Divider(),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          var i = userDetail.addresses![index];
                                          return ListTile(
                                            title: Text(
                                              i.title ?? '-',
                                              style:
                                                  fontStyleSubtitleSemiBoldPrimaryColor(
                                                      context),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${i.cityData!.cityName} (${i.cityData!.province})',
                                                  style:
                                                      fontStyleParagraftBoldDefaultColor(
                                                          context),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  i.address ?? '',
                                                  style:
                                                      fontStyleParagraftDefaultColor(
                                                          context),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '${i.name} (${i.number})',
                                                  style:
                                                      fontStyleParagraftDefaultColor(
                                                          context),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            trailing: Checkbox(
                                              value:
                                                  userDetail.addressId == i.id,
                                              onChanged: (value) async {
                                                setState(() {
                                                  isLoad = true;
                                                });
                                                await AuthController()
                                                    .sebagaiAlamatToko(
                                                        i.id!, user!);

                                                start();
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                    onTap: addAdrress, child: Icon(Icons.add)),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: user != null ? logout : null,
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10), // <-- Radius
                                ),
                                elevation: 0,
                                backgroundColor:
                                    ThemeSettings().errorColor(context)),
                            child: Text(
                              "Logout",
                              style:
                                  fontStyleSubtitleSemiBoldWhiteColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    ));
  }
}
