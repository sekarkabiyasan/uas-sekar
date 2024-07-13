class PaymentList {
  List<PaymentModel>? listPayment;

  PaymentList({this.listPayment});

  PaymentList.fromJson(Map<String, dynamic> json) {
    if (json['payment'] != null) {
      listPayment = <PaymentModel>[];
      json['payment'].forEach((v) {
        listPayment!.add(PaymentModel.fromJson(v));
      });
    }
  }
}

class PaymentModel {
  String? id;
  String? name;
  String? icon;

  PaymentModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  PaymentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['logo_url'];
  }
}
