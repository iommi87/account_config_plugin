import 'package:account_config_plugin/api/crypto_helper.dart';
import 'package:account_config_plugin/models/account_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dart:convert';

class RequestHelper {
  late final CryptoHelper _cryptoHelper;

  late BuildContext context;

  RequestHelper(BuildContext context) {
    _cryptoHelper = CryptoHelper();

    context = context;
  }

  Future<String?> _httpGet(String method, [Map<String, String>? params]) async {
    try {
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
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

  Future<String?> getAccountUrl(int accountId, String type) async {
    String? response = await _httpGet('/api/get_company_url/', {'account_id': accountId.toString(), 'type': type});
    if (response != null) {
      return jsonDecode(response);
    }

    return null;
  }
}
