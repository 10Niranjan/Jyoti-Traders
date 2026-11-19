import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/services/image_upload_service.dart';

void main() {
  late HttpServer server;
  late File photo;
  String? seenPath;
  String? seenBody;
  int status = 200;

  setUp(() async {
    status = 200;
    seenPath = null;
    seenBody = null;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      seenPath = req.uri.path;
      seenBody = latin1.decode(
        await req.fold<List<int>>([], (a, b) => a..addAll(b)),
      );
      req.response
        ..statusCode = status
        ..write(
          status == 200
              ? jsonEncode({'secure_url': 'https://res.cloudinary.com/x/a.jpg'})
              : '{"error":{"message":"Upload preset not found"}}',
        );
      await req.response.close();
    });
    photo = File('${Directory.systemTemp.path}/jt_upload_test.jpg')
      ..writeAsBytesSync([1, 2, 3, 4]);
  });

  tearDown(() => server.close(force: true));

  ImageUploadService service() => ImageUploadService(
    cloudName: 'democloud',
    preset: 'demo_preset',
    cloudinaryHost: 'http://127.0.0.1:${server.port}',
  );

  test(
    'uploads to the right Cloudinary URL and returns the secure_url',
    () async {
      final url = await service().uploadProductImage(
        productId: 'p1',
        localFilePath: photo.path,
      );
      expect(url, 'https://res.cloudinary.com/x/a.jpg');
      expect(seenPath, '/v1_1/democloud/image/upload');
      expect(seenBody, contains('name="upload_preset"'));
      expect(seenBody, contains('demo_preset'));
      expect(seenBody, contains('product_images'));
    },
  );

  test('a Cloudinary error throws instead of saving a broken URL', () async {
    status = 400;
    expect(
      service().uploadPaymentScreenshot(
        orderId: 'o1',
        localFilePath: photo.path,
      ),
      throwsA(isA<HttpException>()),
    );
  });

  test('blank Cloudinary settings keep the old simulation fallback', () async {
    final url = await ImageUploadService(
      cloudName: '',
      preset: '',
    ).uploadCategoryIcon(categoryId: 'c1', localFilePath: photo.path);
    expect(url, photo.path);
  });
}
