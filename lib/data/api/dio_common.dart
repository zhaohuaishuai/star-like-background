import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:m/core/constants/constants.dart';
import 'package:m/core/utils/utils.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';



final _dio = Dio(BaseOptions(baseUrl: baseApi));


extension A on Response {
 dynamic get  body => data;
}

 
class _DioCommon extends InterceptorsWrapper  {

  String cacheKeyPrefix = GetStorage.version + cacheSplit;
  GetStorage box = GetStorage();
  _DioCommon() { 
    _init();
  } 
  void _init() { 
    _dio.interceptors
    ..add(RetryInterceptor(
        dio: _dio,
        logPrint: debugPrint, // specify log function (optional)
        retries: 3, // retry count (optional)
        retryDelays: const [ // set delays between retries (optional)
          Duration(seconds: 1), // wait 1 sec before first retry
          Duration(seconds: 2), // wait 2 sec before second retry
          Duration(seconds: 3), // wait 3 sec before third retry
        ],
))
    ..add(this); 
  }

 Future<Response<T>> get<T>(String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress, 
     /// 是否缓存
    bool isCache = false, 
    /// 缓存的本地key,默认是Version 
    bool isLogin = false,
  }) async { 
    options = _getOptions(options, isCache, isLogin); 
    return  await _dio.get<T>(path,
      queryParameters: queryParameters,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
 }


Future<Response<T>> post<T>(String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress, 
     /// 是否缓存
    bool isCache = false, 
    /// 缓存的本地key,默认是Version 
    bool isLogin = false,
  }) async { 
    options = _getOptions(options, isCache, isLogin); 
    return  await _dio.post<T>(path,
      queryParameters: queryParameters,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
 }



Future<Response<T>> delete<T>(String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress, 
     /// 是否缓存
    bool isCache = false, 
    /// 缓存的本地key,默认是Version 
    bool isLogin = false,
  }) async { 
    options = _getOptions(options, isCache, isLogin); 
    return  await _dio.delete<T>(path,
      queryParameters: queryParameters,
      data: data,
      options: options,
      cancelToken: cancelToken,
      
    );
 }



  

 Options _getOptions(Options? options, bool isCache, bool isLogin) {
      options = options ?? Options();
   Map<String,dynamic > extra = options.extra  ?? {};
   extra = {...extra,'isCache':isCache,'isLogin':isLogin};
  options = options.copyWith(extra: extra);
   return options;
 }


  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint('请求前 ${options.extra}'); 

    if(options.extra['isCache']){
      Response? cacheRes = await _readCache(cacheKey: cacheKeyPrefix + options.path);
      if(cacheRes != null){
        return handler.resolve(cacheRes);
      }
    }

    await _setToken(options); 
    return super.onRequest(options, handler);
  }

  Future<void> _setToken(RequestOptions options) async {
    String? token = await box.readString(GetStorage.token); 
    if(token != null){
      options.headers['Authorization'] = 'Bearer $token';
    }
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    
    if(response.requestOptions.extra['isCache'] && response.statusCode == 200){ 
      await _writeResponseCache(res: response, cacheKey: cacheKeyPrefix + response.requestOptions.path);
    }
    return super.onResponse(response, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
  
    return super.onError(err, handler);
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
      return Future.value( Response<T>(data: jsonDecode(cache), statusCode: 200, requestOptions: RequestOptions()));
    }
  }
   

}



// ignore: library_private_types_in_public_api
final _DioCommon dioCommon = _DioCommon();

 


abstract class RequestCommon {


 Future<Response<T>> get<T>( String url, {
  Map<String, String>? headers,
  String? contentType,
  Map<String, dynamic>? query,
  T Function(dynamic)? decoder,
  bool isCache = false,
  bool isLogin = false,
  CancelToken? cancelToken,
  ProgressCallback? onReceiveProgress,
  Object? data,
  }) async { 
     
    return  await dioCommon.get<T>(url,
      queryParameters: query,
      data: data,
      options: Options(
        headers: headers,
        contentType: contentType,
      ),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
 }


Future<Response<T>> post<T>(
  
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    
   
    bool isCache = false,
     
    bool isLogin = false,

    }
  ) async { 
     
    return  await dioCommon.post<T>(
      url,
 
      data: body,
      options: Options(
        headers: headers,
        contentType: contentType,
      ),
      
    );
 }




  Future<Response<T>> delete<T>(String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress, 
     /// 是否缓存
    bool isCache = false, 
    /// 缓存的本地key,默认是Version 
    bool isLogin = false,
  }) async {  
    return  await dioCommon.delete<T>(path,
      queryParameters: queryParameters,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
 }


  


}