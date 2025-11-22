/// Utility to parse heterogeneous Supabase RPC responses that may return
/// Map, List<[bool, text]>, List<Map>, bool, or null. Returns a normalized
/// success flag and optional error message.
class RpcParseResult {
  final bool success;
  final String? errorMessage;
  const RpcParseResult(this.success, this.errorMessage);
}

RpcParseResult parseRpcAddExpenseResponse(dynamic response) {
  bool isSuccess = true;
  String? errorMessage;

  void extractFromMap(Map map) {
    bool? ok;
    String? err;
    if (map.containsKey('success')) ok = map['success'] == true;
    if (map.containsKey('ok')) ok = ok ?? (map['ok'] == true);
    if (map.containsKey('error_message'))
      err = (map['error_message'])?.toString();
    if (map.containsKey('error')) err = err ?? (map['error'])?.toString();
    ok = ok ??
        map.values.cast<dynamic>().firstWhere(
              (v) => v is bool,
              orElse: () => true,
            ) as bool?;
    final strVal = map.values.cast<dynamic>().firstWhere(
          (v) => v is String && v.isNotEmpty,
          orElse: () => null,
        );
    err = err ?? (strVal is String ? strVal : null);
    isSuccess = ok ?? true;
    errorMessage = err;
  }

  if (response == null) {
    isSuccess = true;
  } else if (response is Map) {
    extractFromMap(response);
  } else if (response is List) {
    final first = response.isNotEmpty ? response.first : null;
    if (first is Map) {
      extractFromMap(first);
    } else if (first is List) {
      if (first.isNotEmpty && first[0] is bool) {
        isSuccess = first[0] as bool;
        if (first.length > 1 && first[1] is String) {
          errorMessage = first[1] as String;
        }
      }
    } else if (first is bool) {
      isSuccess = first;
    }
  } else if (response is bool) {
    isSuccess = response;
  }

  return RpcParseResult(isSuccess, errorMessage);
}
