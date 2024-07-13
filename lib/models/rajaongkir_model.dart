class RajaOngkir {
  String payload = 'rajaongkir';
  String status = 'status';
  String messageStatus = 'description';
}

class CityRajaOngkirList {
  List<CityRajaOngkir>? results;

  CityRajaOngkirList({this.results});

  CityRajaOngkirList.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <CityRajaOngkir>[];
      json['results'].forEach((v) {
        results!.add(CityRajaOngkir.fromJson(v));
      });
    }
  }
}

class CityRajaOngkir {
  String? cityId;
  String? provinceId;
  String? province;
  String? type;
  String? cityName;
  String? postalCode;

  CityRajaOngkir(
      {this.cityId,
      this.provinceId,
      this.province,
      this.type,
      this.cityName,
      this.postalCode});

  CityRajaOngkir.fromJson(Map<String, dynamic> json) {
    cityId = json['city_id'];
    provinceId = json['province_id'];
    province = json['province'];
    type = json['type'];
    cityName = json['city_name'];
    postalCode = json['postal_code'];
  }
}

class ProvinceRajaOngkirList {
  List<ProvinceRajaOngkir>? results;

  ProvinceRajaOngkirList({this.results});

  ProvinceRajaOngkirList.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ProvinceRajaOngkir>[];
      json['results'].forEach((v) {
        results!.add(ProvinceRajaOngkir.fromJson(v));
      });
    }
  }
}

class ProvinceRajaOngkir {
  String? provinceId;
  String? province;

  ProvinceRajaOngkir({this.provinceId, this.province});

  ProvinceRajaOngkir.fromJson(Map<String, dynamic> json) {
    provinceId = json['province_id'];
    province = json['province'];
  }
}

class CheckOngkirResponseList {
  List<CheckOngkirResponse>? results;

  CheckOngkirResponseList({this.results});

  CheckOngkirResponseList.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <CheckOngkirResponse>[];
      json['results'].forEach((v) {
        results!.add(CheckOngkirResponse.fromJson(v));
      });
    }
  }
}

class CheckOngkirResponse {
  String? code;
  String? name;
  List<CostsCheckOngkirResponse>? costs;

  CheckOngkirResponse({this.code, this.name, this.costs});

  CheckOngkirResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    if (json['costs'] != null) {
      costs = <CostsCheckOngkirResponse>[];
      json['costs'].forEach((v) {
        costs!.add(CostsCheckOngkirResponse.fromJson(v));
      });
    }
  }
}

class CostsCheckOngkirResponse {
  String? service;
  String? description;
  List<CostCheckOngkirResponse>? cost;

  CostsCheckOngkirResponse({this.service, this.description, this.cost});

  CostsCheckOngkirResponse.fromJson(Map<String, dynamic> json) {
    service = json['service'];
    description = json['description'];
    if (json['cost'] != null) {
      cost = <CostCheckOngkirResponse>[];
      json['cost'].forEach((v) {
        cost!.add(CostCheckOngkirResponse.fromJson(v));
      });
    }
  }
}

class CostCheckOngkirResponse {
  int? value;
  String? etd;
  String? note;

  CostCheckOngkirResponse({this.value, this.etd, this.note});

  CostCheckOngkirResponse.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    etd = json['etd'];
    note = json['note'];
  }
}
