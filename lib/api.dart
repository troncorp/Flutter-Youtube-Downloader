import 'package:http/http.dart' as http;

Future getData(String url) async {
  String reqUrl = 'http://10.0.2.2:5000/api?link=${url.toString()}';
  print(reqUrl);
  http.Response response = await http.get(reqUrl);
  return response.body;
}
