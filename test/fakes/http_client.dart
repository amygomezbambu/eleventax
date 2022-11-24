import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

enum HttpMethod { get, post }

class HttpMockClientResponse {
  final String response;
  final HttpMethod method;
  final int statusCode;

  HttpMockClientResponse({
    required this.response,
    required this.method,
    required this.statusCode,
  });
}

class HttpMockClient implements Client {
  final List<HttpMockClientResponse> _responses = [];

  void agregarRespuesta(HttpMockClientResponse respuesta) {
    _responses.add(respuesta);
  }

  @override
  void close() {}

  @override
  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) {
    // TODO: implement head
    throw UnimplementedError();
  }

  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement patch
    throw UnimplementedError();
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    var respuesta =
        _responses.firstWhere((resp) => resp.method == HttpMethod.post);

    return Response(respuesta.response, respuesta.statusCode);
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement put
    throw UnimplementedError();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    // TODO: implement readBytes
    throw UnimplementedError();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    // TODO: implement send
    throw UnimplementedError();
  }
}
