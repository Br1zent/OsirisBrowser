part of 'privacy_bloc.dart';

enum PrivacyStatus { initial, loading, loaded, nuking, nuked, error }

class PrivacyState extends Equatable {
  final PrivacyStatus status;
  final PrivacySettings settings;
  final String? message;

  const PrivacyState({
    this.status = PrivacyStatus.initial,
    this.settings = const PrivacySettings(),
    this.message,
  });

  PrivacyState copyWith({
    PrivacyStatus? status,
    PrivacySettings? settings,
    String? message,
  }) {
    return PrivacyState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, settings, message];
}
