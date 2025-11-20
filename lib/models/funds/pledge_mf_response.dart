class PledgeMfResponse {
  final String? status;
  final Map<String, dynamic>? data;
  final String? message;
  final String? error;

  PledgeMfResponse({
    this.status,
    this.data,
    this.message,
    this.error,
  });

  factory PledgeMfResponse.fromJson(Map<String, dynamic> json) {
    return PledgeMfResponse(
      status: json['status'] as String?,
      data: json['data'] != null && json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      message: json['message'] as String?,
      error: null,
    );
  }

  factory PledgeMfResponse.error(String errorMessage, {String? message}) {
    return PledgeMfResponse(
      status: null,
      data: null,
      message: message,
      error: errorMessage,
    );
  }

  /// Robust extraction: handles String, List<String>, or nested map shapes.
  String? extractInnerStatus() {
    final inner = data?['status'];
    if (inner == null) {
      // maybe backend put status elsewhere e.g. data['data'] is a map with status
      final nested = data?['data'];
      if (nested is Map && nested['status'] != null) {
        return _stringFromDynamic(nested['status']);
      }
      return null;
    }
    return _stringFromDynamic(inner);
  }

  String? _stringFromDynamic(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is List && v.isNotEmpty) {
      // prefer explicit markers
      if (v.contains('mf_fetched')) return 'mf_fetched';
      // return first string-looking item
      for (final item in v) {
        if (item is String && item.isNotEmpty) return item;
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'PledgeMfResponse(status: $status, data: $data, message: $message, error: $error)';
  }
}
