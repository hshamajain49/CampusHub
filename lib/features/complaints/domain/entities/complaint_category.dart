enum ComplaintCategory {
  electrical('electrical', 'Electrical'),
  plumbing('plumbing', 'Plumbing'),
  itNetwork('it_network', 'IT/Network'),
  furniture('furniture', 'Furniture'),
  cleanliness('cleanliness', 'Cleanliness'),
  civilInfrastructure('civil_infrastructure', 'Civil/Infrastructure'),
  other('other', 'Other');

  final String value; // stored in Firestore
  final String displayName; // shown in UI
  const ComplaintCategory(this.value, this.displayName);

  static ComplaintCategory fromString(String value) {
    return ComplaintCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => ComplaintCategory.other,
    );
  }

  String get assignedDepartment {
    switch (this) {
      case ComplaintCategory.electrical:
        return 'Electrical Department';
      case ComplaintCategory.plumbing:
        return 'Plumbing Department';
      case ComplaintCategory.itNetwork:
        return 'IT Department';
      case ComplaintCategory.furniture:
        return 'Furniture/Carpentry Department';
      case ComplaintCategory.cleanliness:
        return 'Housekeeping Department';
      case ComplaintCategory.civilInfrastructure:
        return 'Civil/Maintenance Department';
      case ComplaintCategory.other:
        return 'General Administration';
    }
  }
}
