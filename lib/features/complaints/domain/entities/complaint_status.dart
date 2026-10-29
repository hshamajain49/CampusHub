enum ComplaintStatus {
  pendingReview('pending_review', 'Pending Review'),
  inProgress('in_progress', 'In Progress'),
  // Staff finished the work; the student who filed it approves or rejects.
  awaitingConfirmation('awaiting_confirmation', 'Awaiting Approval'),
  resolved('resolved', 'Resolved'),
  unassigned('unassigned', 'Unassigned'); // safety fallback, rarely used

  final String value;
  final String displayName;
  const ComplaintStatus(this.value, this.displayName);

  static ComplaintStatus fromString(String value) {
    return ComplaintStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ComplaintStatus.unassigned,
    );
  }
}
