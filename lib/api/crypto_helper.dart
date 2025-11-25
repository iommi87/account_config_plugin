import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class CryptoHelper {
  String encrypt(String text) {
    final key = Key(Uint8List.fromList(md5.convert(utf8.encode('ramos')).bytes));
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(text, iv: iv);

    final combined = iv.bytes + encrypted.bytes;

    return base64Encode(combined);
  }
}
