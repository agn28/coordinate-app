import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:nhealth/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:nhealth/models/auth.dart';


class ApiService {
  var client = http.Client();
  int timeout = 15;

  var defaultHeaders = {
    "Accept": "application/json"
  };

  getHeaders(additionalHeaders, auth) async {
    var headers = defaultHeaders;
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    if (auth) {
      //get token form local storge;
      var data = await Auth().getStorageAuth() ;
      var token = data['accessToken'];
      if (data != null && data['accessToken'] != null) {
        headers['Authorization'] = 'Bearer ' + data['accessToken'];
      }
      
    }

    return headers;
  }


  Future get(url, { additionalHeaders, auth = true }) async {
    var response;
    
    try {
      response = await client.get(
        apiUrl + url,
        headers: await getHeaders(additionalHeaders, auth)
      ).timeout(Duration(seconds: timeout));
      
      if (response.statusCode == 401) {

      }

      return response;
      
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);
      return null;
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);
      return null;
    } on Error catch(err) {

      // showErrorSnackBar('Error', 'unknownError'.tr);
      return null;
    }
  }

  Future post(String url, body, { additionalHeaders, auth = true }) async {

    var response;

    try {
      response = await client.post(
        apiUrl + url,
        body: json.encode(body),
        headers: await getHeaders(additionalHeaders, auth)
      ).timeout(Duration(seconds: timeout));


      return response;
      
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);

      return;
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);

      return;
    } on Error catch(err) {

      // showErrorSnackBar('Error', 'unknownError'.tr);
      return;
    }

  }

  Future put(url, body, { additionalHeaders, auth = true }) async {

    var response;

    try {
      response = await client.put(
        apiUrl + url,
        body: body,
        headers: await getHeaders(additionalHeaders, auth)
      ).timeout(Duration(seconds: timeout));

      return response;
      
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);
      return null;
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);
      return null;
    } on Error catch(err) {

      // showErrorSnackBar('Error', 'unknownError'.tr);
      return null;
    }

  }
  Future patch(url, body, { additionalHeaders, auth = true }) async {

    var response;

    try {
      response = await client.patch(
        apiUrl + url,
        body: body,
        headers: await getHeaders(additionalHeaders, auth)
      ).timeout(Duration(seconds: timeout));

      return response;
      
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);
      return null;
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);
      return null;
    } on Error catch(err) {

      // showErrorSnackBar('Error', 'unknownError'.tr);
      return null;
    }
  }
  
  Future delete(url, { additionalHeaders, auth = true }) async {

    var response;

    try {
      response = await client.post(
        apiUrl + url,
        headers: await getHeaders(additionalHeaders, auth)
      ).timeout(Duration(seconds: timeout));

      return response;
      
    } on SocketException {
      // showErrorSnackBar('Error', 'socketError'.tr);
      return null;
    } on TimeoutException {
      // showErrorSnackBar('Error', 'timeoutError'.tr);
      return null;
    } on Error catch(err) {

      // showErrorSnackBar('Error', 'unknownError'.tr);
      return null;
    }
  }
}
