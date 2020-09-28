import 'dart:convert';

import 'package:http/http.dart';

/// Root class for all errors related to InfluxDB API calls.
class InfluxDBAPIError implements Exception {
  /// Cause of the error.
  String cause;

  /// Creates an instance of [InfluxDBAPIError].
  InfluxDBAPIError(this.cause);
}

/// Main class for all errors related to HTTP in InfluxDB API calls.
class InfluxDBAPIHTTPError extends InfluxDBAPIError {
  /// Response from the HTTP call.
  final Response response;
  /// Field "code", if present in HTTP `response.body` message.
  String responseCode;
  /// Field "message", if present in HTTP `response.body` message.
  String responseMessage;

  /// Creates an instance of [InfluxDBAPIHTTPError] based on cause string and HTTP [Response].
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

  /// Creates a human readable message from the error, that can be presented to the user.
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

  /// Creates an instance of [InfluxDBAPIHTTPError] or its subclasses based on HTTP [Response].
  static InfluxDBAPIHTTPError fromResponse(Response response) {
    switch (response.statusCode) {
      case 400:
        return InfluxDBAPIHTTPBadRequestError(response);
        break;
      case 401:
        return InfluxDBAPIHTTPUnauthorizedError(response);
        break;
      case 500:
        return InfluxDBAPIHTTPInternalError(response);
        break;
      default:
        return InfluxDBAPIHTTPError(response.body, response);
    }
  }
}

/// Class for reporting HTTP internal error (code `500`) from the server
class InfluxDBAPIHTTPInternalError extends InfluxDBAPIHTTPError {
  InfluxDBAPIHTTPInternalError(Response response) : super("Internal error from server", response);
}

/// Class for reporting HTTP bad request error (code `400`) from the server
class InfluxDBAPIHTTPBadRequestError extends InfluxDBAPIHTTPError {
  InfluxDBAPIHTTPBadRequestError(Response response) : super("Bad request", response);
}

/// Class for reporting HTTP unauthorized error (code `401`) from the server
class InfluxDBAPIHTTPUnauthorizedError extends InfluxDBAPIHTTPError {
  InfluxDBAPIHTTPUnauthorizedError(Response response) : super("Unauthorized", response);
}
