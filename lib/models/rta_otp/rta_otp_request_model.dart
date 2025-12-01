class RtaOtpRequestModel {
  final String reqId;
  final List<OtpDetail> otpDetails;

  RtaOtpRequestModel({
    required this.reqId,
    required this.otpDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'req_id': reqId,
      'otp_details': otpDetails.map((x) => x.toJson()).toList(),
    };
  }
}

class OtpDetail {
  final String phone;
  final String rta;
  final String otp;
  final String refNo;

  OtpDetail({
    required this.phone,
    required this.rta,
    required this.otp,
    required this.refNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'rta': rta,
      'otp': otp,
      'ref_no': refNo,
    };
  }
}