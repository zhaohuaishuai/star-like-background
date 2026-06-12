import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:m/core/constants/constants.dart';
import 'package:m/core/utils/toast.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/services/user.dart';


 


class CommonGetConnect extends GetConnect {


 


  GetStorage box = GetStorage();
  late final Map<String, int> errorTryCount = {};
  String cacheKeyPrefix = GetStorage.version + cacheSplit;

  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = baseApi;
    httpClient.timeout = const Duration(seconds: 5);

    httpClient.addRequestModifier<dynamic>((request) async {
      String? token = await box.readString(GetStorage.token);

      if (token != null) {
        request.headers.addAll({
          'Authorization': 'Bearer $token',
        });
      }

      // 注入设备指纹
      String fingerprint = await Utils.getOrCreateFingerprintId();
      request.headers.addAll({
        'fingerprintId': fingerprint,
      });

      debugPrint('【API请求】${request.method} ${request.url} headers=${request.headers}');
      return request;
    });

    httpClient.addResponseModifier((request, response) async {
      dynamic body = await errorTry(request, response);

      debugPrint("body:${body?["code"]}");
      return response;
    });
  }

  Future<Object?> errorTry(
      Request<Object?> request, Response<Object?> response) async {
    String url = request.url.toString().replaceAll(baseApi, '');

    if (!errorTryCount.containsKey(url)) {
      errorTryCount[url] = 0;
    }

    debugPrint('URL: $url');

    if (response.hasError || response.body == null) {
      HttpStatus httpStatus = response.status;

      if (httpStatus.code == HttpStatus.internalServerError) {
        Utils.showToast('服务器错误'.tr, ToastStatusEnum.error);
        return null;
      }

      errorTryCount[url] = errorTryCount[url]! + 1;

      if (errorTryCount[url]! >= 3) {
        debugPrint('已达最大重试次数: $url');
        return null;
      }
      String bodyString = await collectStreamToString(request.bodyBytes);
      String method = request.method;
      Object? res = await this.request(url, method, body: bodyString);

      return res;
    }

    if (response.body is Map) {
      Map body = response.body as Map;
      if (body['code'] == 401) {
        Utils.showToast('登录已过期，请重新登录'.tr, ToastStatusEnum.error);
      }
      if (body['code'] == 403) {
        Utils.showToast('权限不足'.tr, ToastStatusEnum.error);
      }
      if (body['code'] == 500) {
         Utils.showToast ( '服务器错误'.tr, ToastStatusEnum.error);
         
       
      }
    }

    return response.body;
  }

  Future<String> collectStreamToString(Stream<List<int>> byteStream) async {
    // 使用 reduce 收集所有数据
    var byteList = await byteStream
        .fold<List<int>>([], (prev, element) => prev..addAll(element));

    // 将字节数据转换为字符串
    return utf8.decode(byteList);
  }

  @override
  Future<Response<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,

    /// 是否缓存
    bool isCache = false,

    /// 缓存的本地key,默认是Version
    
    bool isLogin = false,
  }) async {
    String cacheKey = cacheKeyPrefix + url;
    if (isCache) {
      Response<T>? cache = await _readCache(cacheKey: cacheKey);
      if (cache != null) {
        return cache;
      }
    }

    if (isLogin) {
      if (!UserService.to.isLogin) {
        Toast.showToast('请先登录'.tr);
        return Future.value(Response<T>(body: null, statusCode: 401));
      }
    }

    Response<T> res = await super.get<T>(
      url,
      headers: headers,
      contentType: contentType,
      query: query,
      decoder: decoder,
    );
    // 缓存结果
    if (isCache) {
      await _writeResponseCache(res: res, cacheKey: cacheKey);
    }

    return res;
  }

  @override
  Future<Response<T>> post<T>(
    String? url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
    bool isCache = false,
     
    bool isLogin = false,
  }) async {
    String cacheKey = cacheKeyPrefix + url!;
    if (isCache) {
      Response<T>? cache = await _readCache(cacheKey: cacheKey);
      if (cache != null) {
        return cache;
      }
    }
    if (isLogin) {
      if (!UserService.to.isLogin) {
        Toast.showToast('请先登录'.tr);
        return Future.value(Response<T>(body: null, statusCode: 401));
      }
    }

    Response<T> res = await super.post<T>(
      url,
      body,
      contentType: contentType,
      headers: headers,
      query: query,
      decoder: decoder,
      uploadProgress: uploadProgress,
    );

    // 缓存结果
    if (isCache) {
      await _writeResponseCache(res: res, cacheKey: cacheKey);
    }

    return res;
  }

  _writeResponseCache<T>(
      {required Response<dynamic> res, required String cacheKey}) async {
    if (res.body != null) {
      await box.writeString(cacheKey, jsonEncode(res.body));
    }
  }

  _readCache<T>({required String cacheKey}) async {
    String? cache = await box.readString(cacheKey);
    if (cache != null) {
      return Future.value(
          Response<T>(body: jsonDecode(cache), statusCode: 200));
    }
  }
}
