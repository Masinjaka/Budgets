import 'package:supabase_flutter/supabase_flutter.dart';

String friendlyErrorMessage(Object error) {
  if (error is AuthException) {
    return _friendlyAuthMessage(error.message);
  }

  if (error is PostgrestException) {
    return _friendlyPostgrestMessage(error.message);
  }

  if (error is StorageException) {
    return _friendlyStorageMessage(error.message);
  }

  if (error is StateError) {
    return _friendlyGenericMessage(error.message);
  }

  if (error is Exception) {
    return _friendlyGenericMessage(error.toString());
  }

  return "Une erreur est survenue. Veuillez réessayer.";
}

String _friendlyAuthMessage(String message) {
  final normalized = message.toLowerCase();

  if (normalized.contains('invalid login credentials') ||
      normalized.contains('invalid login') ||
      normalized.contains('invalid_credentials')) {
    return "Email ou mot de passe incorrect.";
  }

  if (normalized.contains('email not confirmed') ||
      normalized.contains('email_not_confirmed')) {
    return "Veuillez confirmer votre email avant de vous connecter.";
  }

  if (normalized.contains('user not found')) {
    return "Aucun compte trouvé pour cet email.";
  }

  if (normalized.contains('already registered') ||
      normalized.contains('duplicate key value') ||
      normalized.contains('user already exists') ||
      normalized.contains('email already')) {
    return "Cet email est déjà utilisé.";
  }

  if (normalized.contains('missing email') ||
      normalized.contains('missing password') ||
      normalized.contains('email is required') ||
      normalized.contains('password is required')) {
    return "Veuillez renseigner l'email et le mot de passe.";
  }

  if (normalized.contains('invalid email')) {
    return "Adresse email invalide.";
  }

  if (normalized.contains('password should be at least') ||
      normalized.contains('weak_password') ||
      normalized.contains('password is too')) {
    return "Le mot de passe est trop faible.";
  }

  return _friendlyGenericMessage(message);
}

String _friendlyPostgrestMessage(String message) {
  final normalized = message.toLowerCase();

  if (normalized.contains('violates foreign key') ||
      normalized.contains('violates not-null') ||
      normalized.contains('null value')) {
    return "Veuillez vérifier les champs requis.";
  }

  if (normalized.contains('duplicate key value')) {
    return "Une entrée identique existe déjà.";
  }

  return "Une erreur serveur est survenue. Veuillez réessayer.";
}

String _friendlyStorageMessage(String message) {
  final normalized = message.toLowerCase();

  if (normalized.contains('permission') ||
      normalized.contains('not authorized')) {
    return "Accès refusé. Veuillez réessayer.";
  }

  if (normalized.contains('not found')) {
    return "Fichier introuvable.";
  }

  return "Impossible de traiter le fichier. Veuillez réessayer.";
}

String _friendlyGenericMessage(String message) {
  final normalized = message.toLowerCase();

  if (normalized.contains('user not authenticated') ||
      normalized.contains('no authenticated user') ||
      normalized.contains('no authenticated session')) {
    return "Veuillez vous connecter pour continuer.";
  }

  return "Une erreur est survenue. Veuillez réessayer.";
}
