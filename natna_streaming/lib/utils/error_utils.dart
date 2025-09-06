class ErrorUtils {
  static String parseAuthError(String error) {
    if (error.contains("User Already Registered") &&
        error.startsWith("Exception: ")) {
      return "User Already Registered";
    } else if (error.contains("Invalid email or password") &&
        error.startsWith("Exception: ")) {
      return "Invalid email or password";
    } else if (error.contains("User not found")) {
      return "Invalid email or password";
    } else if (error.contains("Network is unreachable") ||
        error.contains("SocketException")) {
      return "Network error. Please check your connection";
    } else if (error.contains("Connection refused") ||
        error.contains("Failed host lookup")) {
      return "Cannot connect to server";
    } else if (error.contains("Timeout")) {
      return ("Connection timeout. Please try again");
    } else {
      return "Internal Server Error";
    }
  }

  static String cleanExceptionMessage(String error) {
    if (error.startsWith("Exception: ")) {
      return error.substring(11);
    }
    return error;
  }
}
