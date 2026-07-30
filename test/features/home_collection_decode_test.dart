import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:urbanthread/core/domain/result.dart';
import 'package:urbanthread/core/network/api_envelope.dart';
import 'package:urbanthread/core/network/network_info.dart';
import 'package:urbanthread/features/home/data/datasource/home_local_datasource.dart';
import 'package:urbanthread/features/home/data/datasource/home_remote_datasource.dart';
import 'package:urbanthread/features/home/data/models/home_product_model.dart';
import 'package:urbanthread/features/home/data/repositories/home_repository_impl.dart';
import 'package:urbanthread/features/home/domain/entities/home_product.dart';

class MockRemote extends Mock implements HomeRemoteDataSource {}

class MockLocal extends Mock implements HomeLocalDataSource {}

class FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onStatusChange => const Stream<bool>.empty();
}

/// Retrofit maps the whole `data` array in a single expression, so a row that
/// fails to decode does not cost one card — it throws a raw `TypeError` that
/// [ErrorMapper] can only report as `UnexpectedFailure`, and the rail renders
/// "Something unexpected happened. Please try again." instead of its products.
///
/// `/products/new-arrivals` is where this bites first: it is the only
/// collection query filtered on `isActive` alone, so a product the other three
/// rails exclude — no sales, no stock, not featured — appears only here. And
/// `slug` is not `required` in the backend's schema, so a product created
/// without one is a payload the endpoint is entitled to return.
void main() {
  Map<String, dynamic> row({
    String id = 'p1',
    String? name = 'Essential Cotton Crew Tee',
    String? slug = 'essential-cotton-crew-tee-ab12c',
  }) =>
      {
        '_id': id,
        'name': ?name,
        'slug': ?slug,
        'price': 1899,
        'discountPercentage': 15,
        'effectivePrice': 1614.15,
        'images': [
          {'url': 'https://example.test/1.jpg', 'isPrimary': true},
        ],
        'rating': {'average': 4.4, 'count': 12},
        'totalStock': 40,
        'category': {'_id': 'c1', 'name': 'T-Shirts', 'slug': 't-shirts'},
        'brand': {'_id': 'b1', 'name': 'Everlane', 'slug': 'everlane'},
        'isNewArrival': true,
      };

  ApiEnvelope<List<HomeProductModel>> envelope(
    List<Map<String, dynamic>> rows,
  ) =>
      ApiEnvelope<List<HomeProductModel>>(
        success: true,
        message: 'New arrivals fetched successfully',
        // Decoded exactly as the generated client does it.
        data: rows.map(HomeProductModel.fromJson).toList(),
      );

  late MockRemote remote;
  late MockLocal local;
  late HomeRepositoryImpl repository;

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    repository = HomeRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: FakeNetworkInfo(),
    );
    when(() => local.write(HomeCollection.newArrivals, any()))
        .thenAnswer((_) async {});
    when(() => local.read(HomeCollection.newArrivals)).thenReturn(const []);
  });

  test('a row with no slug does not cost the rail its other products',
      () async {
    final rows = [
      for (var i = 0; i < 9; i++) row(id: 'p$i'),
      row(id: 'unslugged', slug: null),
    ];
    when(() => remote.getNewArrivals(limit: any(named: 'limit')))
        .thenAnswer((_) async => envelope(rows));

    final result = await repository.getCollection(
      HomeCollection.newArrivals,
      limit: 10,
    );

    expect(result, isA<Success<List<HomeProduct>>>());
    final products = (result as Success<List<HomeProduct>>).value;
    // Nine drawn; the tenth is dropped because product detail is slug-only
    // and the card would have nowhere to go.
    expect(products, hasLength(9));
    expect(products.every((product) => product.slug.isNotEmpty), isTrue);
  });

  test('a row with no name is dropped too', () async {
    when(() => remote.getNewArrivals(limit: any(named: 'limit'))).thenAnswer(
      (_) async => envelope([row(), row(id: 'unnamed', name: null)]),
    );

    final result = await repository.getCollection(HomeCollection.newArrivals);

    expect(
      (result as Success<List<HomeProduct>>).value.map((p) => p.id),
      ['p1'],
    );
  });

  test('a well-formed payload is untouched', () async {
    when(() => remote.getNewArrivals(limit: any(named: 'limit'))).thenAnswer(
      (_) async => envelope([row(id: 'a'), row(id: 'b'), row(id: 'c')]),
    );

    final result = await repository.getCollection(HomeCollection.newArrivals);

    expect((result as Success<List<HomeProduct>>).value, hasLength(3));
  });
}
