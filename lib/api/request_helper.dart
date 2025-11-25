import 'package:account_config_plugin/api/crypto_helper.dart';
import 'package:account_config_plugin/models/account_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class RequestHelper {
  late final CryptoHelper _cryptoHelper;

  RequestHelper() {
    _cryptoHelper = CryptoHelper();
  }

  Future<String?> _httpGet(String method, [Map<String, String>? params]) async {
    final response = await http.get(
      Uri.https('account.ramos.com.ge', method, params),
      headers: {
        'Content-Type': 'application/json',
        'apikey': _cryptoHelper.encrypt("${DateFormat('yyyy-MM-dd').format(DateTime.now())}ramos"),
      },
    );

    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes);
    } else {
      return null;
    }
  }

  Future<List<AccountModel>> getAccounts() async {
    String? response = await _httpGet('/api/get_companies/');
    if (response != null) {
      final parsed = jsonDecode(response);
      return parsed.map<AccountModel>((map) => AccountModel.fromMap(map)).toList();
    }

    return [];
  }

  Future<String?> getAccountUrl(int accountId) async {
    String? response = await _httpGet('/api/get_company_url/', {'account_id': accountId.toString()});
    if (response != null) {
      return jsonDecode(response);
    }

    return null;
  }
}
