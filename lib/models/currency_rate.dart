// Описываем какие данные получаем от API

/* Пример ответа от АПИ:
{
  "date": "2026-10-06",
  "base": "EUR",
  "quote": "RUB",
  "rate": 95.12
} */

class CurrencyRate {
  final String date;
  final String base;
  final String quote;
  final double rate;

  CurrencyRate({
    required this.date,
    required this.base,
    required this.quote,
    required this.rate,
  });

  // САМ создает объект курса валют из данных, которые пришли от API
  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      date: json['date'],
      base: json['base'],
      quote: json['quote'],
      rate: (json['rate'] as num).toDouble(),
    );
  }
}