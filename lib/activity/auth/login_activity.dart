import 'package:flutter/material.dart';
import 'package:phone_mart/activity/auth/register_activity.dart';
import 'package:phone_mart/activity/load_indicator.dart';
import 'package:phone_mart/activity/navbar_activity.dart';
import 'package:phone_mart/controllers/firebase/auth_controller.dart';
import 'package:phone_mart/settings/app_settings.dart';
import 'package:phone_mart/settings/theme_settings.dart';
import 'package:phone_mart/style/font_style.dart';

class LoginActivity extends StatefulWidget {
  const LoginActivity({super.key, this.email, this.pw});

  //untuk menerima autofield
  final String? email;
  final String? pw;

  @override
  State<LoginActivity> createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
//Membuat form key untuk validasi textform
  final _formKey = GlobalKey<FormState>();

  //Membuat controller untuk textform
  TextEditingController _emailCtrl = TextEditingController();
  TextEditingController _passwordCtrl = TextEditingController();

  //Untuk mengatur situasi loading
  bool isLoad = false;

  //untuk mengatur situasi hide password
  bool obscureTextPassword = true;

  void login() async {
    setState(() {
      isLoad = true;
    });
    AuthController()
        .login(email: _emailCtrl.text, password: _passwordCtrl.text)
        .then((value) {
      if (value!.error == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const NavbarActivity(),
            ),
            (route) => false);
      } else {
        if (!mounted) return;
        setState(() {
          isLoad = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            value.message ?? "Terjadi kesalahan tak diketahui",
          ),
        ));
      }
    });
  }

  @override
  void initState() {
    //Ketika class login dipanggil maka akan cek apakah autofield ada, jika ada akan dijadikan default value untuk textform
    if (widget.email != null) {
      _emailCtrl.text = widget.email ?? '';
    }
    if (widget.pw != null) {
      _passwordCtrl.text = widget.pw ?? '';
    }
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
          "Masuk",
          style: fontStyleTitleAppbar(context),
        ),
      ),
      body: isLoad
          ? loadIndicator()
          : Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSetting().paddingScreen),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: fontStyleSubtitleSemiBoldDefaultColor(context),
                      //Validasi untuk cek isi dari textform email dan apakah sesuai dengan format email
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        final RegExp emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                        if (!emailRegex.hasMatch(value)) {
                          return 'Masukkan email yang valid';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(hintText: "Email"),
                    ),
                    TextFormField(
                      controller: _passwordCtrl,
                      keyboardType: TextInputType.visiblePassword,
                      style: fontStyleSubtitleSemiBoldDefaultColor(context),
                      obscureText: obscureTextPassword,
                      //Validasi untuk cek isi dari textform apakah pw lebih dari 8 karakter
                      validator: (value) => value!.length < 8
                          ? "Password harus lebih dari 8 digit"
                          : null,
                      decoration: InputDecoration(
                          hintText: "Password",
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureTextPassword = !obscureTextPassword;
                                });
                              },
                              icon: Icon(obscureTextPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility))),
                    ),
                    Expanded(
                        child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: isPotrait
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      login();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // <-- Radius
                                      ),
                                      elevation: 0,
                                      backgroundColor: ThemeSettings()
                                          .primaryColor(context)),
                                  child: Text(
                                    "Masuk",
                                    style: fontStyleSubtitleSemiBoldWhiteColor(
                                        context),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Belum punya akun? ",
                                    style:
                                        fontStyleSubtitleSemiBoldDefaultColor(
                                            context),
                                  ),
                                  InkWell(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RegisterAcitvity(),
                                          )),
                                      child: Text(
                                        "Daftar",
                                        style:
                                            fontStyleSubtitleSemiBoldPrimaryColor(
                                                context),
                                      ))
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
    );
  }
}
