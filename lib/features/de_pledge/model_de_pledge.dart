part of 'view_de_pledge.dart';

List<ClientModel> clientFromJson(List<dynamic> list) =>
    List<ClientModel>.from(list.map((x) => ClientModel.fromJson(x)));

class ClientModel {
  String? leadId;
  String? name;
  String? maskedPan;
  String? mobileNumber;
  double? portfolio;
  String? lamfLink;
  String? laipLink;
  String? lasLink;

  ClientModel({
    this.leadId,
    this.name,
    this.maskedPan,
    this.mobileNumber,
    this.portfolio,
    this.lamfLink,
    this.laipLink,
    this.lasLink,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
        leadId: json['lead_id'],
        name: json['name'],
        maskedPan: json['masked_pan'],
        mobileNumber: json['mobile_number'],
        portfolio: double.tryParse(json['portfolio']),
        lamfLink: json['lamf_link'],
        laipLink: json['laip_link'],
        lasLink: json['las_link'],
      );

  Map<String, dynamic> toJson() => {
        'lead_id': leadId,
        'name': name,
        'masked_pan': maskedPan,
        'mobile_number': mobileNumber,
        'portfolio': portfolio,
        'lamf_link': lamfLink,
        'laip_link': laipLink,
        'las_link': lasLink,
      };
}
