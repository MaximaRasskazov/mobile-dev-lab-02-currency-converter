import '../models/currency_rate.dart';
import '../services/api_client.dart';

class CurrencyRepository {
  final ApiClient apiClient = ApiClient();

  Future<CurrencyRate> getRate(
    String fromCurrency,
    String toCurrency,
  ) async {
    CurrencyRate currencyRate = await apiClient.getRate(
      fromCurrency,
      toCurrency,
    );

    return currencyRate;
  }
}