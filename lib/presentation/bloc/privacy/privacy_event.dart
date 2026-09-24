part of 'privacy_bloc.dart';

abstract class PrivacyEvent extends Equatable {
  const PrivacyEvent();

  @override
  List<Object?> get props => [];
}

class PrivacyLoadSettings extends PrivacyEvent {
  const PrivacyLoadSettings();
}

class PrivacyUpdateSettings extends PrivacyEvent {
  final String key;
  final Object value;
  const PrivacyUpdateSettings(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

class PrivacyNukeAllData extends PrivacyEvent {
  final bool clearBookmarks;
  const PrivacyNukeAllData({this.clearBookmarks = false});

  @override
  List<Object?> get props => [clearBookmarks];
}

class PrivacyClearHistory extends PrivacyEvent {
  const PrivacyClearHistory();
}

class PrivacyResetToDefaults extends PrivacyEvent {
  const PrivacyResetToDefaults();
}
