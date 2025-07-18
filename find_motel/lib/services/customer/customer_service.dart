import 'package:find_motel/common/models/deal.dart';

abstract class ICustomerService {
  Future<(List<Deal>? deals, String? error)> fetchDeals({String? saleId});
  Future<(bool result, String? error)> addDeal(Deal deal);
  Future<(bool result, String? error)> deleteDeal(String id);
  Future<(bool result, String? error)> updateDeal(Deal deal);
}