import 'package:flutter/material.dart';

import '../models/currency_rate.dart';
import '../repositories/currency_repository.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({Key? key}) : super(key: key);

  @override
  State<ConverterPage> createState() {
    return _ConverterPageState();
  }
}

class _ConverterPageState extends State<ConverterPage> {
  final CurrencyRepository currencyRepository = CurrencyRepository();

  final TextEditingController amountController = TextEditingController();

  final List<String> currencies = [
    'EUR',
    'RUB',
    'USD',
    'GBP',
    'JPY',
    'CNY',
  ];

  // Храним последние конвертации
  final List<String> conversionHistory = [];

  String fromCurrency = 'EUR';
  String toCurrency = 'RUB';

  CurrencyRate? currencyRate;
  double? result;

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  // Меняем исходную и целевую валюты местами
  void _swapCurrencies() {
    setState(() {
      String oldFromCurrency = fromCurrency;

      fromCurrency = toCurrency;
      toCurrency = oldFromCurrency;

      result = null;
      currencyRate = null;
      errorMessage = null;
    });
  }

  // Проверяем сумму, получаем курс и считаем результат
  Future<void> _convert() async {
    String amountText =
        amountController.text.trim().replaceAll(',', '.');

    if (amountText.isEmpty) {
      setState(() {
        errorMessage = 'Введите сумму';
        result = null;
      });

      return;
    }

    double? amount = double.tryParse(amountText);

    if (amount == null) {
      setState(() {
        errorMessage = 'Введите корректную сумму';
        result = null;
      });

      return;
    }

    if (amount < 0) {
      setState(() {
        errorMessage = 'Сумма не может быть отрицательной';
        result = null;
      });

      return;
    }

    if (fromCurrency == toCurrency) {
      setState(() {
        errorMessage = 'Выберите разные валюты';
        result = null;
      });

      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      result = null;
    });

    try {
      CurrencyRate rate = await currencyRepository.getRate(
        fromCurrency,
        toCurrency,
      );

      double convertedAmount = amount * rate.rate;

      String historyItem =
          amount.toStringAsFixed(2) +
          ' ' +
          fromCurrency +
          ' → ' +
          convertedAmount.toStringAsFixed(2) +
          ' ' +
          toCurrency;

      setState(() {
        currencyRate = rate;
        result = convertedAmount;
        isLoading = false;

        conversionHistory.insert(0, historyItem);

        // Оставляем только 5 последних операций
        if (conversionHistory.length > 5) {
          conversionHistory.removeLast();
        }
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Не удалось получить курс валют';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер валют'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Сумма',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: fromCurrency,
                decoration: const InputDecoration(
                  labelText: 'Из валюты',
                  border: OutlineInputBorder(),
                ),
                items: _buildCurrencyItems(),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    fromCurrency = value;
                    result = null;
                    currencyRate = null;
                    errorMessage = null;
                  });
                },
              ),

              const SizedBox(height: 12),

              Center(
                child: IconButton(
                  onPressed: _swapCurrencies,
                  icon: const Icon(Icons.swap_vert),
                  iconSize: 32,
                ),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: toCurrency,
                decoration: const InputDecoration(
                  labelText: 'В валюту',
                  border: OutlineInputBorder(),
                ),
                items: _buildCurrencyItems(),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    toCurrency = value;
                    result = null;
                    currencyRate = null;
                    errorMessage = null;
                  });
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : _convert,
                child: const Text('Конвертировать'),
              ),

              const SizedBox(height: 24),

              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              if (errorMessage != null)
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),

              if (result != null && currencyRate != null)
                _buildResultCard(),

              if (conversionHistory.isNotEmpty)
                _buildHistory(),
            ],
          ),
        ),
      ),
    );
  }

  // Создаем список валют для выпадающего меню
  List<DropdownMenuItem<String>> _buildCurrencyItems() {
    List<DropdownMenuItem<String>> items = [];

    for (String currency in currencies) {
      items.add(
        DropdownMenuItem<String>(
          value: currency,
          child: Text(currency),
        ),
      );
    }

    return items;
  }

  // Создаем карточку с результатом конвертации
  Widget _buildResultCard() {
    CurrencyRate rate = currencyRate!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Результат',
              style: TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              result!.toStringAsFixed(2) + ' ' + toCurrency,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '1 ' +
                  fromCurrency +
                  ' = ' +
                  rate.rate.toStringAsFixed(4) +
                  ' ' +
                  toCurrency,
            ),

            const SizedBox(height: 6),

            Text(
              'Курс на ' + rate.date,
            ),
          ],
        ),
      ),
    );
  }

  // Показываем последние конвертации
  Widget _buildHistory() {
    List<Widget> historyItems = [];

    for (String item in conversionHistory) {
      historyItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          child: Text(item),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'История конвертаций',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...historyItems,
          ],
        ),
      ),
    );
  }
}