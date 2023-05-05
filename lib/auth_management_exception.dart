/// An exception that is thrown when an error occurs during authentication
/// management.
///
/// The `AuthManagementException` class is used to indicate that an error has
/// occurred during authentication management, such as when a user's credentials
/// are invalid, when an authentication token is expired or invalid, or when
/// there is a problem communicating with the authentication server.
class AuthManagementException implements Exception {
  /// Creates a new instance of the `AuthManagementException` class with the
  /// specified error [message].
  ///
  /// An optional [todoAction] parameter can be provided to suggest an action
  /// that can be taken to resolve the error.
  AuthManagementException(this.message, {this.todoAction});

  /// The error message associated with the exception.
  final String message;

  /// An optional action that can be taken to resolve the error.
  final String? todoAction;
}
