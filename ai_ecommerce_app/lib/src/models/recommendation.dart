import 'package:json_annotation/json_annotation.dart';

part 'recommendation.g.dart';

@JsonSerializable()
class RecommendationRequest {
  final String productId;
  final String name;
  final String category;
  RecommendationRequest({required this.productId, required this.name, required this.category});
  factory RecommendationRequest.fromJson(Map<String, dynamic> json) => _$RecommendationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationRequestToJson(this);
}

@JsonSerializable()
class RecommendationResponse {
  final List<String> productIds;
  RecommendationResponse({required this.productIds});
  factory RecommendationResponse.fromJson(Map<String, dynamic> json) => _$RecommendationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationResponseToJson(this);
}