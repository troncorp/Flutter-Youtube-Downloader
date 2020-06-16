import 'dart:convert';

import 'api.dart';

class NetworkHelper {
  final url;
  NetworkHelper({this.url});

  Future<dynamic> getVedioData() async {
    var data = await getData(url);
    var decodedData = jsonDecode(data);
    return decodedData;
  }
}
