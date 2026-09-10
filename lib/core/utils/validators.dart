abstract final class Validators {
  static String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  static String? name(String? value) {
    final required = requiredText(value, 'Name');
    if (required != null) return required;
    if (value!.trim().length < 2) return 'Name must be at least 2 characters.';
    return null;
  }

  static String? email(String? value) {
    final required = requiredText(value, 'Email');
    if (required != null) return required;
    final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim());
    return valid ? null : 'Enter a valid email address.';
  }

  static String? password(String? value) {
    final required = requiredText(value, 'Password');
    if (required != null) return required;
    if (value!.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }
}
