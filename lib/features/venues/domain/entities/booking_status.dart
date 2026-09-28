enum BookingStatus {
  pending('pending', 'Pending Approval'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected'),
  cancelled('cancelled', 'Cancelled');

  final String value;
  final String displayName;
  const BookingStatus(this.value, this.displayName);

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => BookingStatus.pending,
    );
  }
}
