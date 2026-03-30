// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroceryItemModel _$GroceryItemModelFromJson(Map<String, dynamic> json) =>
    GroceryItemModel(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as String?,
      category: json['category'] as String?,
      checked: json['checked'] as bool,
      addedBy: json['added_by'] as String,
      checkedBy: json['checked_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$GroceryItemModelToJson(GroceryItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'name': instance.name,
      'quantity': instance.quantity,
      'category': instance.category,
      'checked': instance.checked,
      'added_by': instance.addedBy,
      'checked_by': instance.checkedBy,
      'created_at': instance.createdAt.toIso8601String(),
    };
