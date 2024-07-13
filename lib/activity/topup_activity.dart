import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_mart/activity/load_indicator.dart';
import 'package:phone_mart/controllers/firebase/auth_controller.dart';
import 'package:phone_mart/models/payment_model.dart';
import 'package:phone_mart/settings/app_settings.dart';
import 'package:phone_mart/style/font_style.dart';
import 'package:flutter/services.dart' show rootBundle;

class TopUpActivity extends StatefulWidget {
  const TopUpActivity({super.key});

  @override
  State<TopUpActivity> createState() => _TopUpActivityState();
}

class _TopUpActivityState extends State<TopUpActivity> {
  bool isLoad = false;
  PaymentList? payment;
  TextEditingController price = TextEditingController();
  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return int.tryParse(str) != null;
  }

  getPayment() async {
    payment = PaymentList.fromJson(jsonDecode(await rootBundle
        .loadString('${AssetsSetting().imagePath}paymethod.json')));
  }

  void topUp() async {
    if (isNumeric(price.text)) {
      setState(() {
        isLoad = true;
      });
      var res = await AuthController().topup(int.parse(price.text), user!);

      if (res!.error == null) {
        Navigator.pop(context);
      } else {
        setState(() {
          isLoad = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          res.message!,
        )));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Jumlah topup hanya angka',
      )));
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

  void start() async {
    setState(() {
      isLoad = true;
    });
    await getUser();
    await getPayment();
    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
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
          "Topup saldo",
          style: fontStyleTitleAppbar(context),
        ),
      ),
      body: isLoad
          ? loadIndicator()
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                child: Column(
                  children: [
                    TextFormField(
                      controller: price,
                      keyboardType: TextInputType.number,
                      style: fontStyleParagraftDefaultColor(context),
                      decoration: InputDecoration(hintText: 'jumlah Topup'),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isPotrait ? 2 : 4),
                      itemCount: payment!.listPayment!.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () => topUp(),
                        child: Card(
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Image.network(
                                  payment!.listPayment![index].icon ?? '',
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    "${AssetsSetting().imagePath}err.png",
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  payment!.listPayment![index].name ?? '-',
                                  style: fontStyleSubtitleSemiBoldDefaultColor(
                                      context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
