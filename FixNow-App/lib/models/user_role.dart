enum UserRole { customer, provider, admin }

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.customer => 'Customer',
        UserRole.provider => 'Service Provider',
        UserRole.admin => 'Admin',
      };

  String get description => switch (this) {
        UserRole.customer => 'Book trusted professionals for your home',
        UserRole.provider => 'Offer your services and manage bookings',
        UserRole.admin => 'Manage users, providers and platform operations',
      };

  String get storageValue => name;

  static UserRole fromStorage(String? value) {
    return UserRole.values.firstWhere(
      (r) => r.storageValue == value,
      orElse: () => UserRole.customer,
    );
  }
}
