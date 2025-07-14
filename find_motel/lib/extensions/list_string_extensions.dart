import 'package:cloud_firestore/cloud_firestore.dart';

extension ListStringX on List<String> {
  Query<Map<String, dynamic>> applyArrayContainsAny(
    Query<Map<String, dynamic>> query,
    String field,
  ) {
    if (isEmpty) return query;
    return query.where(field, arrayContainsAny: this);
  }

  Query<Map<String, dynamic>> applyWhereIn(
      Query<Map<String, dynamic>> query, String field) {
    if (isEmpty) return query;
    return query.where(field, whereIn: this);
  }

  Query<Map<String, dynamic>> applyWhereNotIn(
      Query<Map<String, dynamic>> query, String field) {
    if (isEmpty) return query;
    return query.where(field, whereNotIn: this);
  }
}
