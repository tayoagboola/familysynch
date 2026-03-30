import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/grocery_item.dart';

part 'grocery_item_model.g.dart';

@JsonSerializable()
class GroceryItemModel {
  const GroceryItemModel({
    required this.id,
    required this.householdId,
    required this.name,
    this.quantity,
    this.category,
    required this.checked,
    required this.addedBy,
    this.checkedBy,
    required this.createdAt,
  });

  final String id;
  @JsonKey(name: 'household_id')
  final String householdId;
  final String name;
  final String? quantity;
  final String? category;
  final bool checked;
  @JsonKey(name: 'added_by')
  final String addedBy;
  @JsonKey(name: 'checked_by')
  final String? checkedBy;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  factory GroceryItemModel.fromJson(Map<String, dynamic> json) =>
      _$GroceryItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroceryItemModelToJson(this);

  GroceryItem toDomain() => GroceryItem(
        id: id,
        householdId: householdId,
        name: name,
        quantity: quantity,
        category: category,
        checked: checked,
        addedBy: addedBy,
        checkedBy: checkedBy,
        createdAt: createdAt,
      );
}
