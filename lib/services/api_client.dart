import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/currency_rate.dart';

// HTTP-запросы к Апишке (формируем URL, get, получаем ответ)

class ApiClient {
  // позже вернется объект CurrencyRate
  Future<CurrencyRate> getRate(
    String fromCurrency,
    String toCurrency,
  ) async {
    String address =
        'https://api.frankfurter.dev/v2/rate/'
        '${fromCurrency.toLowerCase()}/${toCurrency.toLowerCase()}';

    Uri url = Uri.parse(address);

    http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Не удалось получить курс валют');
    }

    Map<String, dynamic> json = jsonDecode(response.body);

    CurrencyRate currencyRate = CurrencyRate.fromJson(json);

    return currencyRate;
  }
}