class PasswordValidation {
  PasswordValidation(String password)
      : hasMinimumLength = password.length >= 8,
        hasUppercase = RegExp(r'[A-Z]').hasMatch(password),
        hasLowercase = RegExp(r'[a-z]').hasMatch(password),
        hasNumber = RegExp(r'[0-9]').hasMatch(password),
        hasSpecialCharacter =
            RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);

  final bool hasMinimumLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecialCharacter;

  bool get isSatisfied =>
      hasMinimumLength &&
      hasUppercase &&
      hasLowercase &&
      hasNumber &&
      hasSpecialCharacter;
}
