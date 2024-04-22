import 'dart:io';

import 'package:auth_management/auth_management.dart';
import 'package:auth_management/models/user_auth_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class BaseAuthService<T extends BaseUser> {
  static late final Isar isar;
  static late final BaseAuthService authService;

  /// a client that initialize after any OAUTH2 authentication method are called
  /// use any of this method to authenticate with OAuth2 server
  /// [signInWithResourceOwnerPasswordGrant]
  ///
  /// you may also initialize this getter for custom authenticate
  http.Client? httpClient;

  /// Run this function at the first function that will run first during the start up of the application.
  /// Normally inside the main function
  static Future<void> initialize(
      CollectionSchema<dynamic> userSchema, BaseAuthService authService) async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [userSchema],
      directory: dir.path,
    );
    BaseAuthService.authService = authService;
  }

  BaseAuthRouteService get routeService => throw UnimplementedError();

  /// Links user authentication with a provider using Riverpod.
  ///
  /// The function takes a [ref] parameter of type [WidgetRef], which is typically
  /// provided by Riverpod and represents the current scope of the widget.
  ///
  /// The function establishes a listener to a user stream by calling [userStream()].
  /// The [userStream] function is expected to return a [Stream] that emits updates
  /// whenever the user authentication state changes.
  ///
  /// When a new user is emitted from the stream ([newUser] is not null), the function
  /// calls [signIn(newUser)] on the [userNotifierProvider]'s notifier, which is responsible
  /// for handling the sign-in process. This typically triggers state updates and rebuilds
  /// of dependent widgets.
  ///
  /// When null is emitted from the stream, indicating that the user is not authenticated,
  /// the function calls [signOut()] on the [userNotifierProvider]'s notifier, triggering
  /// the sign-out process and subsequent state updates.
  ///
  /// This initialization is automatically call in [AuthScreenHandler] widget so
  /// only call this function if you don't use [AuthScreenHandler]
  ///
  /// !!! This method must be called in build method !!!
  ///
  /// Example usage:
  ///
  /// ```dart
  ///
  /// @override
  ///   Widget build(BuildContext context) {
  ///     authService.linkAuthWithProvider(ref);
  ///     ...
  /// ```
  void linkAuthWithProvider(WidgetRef ref) {
    userStream().listen((newUser) {
      print('User exist: ${newUser != null}');
      if (newUser != null) {
        print("container read package");
        ref.watch(userNotifierProvider.notifier).signIn(newUser);
      } else {
        ref.watch(userNotifierProvider.notifier).signOut();
      }
    });
  }

  /// FNV-1a 64bit hash algorithm optimized for Dart Strings
  static int fastHash(String string) {
    int hash = 0xcbf29ce4;
    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }

    return hash;
  }

  /// an getter to retrieve user isar from project
  /// just override this function with your class isar database.
  IsarCollection<T> get usersIsar;

  /// Returns the URL for the authorization endpoint.
  ///
  /// The authorization endpoint is used by the client application to initiate
  /// the OAuth2 authorization flow and obtain an authorization code.
  ///
  /// The [authorizationEndpoint] typically requires the client application to
  /// provide its client ID and redirect URI. The [authorizationEndpoint] may also
  /// require additional parameters, such as the scope of the authorization
  /// request and the response type.
  ///
  /// It's important to note that the [authorizationEndpoint] must be secured and
  /// protected against unauthorized access, as it contains sensitive information
  /// such as the user's credentials and authorization code. OAuth2 recommends
  /// using HTTPS to secure all communication with the [authorizationEndpoint].
  Uri get authorizationEndpoint => throw UnimplementedError(
      "you does not implement this getter yet,\n"
      "please do so by overwrite authorizationEndpoint getter from your auth service");

  /// Returns the URL for the token endpoint.
  ///
  /// The token endpoint is used by the client application to exchange an
  /// authorization code for an access token.
  ///
  /// The [tokenEndpoint] typically requires the client application to provide
  /// the authorization code, as well as its client ID and client secret for
  /// authentication purposes. The [tokenEndpoint] may also require additional
  /// parameters, such as the grant type and redirect URI.
  ///
  /// It's important to note that the [tokenEndpoint] must be secured and
  /// protected against unauthorized access, as it contains sensitive information
  /// such as access tokens and refresh tokens. OAuth2 recommends using HTTPS to
  /// secure all communication with the [tokenEndpoint].
  Uri get tokenEndpoint => throw UnimplementedError(
      "you does not implement this getter yet,\n"
      "please do so by overwrite tokenEndpoint getter from your auth service");

  /// Returns the redirect URL for the OAuth2 client application.
  ///
  /// The [redirectUrl] is a URL that the authorization server will redirect the
  /// user to after the user grants or denies access to the client application
  /// during the OAuth2 authorization flow. This URL must be registered with the
  /// authorization server when the client is registered, and must match the
  /// value provided by the client in the authorization request.
  ///
  /// The [redirectUrl] must be a valid URL that is under the control of the
  /// client application. It must be unique to the client application, and must
  /// not be shared with other applications or used for other purposes.
  ///
  /// It's important to use a secure and reliable [redirectUrl] to ensure the
  /// OAuth2 authorization flow works correctly and that the user is not directed
  /// to a malicious website or application. OAuth2 recommends using HTTPS for
  /// all redirect URLs to ensure the connection between the client and server is
  /// encrypted and secure.
  Uri get redirectUrl => throw UnimplementedError(
      "you does not implement this getter yet,\n"
      "please do so by overwrite redirectUrl getter from your auth service");

  /// Returns the unique identifier for the OAuth2 client application.
  ///
  /// The [identifier] is a string value that uniquely identifies the client
  /// application to the authorization server. This value is typically generated
  /// by the authorization server and is provided to the client application when
  /// the client is registered with the server.
  ///
  /// The [identifier] is used by the authorization server to verify the identity
  /// of the client application when the client makes requests to the server,
  /// such as during the OAuth2 authorization flow. The [identifier] may also be
  /// used by the client application to identify itself when making requests to
  /// protected resources on behalf of the user.
  ///
  /// It's important to keep the [identifier] secret and protect it against
  /// unauthorized access, as it can be used to impersonate the client application
  /// and gain access to the user's resources. OAuth2 recommends using a secure
  /// storage mechanism to store the [identifier], such as a password manager or
  /// keychain.
  String get identifier =>
      throw UnimplementedError("you does not implement this getter yet,\n"
          "please do so by overwrite identifier getter from your auth service");

  /// Returns the client secret for the OAuth2 client application.
  ///
  /// The [secret] is a string value that is used to authenticate the client
  /// application to the authorization server. This value is typically generated
  /// by the authorization server and is provided to the client application when
  /// the client is registered with the server.
  ///
  /// The [secret] is used by the client application to authenticate itself to the
  /// authorization server when making requests for access tokens or other OAuth2
  /// operations that require client authentication. The [secret] is also used by
  /// the authorization server to verify the identity of the client application
  /// when processing requests from the client.
  ///
  /// It's important to keep the [secret] confidential and protect it against
  /// unauthorized access, as it can be used to impersonate the client application
  /// and gain access to the user's resources. OAuth2 recommends using a secure
  /// storage mechanism to store the [secret], such as a password manager or
  /// keychain.
  String? get secret =>
      throw UnimplementedError("you does not implement this getter yet,\n"
          "please do so by overwrite secret getter from your auth service.\n "
          "if you OAuth2 doesn't use secret, override with null instead");

  /// A file in which the users credentials are stored persistently. If the server
  /// issues a refresh token allowing the client to refresh outdated credentials,
  /// these may be valid indefinitely, meaning the user never has to
  /// re-authenticate.
  Future<File> get credentialsFile async => getApplicationDocumentsDirectory()
      .then((value) => File("${value.path}/credentials.json"));

  /// an abstract function to generate an stream of current user
  /// return null of no current user
  Stream<T?> userStream() async* {
    yield await usersIsar.where().findFirst();
    await for (final event in usersIsar.watchLazy()) {
      T? user = await usersIsar.where().findFirst();
      yield user;
    }
  }

  /// Return the listenable version of current auth
  UserAuthState authListenable() => UserAuthState(userStream());

  /// A widget that register current user from the request param
  /// [user] a object that will be register as current user
  Future<void> addUserToCurrentAuth(T user) async {
    await isar.writeTxn(() async {
      await usersIsar.put(user);
    });
  }

  /// Make a request to the authorization endpoint that will produce the fully
  /// authenticated Client.
  ///
  ///  to use this method, make sure to override all the bellow getter:
  ///  [authorizationEndpoint], [identifier], and [secret]
  Future<void> signInWithResourceOwnerPasswordGrant({
    required String username,
    required String password,
  }) async {
    httpClient = await oauth2.resourceOwnerPasswordGrant(
        authorizationEndpoint, username, password,
        identifier: identifier, secret: secret);
  }

  /// Signs in the user using the authorization code grant flow.
  ///
  /// This method retrieves the OAuth2 credentials for the user by redirecting them
  /// to the authorization server's login page and obtaining an authorization code.
  /// The authorization code is then exchanged for an access token, which is used to
  /// authenticate API requests.
  ///
  /// If the user has previously authorized this application, their credentials will
  /// be retrieved from a saved file. Otherwise, the user will be prompted to log in
  /// and grant permission to this application.
  ///
  /// Throws an [AuthManagementException] if an error occurs during authentication
  /// management.
  Future<void> signInWithAuthorizationCodeGrant() async {
    final File directory = await credentialsFile;

    var exists = await directory.exists();

    // If the OAuth2 credentials have already been saved from a previous run, we
    // just want to reload them.
    if (exists) {
      var credentials =
          oauth2.Credentials.fromJson(await directory.readAsString());
      httpClient =
          oauth2.Client(credentials, identifier: identifier, secret: secret);
    }

    // If we don't have OAuth2 credentials yet, we need to get the resource owner
    // to authorize us. We're assuming here that we're a command-line application.
    var grant = oauth2.AuthorizationCodeGrant(
        identifier, authorizationEndpoint, tokenEndpoint,
        secret: secret);

    // A URL on the authorization server (authorizationEndpoint with some additional
    // query parameters). Scopes and state can optionally be passed into this method.
    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl);

    // Redirect the resource owner to the authorization URL. Once the resource
    // owner has authorized, they'll be redirected to `redirectUrl` with an
    // authorization code. The `redirect` should cause the browser to redirect to
    // another URL which should also have a listener.
    //
    // `redirect` and `listen` are not shown implemented here. See below for the
    // details.
    await _openAuthorizationServerLogin(authorizationUrl);
    var responseUrl = await _listenAuthorizationServerLogin(redirectUrl);

    if (responseUrl == null) return;

    // Once the user is redirected to `redirectUrl`, pass the query parameters to
    // the AuthorizationCodeGrant. It will validate them and extract the
    // authorization code to create a new Client.
    httpClient =
        await grant.handleAuthorizationResponse(responseUrl.queryParameters);
  }

  Future<void> _openAuthorizationServerLogin(Uri authUri) async {
    if (await canLaunchUrl(authUri)) {
      await launchUrl(authUri, mode: LaunchMode.externalApplication);
    } else {
      throw AuthManagementException('Could not launch $authUri',
          todoAction: "please handle this error");
    }
  }

  Future<Uri?> _listenAuthorizationServerLogin(Uri redirectUri) {
    // Attach a listener to the stream
    return uriLinkStream
        .firstWhere((uri) => uri.toString().startsWith(redirectUri.toString()));
  }

  /// A function to delete all user in the isar database for  [T] collection
  /// if you did override this function call the super method.
  @mustCallSuper
  Future<void> signOut() async {
    await isar.writeTxn(() => usersIsar.where().deleteAll());
  }
}
