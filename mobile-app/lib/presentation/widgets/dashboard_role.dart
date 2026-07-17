enum DashboardRole {
  buyer,
  supplier,
  exporter,
}

DashboardRole dashboardRoleFromRaw(String? rawRole) {
  final normalized = (rawRole ?? '').trim().toLowerCase();
  switch (normalized) {
    case 'supplier':
    case 'seller':
      return DashboardRole.supplier;
    case 'exporter':
    case 'export':
      return DashboardRole.exporter;
    default:
      return DashboardRole.buyer;
  }
}
