# Real-Life Experience Design - Implementation Guide

## 📋 Overview

This guide covers the complete implementation of role-based, context-aware UX in AfriGO. The system ensures **suppliers see simplified action-first interfaces**, **buyers see rich analytics**, **logistics sees real-time tracking**, and **admins see dense data controls**.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────┐
│         Application Shell (app_router.dart)     │
├─────────────────────────────────────────────────┤
│                                                 │
│  AdaptiveNavigationShell                        │
│  ├─ userRoleProvider (determines role)          │
│  ├─ roleNavigationProvider (nav items)          │
│  ├─ rolePreferencesProvider (UI tweaks)         │
│  └─ _buildBottomNavigation() (renders nav)      │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ Child: AdaptiveHomeScreen or other      │   │
│  │ - Switches on role                      │   │
│  │ - Renders role-specific template        │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘

Files Involved:
1. lib/config/role_navigation_config.dart .............. RBAC config
2. lib/presentation/providers/role_provider.dart ....... Role state
3. lib/presentation/screens/shell/adaptive_navigation_shell.dart .. Nav shell
4. lib/presentation/screens/home/adaptive_home_screen.dart ........ Home template
5. lib/presentation/widgets/adaptive/adaptive_button.dart ......... Role-sized buttons
```

---

## 📁 New Files Created

### 1. **lib/config/role_navigation_config.dart** (180 lines)
Defines RBAC configuration and role-specific settings.

**Key Classes**:
- `enum UserRole` - supplier, buyer, logistics, admin
- `class NavigationItem` - Label, icon, route
- `class RoleNavigationConfig` - Static methods for role-specific config

**Key Methods**:
- `getNavItems(role)` - Get navigation for role
- `getButtonHeight(role)` - Button sizing per role
- `getRoleEmphasisColor(role)` - Color scheme per role
- `prefersCardLayout(role)` - True for suppliers/logistics, false for buyer/admin

**Import in your files**:
```dart
import '../../config/role_navigation_config.dart';
```

---

### 2. **lib/presentation/providers/role_provider.dart** (170 lines)
Provides reactive access to user role and role-specific preferences.

**Key Providers**:
- `userRoleProvider` - Async, watches auth and determines role
- `userRoleSyncProvider` - Sync version (nullable)
- `rolePreferencesProvider` - Returns `RolePreferences` object
- `roleNavigationProvider` - Navigation items for current role
- `roleButtonHeightProvider` - Button height for current role
- `roleEmphasisColorProvider` - Emphasis color for current role

**Usage**:
```dart
final role = ref.watch(userRoleProvider);  // Async
final prefs = ref.watch(rolePreferencesProvider);  // Sync
final navItems = ref.watch(roleNavigationProvider);  // Sync
```

---

### 3. **lib/presentation/screens/shell/adaptive_navigation_shell.dart** (200 lines)
Main shell widget that renders role-specific navigation.

**Key Widget**: `AdaptiveNavigationShell`
- Takes `child` (the screen content)
- Watches `userRoleProvider`
- Renders appropriate `BottomNavigationBar` based on role

**Navigation Variants**:
- **Supplier**: 4 tabs (Home, Sales, Payments, Profile)
- **Buyer**: 5 tabs with overflow menu
- **Logistics**: 5 tabs (Home, Map, Jobs, Alerts, Profile)
- **Admin**: 5 tabs with overflow menu

**Usage** (in your GoRouter):
```dart
ShellRoute(
  builder: (context, state, child) => AdaptiveNavigationShell(
    child: child,
  ),
  routes: [
    GoRoute(path: '/home', builder: ...),
    GoRoute(path: '/marketplace', builder: ...),
    // ...
  ],
)
```

---

### 4. **lib/presentation/screens/home/adaptive_home_screen.dart** (450 lines)
Complete home screen that adapts to each role.

**Classes**:
- `AdaptiveHomeScreen` - Main widget (switches on role)
- `_SupplierHomeTemplate` - Action buttons, status cards
- `_BuyerHomeTemplate` - KPI cards, activity feed
- `_LogisticsHomeTemplate` - Next job highlighted, upcoming jobs
- `_AdminHomeTemplate` - Critical alerts, KPI grid

**Feature Highlights**:
- Giant buttons for suppliers (action-first)
- Simplified card layouts (no dense tables)
- Map-ready template for logistics
- Dashboard-style KPI cards for buyer/admin

---

### 5. **lib/presentation/widgets/adaptive/adaptive_button.dart** (220 lines)
Adaptive button components that size based on role.

**Classes**:
- `AdaptiveButton` - Primary button (64px supplier, 48px others)
- `AdaptiveOutlinedButton` - Outlined variant
- `AdaptiveTextButton` - Text-only variant
- `AdaptiveIconButton` - Circular icon buttons

**Usage**:
```dart
AdaptiveButton(
  label: 'List Product',
  onPressed: () { context.push('/product/create'); },
)

// Supplier sees 64px button, buyer sees 48px button
```

---

## 🚀 Implementation Steps

### Step 1: Update app_router.dart
Add `AdaptiveNavigationShell` as wrapper for protected routes:

```dart
import 'package:go_router/go_router.dart';
import 'presentation/screens/shell/adaptive_navigation_shell.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Unprotected routes
      GoRoute(path: '/login', builder: ...),
      GoRoute(path: '/register', builder: ...),
      
      // Protected routes with adaptive nav
      ShellRoute(
        builder: (context, state, child) => AdaptiveNavigationShell(
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const AdaptiveHomeScreen(),
          ),
          GoRoute(
            path: '/supplier/sales',
            builder: (context, state) => const SupplierSalesScreen(),
          ),
          // ... more routes
        ],
      ),
    ],
  );
});
```

### Step 2: Update auth_provider.dart
Ensure you're tracking user role:

```dart
// Your existing auth provider - add role tracking
class AuthUser {
  final String id;
  final String email;
  final UserRole role;  // Add this
  
  AuthUser({
    required this.id,
    required this.email,
    required this.role,
  });
}
```

### Step 3: Use Adaptive Components
Replace standard buttons with adaptive versions:

```dart
// Before
ElevatedButton(
  onPressed: () { ... },
  child: const Text('Save'),
),

// After
import '../../widgets/adaptive/adaptive_button.dart';

AdaptiveButton(
  label: 'Save',
  onPressed: () { ... },
)
```

### Step 4: Build Role-Specific Screens
Create distinct screens for each role:

```
lib/presentation/screens/
├── supplier/
│   ├── supplier_home_screen.dart
│   ├── supplier_sales_screen.dart
│   └── supplier_payments_screen.dart
├── buyer/
│   ├── buyer_home_screen.dart
│   ├── buyer_marketplace_screen.dart
│   └── buyer_analytics_screen.dart
├── logistics/
│   ├── logistics_home_screen.dart
│   ├── logistics_map_screen.dart
│   └── logistics_jobs_screen.dart
└── admin/
    ├── admin_dashboard_screen.dart
    ├── admin_users_screen.dart
    └── admin_compliance_screen.dart
```

---

## 💡 Component Patterns

### Pattern 1: Role-Aware Button
```dart
// Suppliers get larger buttons automatically
AdaptiveButton(
  label: 'Action',
  onPressed: () { ... },
)
// Result: 64px for supplier, 48px for buyer
```

### Pattern 2: Role-Aware Layout
```dart
// Suppliers see cards, admins see tables
final prefs = ref.watch(rolePreferencesProvider);

if (prefs.prefersCards) {
  return ListView(...); // Card list
} else {
  return DataTable(...); // Dense table
}
```

### Pattern 3: Role-Aware Data Loading
```dart
// Suppliers see 5 items, admins see 25 items
final itemsPerPage = ref.watch(roleTableRowsProvider);
final items = data.take(itemsPerPage);
```

---

## 🎨 Customization Guide

### Adjust Button Sizes
In `role_navigation_config.dart`:
```dart
static double getButtonHeight(UserRole role) {
  return switch(role) {
    UserRole.supplier => 72.0,  // Make even larger
    UserRole.logistics => 56.0,
    _ => 48.0,
  };
}
```

### Add New Role
1. Add to `enum UserRole` in `role_navigation_config.dart`
2. Add navigation items to `RoleNavigationConfig`
3. Add case to `AdaptiveNavigationShell._buildBottomNavigation()`
4. Add template class to `AdaptiveHomeScreen`

### Customize Colors
In `role_navigation_config.dart`:
```dart
static Color getRoleEmphasisColor(UserRole role) {
  return switch(role) {
    UserRole.supplier => Color(0xFF00AA00),  // Custom green
    // ...
  };
}
```

---

## 📊 Real-World Usage Examples

### Supplier - Selling Products Fast
```
1. User opens app
2. Sees giant "List Product" button
3. Taps button → 3-step form (no 10+ steps)
4. Product listed, gets confirmation
5. Sees "Active Listings" card with count
```

### Buyer - Comparing Suppliers
```
1. User opens app
2. Sees "Marketplace" tab (not on supplier nav)
3. Taps search, sees comparison table
4. Clicks "Request Quote from All"
5. Sees analytics of supplier responses
```

### Logistics - Tracking Shipments
```
1. User opens app
2. Sees "Next Pickup" large highlighted card
3. Taps "Map" tab (main navigation)
4. Shows GPS tracking with ETA
5. Taps "Arrived" button (56px, glove-friendly)
```

### Admin - Monitoring System
```
1. User opens app
2. Sees critical alerts in red
3. Views KPI dashboard (6 metrics)
4. Taps "Users" → Dense table with 25 rows
5. Bulk-exports data, reviews compliance
```

---

## 🧪 Testing Guide

### Test Role Navigation
```dart
// In your test
testWidgets('Supplier sees 4 nav items', (WidgetTester tester) async {
  // Mock user as supplier
  when(userRoleProvider).thenReturn(UserRole.supplier);
  
  // Build AdaptiveNavigationShell
  await tester.pumpWidget(...);
  
  // Verify 4 bottom nav items
  expect(find.byType(BottomNavigationBarItem), findsWidgets(count: 4));
});
```

### Test Button Sizing
```dart
testWidgets('Supplier button is 64px', (WidgetTester tester) async {
  when(userRoleProvider).thenReturn(UserRole.supplier);
  await tester.pumpWidget(...);
  
  final button = find.byType(AdaptiveButton);
  expect(tester.getSize(button).height, 64);
});
```

---

## 🔄 Migration Path

### Phase 1: Foundation (Week 1)
- ✅ Create config files (role_navigation_config.dart)
- ✅ Create providers (role_provider.dart)
- ✅ Update app_router.dart with AdaptiveNavigationShell

### Phase 2: Components (Week 2)
- ✅ Create adaptive button component
- ✅ Create adaptive home screen template
- ✅ Replace existing buttons with adaptive versions

### Phase 3: Screens (Week 3)
- Create role-specific screens (supplier, buyer, logistics, admin)
- Update each screen to use adaptive components
- Test role-specific flows

### Phase 4: Polish (Week 4)
- Gather user feedback
- Iterate on button sizes, colors, layouts
- Performance testing

---

## 📈 Success Metrics

### Supplier Success
- ✅ Time to list: < 2 minutes (vs. 5+ before)
- ✅ Mobile usage: > 80%
- ✅ Listing completion: > 85%

### Buyer Success
- ✅ Time to purchase: < 5 minutes
- ✅ Comparison usage: > 70%
- ✅ Average order value: +15%

### Logistics Success
- ✅ App adoption: > 95%
- ✅ POD completion: < 5 minutes
- ✅ On-time delivery: > 95%

### Admin Success
- ✅ Issue resolution time: < 1 hour
- ✅ Data accuracy: 100%
- ✅ Report generation: < 1 second

---

## 🚨 Common Pitfalls to Avoid

### ❌ Don't: Use Same Interface for All Roles
This forces suppliers into admin-like dense interfaces where they get lost.

### ✅ Do: Adapt Every Element
Buttons, tables, navigation, data density - all should respect role.

### ❌ Don't: Make Suppliers Click Through Multiple Screens
Simplicity is the key differentiator.

### ✅ Do: Provide Giant Buttons and Pre-Filled Forms
Reduce friction, get them selling quickly.

### ❌ Don't: Hide Advanced Features from Buyers
They need to compare, analyze, and make decisions.

### ✅ Do: Show Dashboards and Charts
Provide data-rich interfaces for informed purchasing.

---

## 🤝 Integration Checklist

- [ ] Created `role_navigation_config.dart`
- [ ] Created `role_provider.dart`
- [ ] Created `adaptive_navigation_shell.dart`
- [ ] Created `adaptive_home_screen.dart`
- [ ] Created `adaptive_button.dart`
- [ ] Updated `app_router.dart` with ShellRoute
- [ ] Updated auth provider to track role
- [ ] Replaced 10+ buttons with adaptive version
- [ ] Tested supplier flow (end-to-end)
- [ ] Tested buyer flow (end-to-end)
- [ ] Tested logistics flow (end-to-end)
- [ ] Tested admin flow (end-to-end)
- [ ] Gathered user feedback
- [ ] Iterated on UX

---

**This architecture ensures AfriGO provides a world-class experience for each user type, not a compromise that works for no one.**
