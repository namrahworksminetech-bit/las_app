import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/results/result.dart';

class DemoRepository {

  final _api = ApiClient();

  Future<Result<List<dynamic>>> getPosts() async {

    try {
      final res = await _api.get<List>(ApiConstants.posts);
      return Success(res.data ?? []);
    } catch (e) {
      return Failure(e.toString());
    }

  }
  
}
