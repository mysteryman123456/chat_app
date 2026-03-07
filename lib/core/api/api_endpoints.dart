class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://192.168.254.12:8080/api';
  // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);


  static const String login = '/auth/login';
  static const String register = '/auth/signup';
  static const String getAllUsers = '/auth/users';
  static const String updateProfile = '/user/profile';
  static const String updatePassword = '/user/settings/password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  
  // Conversations
  static const String getConversations = '/conversation';
  static const String createConversation = '/conversation';

  static const String getMessages = '/message';

  static const String searchUser = '/user';

  static const String uploadImage = '/upload/file';
}