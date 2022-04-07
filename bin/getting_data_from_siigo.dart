import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main(List<String> arguments) async {
  String brand = "CASMARA";
  // "$customer, ${invoice['name']},${invoice['date']},${product['description']},${invoice['total']},");
  print(
      "CC,NOMBRE,APELLIDO,DEPARTAMENTO,CIUDAD,TEL1,TEL2,FACTURA,FECHA,PRODUCTO,TOTAL_PEDIDO");
  var headers = {'Authorization': ''};
  var request = http.Request(
      'GET', Uri.parse('https://api.siigo.com/v1/invoices?page_size=100'));
  request.body = '''''';
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    // Setting number of page
    var pageSize = 100;
    var totalResults =
        json.decode(await response.stream.bytesToString())["pagination"]
            ['total_results'];
    // var results = json.decode(await response.stream.bytesToString())["results"];
    for (var i = 1; i <= totalResults / pageSize; i++) {
      print("page $i");
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api.siigo.com/v1/invoices?page=$i&page_size=$pageSize'));
      request.body = '''''';
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        List invoices =
            json.decode(await response.stream.bytesToString())["results"];
        for (var invoice in invoices) {
          for (var product in invoice['items']) {
            // invoice['items'].forEach((product) async {
            try {
              if (product['description'].toString().contains(brand)) {
                String customer = await getCustomerInfo(invoice['customer']);
                print(
                    "$customer, ${invoice['name']},${invoice['date']},${product['description']},${invoice['total']},");
              }
            } catch (e) {}
          }
          // );
        }
      }
    }
  } else {
    print(response.reasonPhrase);
  }
}

// Get Customer Informaction
getCustomerInfo(customer) async {
  var headers = {'Authorization': ''};
  var request = http.Request(
      'GET', Uri.parse('https://api.siigo.com/v1/customers/${customer['id']}'));
  request.body = '''''';
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  if (response.statusCode == 200) {
    var customerData = json.decode(await response.stream.bytesToString());
    var secondName = "";
    try {
      secondName =
          customerData['name'][1] != null ? customerData['name'][1] : '';
    } catch (e) {}
    var customerDataString =
        "${customerData['identification']},${customerData['name'][0]},$secondName,${customerData['address']['city']['state_name']},${customerData['address']['city']['city_name']},${customerData['phones'][0]['number']},${customerData['contacts'][0]['phone']['number']}";
    return customerDataString;
  } else {
    print(response.reasonPhrase);
    return "";
  }
}
