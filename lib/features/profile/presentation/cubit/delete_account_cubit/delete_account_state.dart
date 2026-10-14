import 'package:equatable/equatable.dart';

abstract class DeleteAccountState extends Equatable {
  const DeleteAccountState();
  @override
  List<Object?> get props => [];
}

class DeleteAccountInitial extends DeleteAccountState {
  const DeleteAccountInitial();
}

class DeleteAccountInProgress extends DeleteAccountState {
  const DeleteAccountInProgress();
}

class DeleteAccountFailure extends DeleteAccountState {
  final String message;
  const DeleteAccountFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class DeleteAccountSuccess extends DeleteAccountState {
  const DeleteAccountSuccess();
}
