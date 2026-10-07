import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/currency_rate.dart';

// HTTP-запросы к Апишке (формируем URL, get, получаем ответ)

class ApiClient {
  Future<CurrencyRate> getRate(
    String base,
    String quote,
  ) async {
    String address =
        'https://api.frankfurter.dev/v2/rate/'
        '${base.toLowerCase()}/${quote.toLowerCase()}';

    Uri url = Uri.parse(address);

    // Получаем данные о курсе с сервера и запускаем асинхронку,
    // чтбоы интерфейс не ждал
    http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Не удалось получить курс валют');
    }

    Map<String, dynamic> json = jsonDecode(response.body);

    CurrencyRate currencyRate = CurrencyRate.fromJson(json);

    return currencyRate;
  }
}