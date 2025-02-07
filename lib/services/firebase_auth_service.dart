import 'dart:io';

import 'package:auth_management/auth_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// The FirebaseAuthService is a mixin that provides Firebase authentication
/// functionalities to an existing [BaseAuthService] class.
/// It has a generic type T that extends a [BaseUser] class.
mixin FirebaseAuthService<T extends BaseUser> on BaseAuthService<T> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  /// a client that initialize after any Firebase authentication method are called
  /// use any of this method to authenticate with Firebase authorization
  /// [signInWithEmailAndPasswords]
  /// [signInWithApple]
  /// [signInWithGoogle]
  /// [signInWithFacebook]
  ///
  ///
  /// you may also initialize this getter for custom authenticate
  @override
  FirebaseAuthClient get httpClient {
    if (super.httpClient == null) {
      throw AuthManagementException('httpClient are fail to create, please'
          ' signing first for this variable to be created');
    }

    return super.httpClient as FirebaseAuthClient;
  }

  /// stream firebase user auth state change instead of normal local database (isar) user.
  @override
  Stream<T?> userStream() {
    return firebaseAuth.userChanges().asyncMap((element) async {
      await _createFirebaseHttpClient(element);
      return await userMorph(element);
    });
  }

  User get user {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('user is null');
    }

    return user;
  }

  /// reload current user using firebase [firebaseAuth.currentUser.reload] method
  Future<void> reload() async {
    await firebaseAuth.currentUser?.reload();
  }

  /// create a firebase client
  Future<void> _createFirebaseHttpClient(dynamic userOrToken) async {
    print('masuk sini create firebase client $userOrToken');
    //assert if token is not User or string or null
    assert(userOrToken is User || userOrToken is String || userOrToken == null);
    if (userOrToken == null) {
      return httpClient = null;
    }

    final String token;
    if (userOrToken is User) {
      final innerToken = await userOrToken.getIdToken();
      if (innerToken != null) {
        token = innerToken;
      } else {
        throw AuthManagementException("Error while get token from user");
      }
    } else {
      token = userOrToken;
    }

    httpClient = FirebaseAuthClient(http.Client(), token);
  }

  /// a override method to to be implement so this service can morph [User]
  /// to your real user class [T].
  Future<T?> userMorph(User? user);

  /// Attempts to sign in the user using the provided email and password credentials.
  ///
  /// Throws an [AuthManagementException] with a descriptive message based on the
  /// error code provided by Firebase if the sign-in fails.
  ///
  /// If the sign-in is successful, returns a [UserCredential] object.
  ///
  /// Throws an [AuthManagementException] with the message
  /// "Error while sign in with firebase using sign in with email and password" if
  /// an unexpected error occurs.
  ///
  ///
  /// [email] a non-empty email string
  /// [password] a non-empty password string
  ///
  /// Example usage:
  /// ```
  /// final userCredential = await authService.signInWithEmailAndPasswords(
  ///   email: 'user@example.com',
  ///   password: 'password',
  /// );
  /// ```
  Future<UserCredential> signInWithEmailAndPasswords(
      {required String email, required String password}) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthManagementException("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        throw AuthManagementException("Wrong password provided for that user.");
      } else {
        rethrow;
      }
    } catch (e) {
      throw AuthManagementException(
          "Error while sign in with firebase using sign in with email and password");
    }
  }

  /// Authenticates a user with Firebase using Google Sign-In.
  ///
  /// Returns a [Future] that completes with a [UserCredential] object
  /// containing the user's Firebase authentication information after
  /// successful sign-in, or throws an error if authentication fails.
  ///
  /// To authenticate the user, this function first triggers the Google
  /// Sign-In flow and waits for the user to sign in with their Google account.
  /// It then obtains the user's authentication details from the Google sign-in
  /// response, creates a new [GoogleAuthProvider] credential object with the
  /// obtained access and ID tokens, and uses this credential to sign the user
  /// into Firebase using the [FirebaseAuth.signInWithCredential] method.
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  /// Authenticates a user with Firebase using Facebook Login.
  ///
  /// Returns a [Future] that completes with a [UserCredential] object
  /// containing the user's Firebase authentication information after
  /// successful sign-in, or returns `null` if authentication fails.
  ///
  /// To authenticate the user, this function first triggers the Facebook
  /// Login flow and waits for the user to sign in with their Facebook account.
  /// It then creates an [OAuthCredential] object with the obtained Facebook
  /// access token, and uses this credential to sign the user into Firebase
  /// using the [FirebaseAuth.signInWithCredential] method.
  ///
  /// If the login fails, this function returns `null`.
  Future<UserCredential?> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.accessToken == null) return null;

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);
  }

  Future<UserCredential> signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    return kIsWeb
        ? await FirebaseAuth.instance.signInWithPopup(appleProvider)
        : await FirebaseAuth.instance.signInWithProvider(appleProvider);
  }

  /// A function to end Firebase auth session in this device
  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
    super.signOut();
  }
}

// custom_http_client.dart
class FirebaseAuthClient extends http.BaseClient {
  final http.Client _inner;
  final String _firebaseAuthToken;

  FirebaseAuthClient(this._inner, this._firebaseAuthToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Add the Firebase Auth token to the 'Authorization' header
    request.headers[HttpHeaders.authorizationHeader] =
        'Bearer $_firebaseAuthToken';
    return _inner.send(request);
  }
}
