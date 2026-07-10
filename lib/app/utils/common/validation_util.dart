import 'package:email_validator/email_validator.dart';

class ValidationUtil {
  bool isValidEmail(String email) {
    return EmailValidator.validate(email);
  }
}

ValidationUtil validationUtil = new ValidationUtil();
