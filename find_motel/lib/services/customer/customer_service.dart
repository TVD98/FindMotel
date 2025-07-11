import 'package:find_motel/common/models/deal.dart';

abstract class ICustomerService {
  Future<(List<Deal>?, String?)> fetchDeals({String? saleId});
  Future<(bool, String?)> addDeal(Deal customer);
  Future<(bool, String?)> deleteDeal(String id);
  Future<(bool, String?)> updateDeal(Deal customer);
}