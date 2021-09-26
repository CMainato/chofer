import 'dart:convert';

import 'package:http/http.dart' as http;

class ResquestAssistant
{
  static Future<dynamic> getRequest(String url) async

  {

    http.Response response = await http.get(Uri.parse(url));

    try
    {
      if(response.statusCode == 200)
      {
        String jSonData = response.body;
        var decodeData = jsonDecode(jSonData);
        return decodeData;
      }
      else
      {
        return "failed";
      }
    }
    catch(exp)
    {
      return "failed";
    }
  }
}