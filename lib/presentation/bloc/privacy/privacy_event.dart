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
  final PrivacySettings settings;
  const PrivacyUpdateSettings(this.settings);

  @override
  List<Object?> get props => [settings];
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
