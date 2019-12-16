import 'dart:convert';

import 'package:http/http.dart';

class InfluxDBAPIError implements Exception {
  String cause;
  InfluxDBAPIError(this.cause);
}

class InfluxDBAPIHTTPError extends InfluxDBAPIError {
  final Response response;
  String responseCode;
  String responseMessage;

  InfluxDBAPIHTTPError(String cause, this.response) : super(cause) {
    dynamic body;
    try {
      body = json.decode(response.body);
    } catch (e) {
      // ignore
    }
    if (body != null) {
      if (body["message"] != null) {
        responseMessage = body["message"].toString();
      }
      if (body["code"] != null) {
        responseCode = body["code"].toString();
      }
    }
  }

  String readableMessage() {
    String result = "";
    if (responseCode != null) {
      result += "$cause - $responseCode:\n\n";
    } else {
      result += "$cause:\n\n";
    }
    if (responseMessage != null) {
      result += "$responseMessage\n";
    }
    return result;
  }

  static InfluxDBAPIHTTPError fromResponse(Response response) {
    switch (response.statusCode) {
      case 400:
        return InfluxDBAPIHTTPBadRequestError(response);
        break;
      case 401:
        return InfluxDBAPIHTTPUnauthorizedError(response);
        break;
      case 400:
        return InfluxDBAPIHTTPInternalError(response);
        break;
      default:
        return InfluxDBAPIHTTPError("Unknown error", response);
    }
  }
}

class InfluxDBAPIHTTPInternalError extends InfluxDBAPIHTTPError {
  InfluxDBAPIHTTPInternalError(Response response) : super("Internal error from server", response);
}

class InfluxDBAPIHTTPBadRequestError extends InfluxDBAPIHTTPError {
  InfluxDBAPIHTTPBadRequestError(Response response) : super("Bad request", response);
}

class InfluxDBAPIHTTPUnauthorizedError extends InfluxDBAPIHTTPError {
  InfluxDBAPIHTTPUnauthorizedError(Response response) : super("Unauthorized", response);
}