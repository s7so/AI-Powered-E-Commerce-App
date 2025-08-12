import 'package:cloud_functions/cloud_functions.dart';
import '../models/recommendation.dart';

class FunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<List<String>> getRecommendations(RecommendationRequest request) async {
    final callable = _functions.httpsCallable('recommendProducts');
    final result = await callable.call(request.toJson());
    final data = Map<String, dynamic>.from(result.data as Map);
    final response = RecommendationResponse.fromJson(data);
    return response.productIds;
  }
}