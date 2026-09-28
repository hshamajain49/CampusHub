enum UserRole {
  student('student'),
  departmentStaff('department_staff'),
  venueCoordinator('venue_coordinator'),
  admin('admin');

  final String value;
  const UserRole(this.value);
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }
}
