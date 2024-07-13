import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_mart/activity/load_indicator.dart';
import 'package:phone_mart/controllers/firebase/auth_controller.dart';
import 'package:phone_mart/controllers/rongkir_controller.dart';
import 'package:phone_mart/models/rajaongkir_model.dart';
import 'package:phone_mart/models/user_model.dart';
import 'package:phone_mart/settings/app_settings.dart';
import 'package:phone_mart/settings/theme_settings.dart';
import 'package:phone_mart/style/font_style.dart';

class AddressManageActivity extends StatefulWidget {
  const AddressManageActivity({super.key});

  @override
  State<AddressManageActivity> createState() => _AddressManageActivityState();
}

class _AddressManageActivityState extends State<AddressManageActivity> {
  TextEditingController name = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();

  String _selectedProvince = '';
  String _selectedCity = '';

  bool isLoad = false;
  ProvinceRajaOngkirList provinceData = ProvinceRajaOngkirList(results: []);
  CityRajaOngkirList cityData = CityRajaOngkirList(results: []);
  selectProvince() async {
    setState(() {
      isLoad = true;
    });
    await getCity();
  }

  getProvince() async {
    var res = await RajaOngkirController().getProvince();
    if (res.error == null) {
      provinceData = res.data as ProvinceRajaOngkirList;
      _selectedProvince = provinceData.results![0].provinceId ?? '';
      await getCity();
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          res.error.toString(),
        ),
      ));
    }
  }

  getCity() async {
    var res =
        await RajaOngkirController().getCity(provinceId: _selectedProvince);
    if (res.error == null) {
      cityData = CityRajaOngkirList(results: []);
      cityData = res.data as CityRajaOngkirList;
      _selectedCity = cityData.results![0].cityId ?? '';

      if (!mounted) return;
      setState(() {
        isLoad = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _selectedCity = '';
        cityData = CityRajaOngkirList(results: []);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          res.error.toString(),
        ),
      ));
    }
  }

  void selectCity(CityRajaOngkir city) async {
    setState(() {
      isLoad = true;
    });
    if (!mounted) return;
    setState(() {
      address.text =
          'Kab. ${city.cityName}, ${city.province} - ${city.postalCode}';
      isLoad = false;
    });
  }

  final _formKey = GlobalKey<FormState>();

  User? user;
  getUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      if (!mounted) return;
      setState(() {
        user = _user;
      });
    });
  }

  void start() async {
    setState(() {
      isLoad = true;
    });
    await getUser();
    await getProvince();
    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
  }

  submit() async {
    setState(() {
      isLoad = true;
    });
    var res = await AuthController().addAdress(
        UserAdressesModel(
            address: address.text,
            cityId: _selectedCity,
            name: name.text,
            number: phone.text,
            title: title.text),
        user!);
    if (res!.error == null) {
      Navigator.pop(context);
    }
    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        res.message ?? '-',
      ),
    ));
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
          "Tambah Alamat",
          style: fontStyleTitleAppbar(context),
        ),
      ),
      body: isLoad
          ? loadIndicator()
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tambah Alamat: ",
                        style: fontStyleSubtitleSemiBoldPrimaryColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextFormField(
                        style: fontStyleParagraftDefaultColor(context),
                        validator: (value) =>
                            value!.isEmpty ? 'masukan judul alamat' : null,
                        controller: title,
                        decoration:
                            const InputDecoration(hintText: "Judul Alamat"),
                      ),
                      TextFormField(
                        style: fontStyleParagraftDefaultColor(context),
                        validator: (value) =>
                            value!.isEmpty ? 'isi nama pemilik alamat' : null,
                        controller: name,
                        decoration:
                            const InputDecoration(hintText: "Nama Penerima"),
                      ),
                      TextFormField(
                        style: fontStyleParagraftDefaultColor(context),
                        validator: (value) =>
                            value!.isEmpty ? 'isi nomor pemilik alamat' : null,
                        controller: phone,
                        decoration: const InputDecoration(
                            hintText: "Nomor Telepon Penerima"),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButton<String>(
                          value: _selectedProvince,
                          onChanged: (String? newValue) {
                            _selectedProvince = newValue!;
                            selectProvince();
                          },
                          hint: Text(
                            "Tidak Ditemukan Provinsi",
                            style: fontStyleParagraftDefaultColor(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isExpanded: true,
                          items: provinceData.results!
                              .map<DropdownMenuItem<String>>(
                                  (ProvinceRajaOngkir value) {
                            return DropdownMenuItem<String>(
                              value: value.provinceId,
                              child: Text(
                                value.province!,
                                style: fontStyleParagraftDefaultColor(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButton<String>(
                          value: _selectedCity,
                          onChanged: (String? newValue) {
                            _selectedCity = newValue!;
                            selectCity(cityData.results!.singleWhere(
                                (element) => element.cityId == _selectedCity));
                          },
                          hint: Text(
                            "Tidak Ditemukan Kota",
                            style: fontStyleParagraftDefaultColor(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isExpanded: true,
                          items: cityData.results!
                              .map<DropdownMenuItem<String>>(
                                  (CityRajaOngkir value) {
                            return DropdownMenuItem<String>(
                              value: value.cityId,
                              child: Text(
                                "${value.cityName} - ${value.postalCode}",
                                style: fontStyleParagraftDefaultColor(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      TextFormField(
                        maxLines: 3,
                        style: fontStyleParagraftDefaultColor(context),
                        validator: (value) =>
                            value!.isEmpty ? 'isi alamat lengkap' : null,
                        controller: address,
                        decoration:
                            const InputDecoration(hintText: "Alamat Lengkap"),
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
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
