import 'package:find_motel/common/models/customer.dart';

abstract class ICustomerService {
  Future<(List<Customer>?, String?)> fetchCustomers({String? saleId});
  Future<(bool, String?)> addCustomer(Customer customer);
  Future<(bool, String?)> deleteCustomer(String id);
  Future<(bool, String?)> updateCustomer(Customer customer);
}