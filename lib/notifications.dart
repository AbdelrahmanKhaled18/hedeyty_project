import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class Notifications {
  final String projectId = "hedieaty-475f4";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch the Firebase Admin SDK Access Token
  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "hedieaty-475f4",
      "private_key_id": "5e14ff73cfbe17160c0e408703c9de0fa00f2f3d",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDx9SHsDlAoFkNy\n+NejWatJcSJITRI1BDY2KetectOZ7MxGd7qfT9HLrjRlKyypps4EnsuJ2yRfI/sE\nz581OEf6zeGEgYHzpo06EfFI4gp5pQqbngp8GmuUykFjUZwdP83T6OzR0wIyIzby\nykHdt0+dN3wDs9cdJiBA8ENe4ronPRMKu1Xaq6GRoCEnaO1nwEz5/1mXchdIJmGn\nBK+Qb8S67FqlrIiKN5PFyQVj9twlEUAfrgRWQn9Bzm0va7WICHFmkk+KRgUNT1En\nKS5yJy4YArgk26Ty5A8ve7SCNH1DuIUHEY+l6PnpofSFdPgIo6NoFOtr/ufGOL4Z\ncqtasyLtAgMBAAECggEAP21fQx5NbPTJIa6R+MRc3pfFwOZTS4qbG3/Jr6yyQ7uL\noT1psrGd8aLtIUg8IQ0VHKjz+mN0GWy5NP2oYq8qT1kBMVcx1clnZD2n3s9Cp7jY\nGwtG/FmAsjSDB6IxJom/TznUOvzxqmsI0ISs145iVHhjDiVq0r1X3y4cuxb8baRW\nhWVcX5SV81YCFnx5sNHBpasAcgN2BUXc4EdWiF3z/QAmXgmEUFha67q9HG3EfXDM\nxThtj9c28ISGl1nGJRGB2i99Pc4jLleXwZH6PflScvGaVrNJOy7Pych4T+NnxzPZ\n+l/AQVxGJJsypxxfKOmlvGmq59nHs6u7OYlwEHxgEQKBgQD8rRbq+NlNSkQACRrv\nev0MidzDaq8JAk2/iX8GOLGIVphb83zL+1f1/M7R0kLEQjmLjrvh1sVsomBE92Rg\n9VJp9w92oa04h7fEYEw3dFAj+U67HC4pOGVXf9SzFqpBYhpR+P55ITPG5Qo/A3TW\nU/4o1R1kYnC/6Jm9MH7ANpvykwKBgQD1I/J4/olZ0rcQa/2GCqH0sI68mruqETer\ngDk0//BblJr+L8YzvR3LYYoSzJvwnmXUERO1xqT3U/q3kZu49rto1VrNRDe/o+Oi\nGQgPul/ia2mz1d7lbfZrBrrxFUwDGWm661vx2GJbW1s4yAzLJCdgYIz3IVPAEryk\nrvKz2/aEfwKBgQDjYGNyOVNawQzmN0tc3AEhKmJWHAe9BKywQuvizlu8A6kBfd/8\ns4aZHtGCcUKR18Ju+pfKB/oK4yfch/91XO2325K3v4/gggj1l26erHV9mdimehp0\nD4LqtWbTbf7x7XUf9QASQrWUMwIAaHzYbicV2Ymkjw1FNOw8GorFL58wLwKBgQCb\natT5nPbbudpSUQUFDIyto5p7POap5gyTcNHUJkfu6AJ0ETnp54aSQR7W2F4taV9J\n2iHS50QDgny8EVbXJ6adylatOQjXOULCrHgN8K2F0W/MklWkw9is9jFjU4tDk8MS\nvNEoPXXuUbc+AqcJy7wjQFNfAwQkDD0Jc9lv6o8aZQKBgQDLWUKFAST2BJSsrRVj\n4wW4MocLKReEBjcYC1LSSp62M3fhunO/AjmwypqhgPYJs9kAy8WXT2GCqWaXEEwz\ngAo3TvhwmtpQ7Uwd8wAjfdiYvgEJ0tmjZ9/zGN2owg//YAj8eHV4+c5nobNG1Znb\n9Cwgf1ch+5Y9gQcb+NtkDR0jBw==\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-3hznl@hedieaty-475f4.iam.gserviceaccount.com",
      "client_id": "116689738222293608930",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-3hznl%40hedieaty-475f4.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    final client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    final credentials = client.credentials.accessToken.data;
    client.close();

    return credentials;
  }

  /// Send a Push Notification via FCM
  Future<void> sendPledgeNotification({
    required String toUserId,
    required String giftName,
    required String pledgedByName,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(toUserId).get();

      if (!userDoc.exists) {
        print('User not found.');
        return;
      }

      final fcmToken = userDoc['fcm_token'];
      print(fcmToken);
      if (fcmToken == null || fcmToken.isEmpty) {
        print('No FCM token found for user $toUserId.');
        return;
      }

      final notificationPayload = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': 'Gift Pledged! 🎁',
            'body': '$pledgedByName pledged to you The gift "$giftName".',
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'giftName': giftName,
          },
        },
      };

      final String fcmEndpoint =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final String accessToken = await getAccessToken();

      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(notificationPayload),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully to $toUserId.');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending pledge notification: $e');
    }
  }
}
