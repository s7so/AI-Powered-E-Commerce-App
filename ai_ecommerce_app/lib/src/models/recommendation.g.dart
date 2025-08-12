// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationRequest _$RecommendationRequestFromJson(
  Map<String, dynamic> json,
) => RecommendationRequest(
  productId: json['productId'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
);

Map<String, dynamic> _$RecommendationRequestToJson(
  RecommendationRequest instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'name': instance.name,
  'category': instance.category,
};

RecommendationResponse _$RecommendationResponseFromJson(
  Map<String, dynamic> json,
) => RecommendationResponse(
  productIds: (json['productIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RecommendationResponseToJson(
  RecommendationResponse instance,
) => <String, dynamic>{'productIds': instance.productIds};
