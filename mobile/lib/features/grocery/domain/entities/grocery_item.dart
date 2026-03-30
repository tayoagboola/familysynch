import 'package:freezed_annotation/freezed_annotation.dart';

part 'grocery_item.freezed.dart';

@freezed
class GroceryItem with _$GroceryItem {
  const factory GroceryItem({
    required String id,
    required String householdId,
    required String name,
    String? quantity,
    String? category,
    @Default(false) bool checked,
    required String addedBy,
    String? checkedBy,
    required DateTime createdAt,
  }) = _GroceryItem;
}
