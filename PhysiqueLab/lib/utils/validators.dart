/// Form validation helpers used across auth and profile screens.
class Validators {
  Validators._();

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 50) {
      return 'Name must be 2–50 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmed)) {
      return 'Letters and spaces only';
    }
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Enter a valid whole number';
    }
    if (age < 13 || age > 80) {
      return 'Age must be between 13 and 80';
    }
    return null;
  }

  static String? heightCm(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Height is required';
    }
    final height = double.tryParse(value.trim());
    if (height == null) {
      return 'Enter a valid height';
    }
    if (height < 100 || height > 250) {
      return 'Height must be 100–250 cm';
    }
    return null;
  }

  static String? weightKg(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value.trim());
    if (weight == null) {
      return 'Enter a valid weight';
    }
    if (weight < 30 || weight > 300) {
      return 'Weight must be 30–300 kg';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include at least one number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
