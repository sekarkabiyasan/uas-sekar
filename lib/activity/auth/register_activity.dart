import 'package:flutter/material.dart';
import 'package:phone_mart/activity/auth/login_activity.dart';
import 'package:phone_mart/activity/load_indicator.dart';
import 'package:phone_mart/controllers/firebase/auth_controller.dart';
import 'package:phone_mart/settings/app_settings.dart';
import 'package:phone_mart/settings/theme_settings.dart';
import 'package:phone_mart/style/font_style.dart';

class RegisterAcitvity extends StatefulWidget {
  const RegisterAcitvity({super.key});

  @override
  State<RegisterAcitvity> createState() => _RegisterAcitvityState();
}

class _RegisterAcitvityState extends State<RegisterAcitvity> {
  //Membuat form key untuk validasi textform
  final _formKey = GlobalKey<FormState>();

  //Membuat controller untuk textform
  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _emailCtrl = TextEditingController();
  TextEditingController _passwordCtrl = TextEditingController();

  //Untuk mengatur situasi loading
  bool isLoad = false;

  //untuk mengatur situasi hide password
  bool obscureTextPassword = true;
  void register() async {
    //Mengubah login menjadi aktif
    setState(() {
      isLoad = true;
    });
    //Memanggil controller registrasi
    AuthController()
        .register(
            name: _nameCtrl.text,
            email: _emailCtrl.text,
            password: _passwordCtrl.text)
        .then((value) {
      if (value!.error == null) {
        if (!mounted) return;
        //Memberikan aksi jika berhasil
        setState(() {
          isLoad = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginActivity(
                email: _emailCtrl.text,
                pw: _passwordCtrl.text,
              ),
            ));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Registrasi berhasil",
          ),
        ));
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
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Daftar",
          style: fontStyleTitleAppbar(context),
        ),
      ),
      body: isLoad ? loadIndicator(): Padding(
        padding:
            EdgeInsets.symmetric(horizontal: ScreenSetting().paddingScreen),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                keyboardType: TextInputType.name,
                style: fontStyleSubtitleSemiBoldDefaultColor(context),
                //Validasi untuk cek isi dari textform nama
                validator: (value) =>
                    value!.isEmpty ? "nama tidak boleh kosong" : null,
                decoration: const InputDecoration(hintText: "Nama"),
              ),
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
                                register();
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
                              "Daftar",
                              style:
                                  fontStyleSubtitleSemiBoldWhiteColor(context),
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
                              "Sudah punya akun? ",
                              style: fontStyleSubtitleSemiBoldDefaultColor(
                                  context),
                            ),
                            InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginActivity(
                                        //Mengirim auto field
                                        email: _emailCtrl.text,
                                        pw: _passwordCtrl.text,
                                      ),
                                    )),
                                child: Text(
                                  "Masuk",
                                  style: fontStyleSubtitleSemiBoldPrimaryColor(
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
