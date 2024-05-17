import 'package:json_annotation/json_annotation.dart';

part 'products_category.g.dart';

@JsonSerializable()
class ProductsCategory {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "name")
  String? name;

  ProductsCategory({
    this.id,
    this.name,
  });

  factory ProductsCategory.fromJson(Map<String, dynamic> json) => _$ProductsCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsCategoryToJson(this);
}
