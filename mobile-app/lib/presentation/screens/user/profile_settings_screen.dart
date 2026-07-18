import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/colors.dart';
import '../../providers/auth_provider.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  TextEditingController _controller(String key) =>
      _controllers.putIfAbsent(key, TextEditingController.new);

  @override
  void initState() {
    super.initState();
    unawaited(_loadProfile());
  }

  Future<void> _loadProfile() async {
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final reference =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      final cached = await reference.get(const GetOptions(source: Source.cache));
      _apply(cached.data());
    } catch (_) {}
    try {
      final server = await reference
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 4));
      _apply(server.data());
    } catch (_) {
      // Cached identity remains usable; no blocking error banner is needed.
    }
  }

  void _apply(Map<String, dynamic>? profile) {
    if (!mounted || profile == null) return;
    for (final entry in profile.entries) {
      if (_controllers.containsKey(entry.key) && entry.value != null) {
        _controllers[entry.key]!.text = entry.value.toString();
      }
    }
    setState(() {});
  }

  Future<void> _save(String role) async {
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    final allowed = <String>{
      'phone',
      'organization',
      'countryCode',
      ..._roleFields(role).map((field) => field.key),
    };
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        for (final key in allowed) key: _controller(key).text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile was not saved. Check connectivity and retry.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final role = user?.roles.firstOrNull?.toLowerCase() ?? 'buyer';
    final identity = _identity(role);
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 900 ? (width - 820) / 2 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('${identity.title} profile'),
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: .94, end: 1),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: _IdentityCard(
              identity: identity,
              name: user?.fullName.isNotEmpty == true
                  ? user!.fullName
                  : 'AfriGO user',
              email: user?.email ?? '',
              kycStatus: user?.kycStatus ?? 'pending',
            ),
          ),
          const SizedBox(height: 18),
          Text(identity.description,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          _sectionTitle(context, 'Contact and organization'),
          _responsiveFields(const [
            _ProfileField('phone', 'Phone number', Icons.phone_outlined),
            _ProfileField(
                'organization', 'Organization', Icons.business_outlined),
            _ProfileField(
                'countryCode', 'Operating country', Icons.public_outlined),
          ]),
          const SizedBox(height: 18),
          _sectionTitle(context, identity.sectionTitle),
          _responsiveFields(_roleFields(role)),
          const SizedBox(height: 18),
          _VerificationCard(
            role: identity.title,
            kycStatus: user?.kycStatus ?? 'pending',
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saving ? null : () => _save(role),
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Saving…' : 'Save ${identity.title} profile'),
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Account settings'),
            style:
                OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
      );

  Widget _responsiveFields(List<_ProfileField> fields) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 680 ? 2 : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: fields.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 78,
        ),
        itemBuilder: (context, index) {
          final field = fields[index];
          return TextField(
            controller: _controller(field.key),
            keyboardType: field.numeric
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            decoration: InputDecoration(
              labelText: field.label,
              prefixIcon: Icon(field.icon),
              border: const OutlineInputBorder(),
            ),
          );
        },
      );
    });
  }

  List<_ProfileField> _roleFields(String role) => switch (role) {
        'supplier' => const [
            _ProfileField(
                'tradingName', 'Farm or trading name', Icons.storefront),
            _ProfileField('commodities', 'Commodities supplied',
                Icons.agriculture_outlined),
            _ProfileField('productionCapacity', 'Monthly capacity (kg)',
                Icons.scale_outlined,
                numeric: true),
            _ProfileField('pickupLocation', 'Primary pickup location',
                Icons.location_on_outlined),
          ],
        'exporter' => const [
            _ProfileField('exportLicenseNumber', 'Export licence number',
                Icons.badge_outlined),
            _ProfileField('customsRegistrationNumber',
                'Customs registration number', Icons.assignment_outlined),
            _ProfileField('warehouseLocations', 'Warehouse locations',
                Icons.warehouse_outlined),
            _ProfileField('destinationMarkets', 'Destination markets',
                Icons.public_outlined),
          ],
        _ => const [
            _ProfileField('procurementCategories', 'Procurement categories',
                Icons.category_outlined),
            _ProfileField('deliveryMarkets', 'Delivery markets',
                Icons.location_city_outlined),
            _ProfileField('annualProcurementVolume',
                'Annual procurement volume', Icons.analytics_outlined,
                numeric: true),
            _ProfileField('preferredCurrency', 'Preferred currency',
                Icons.currency_exchange_outlined),
          ],
      };

  _RoleIdentity _identity(String role) => switch (role) {
        'supplier' => const _RoleIdentity(
            title: 'Supplier',
            sectionTitle: 'Production and fulfilment',
            description:
                'These details help buyers and exporters understand your real supply capacity and pickup operation.',
            icon: Icons.agriculture_outlined,
            color: AppColors.primaryGreen,
          ),
        'exporter' => const _RoleIdentity(
            title: 'Exporter',
            sectionTitle: 'Export compliance and logistics',
            description:
                'Export credentials and operational locations support quality, customs, warehousing, and shipment coordination.',
            icon: Icons.public,
            color: Colors.orange,
          ),
        _ => const _RoleIdentity(
            title: 'Buyer',
            sectionTitle: 'Procurement preferences',
            description:
                'Procurement details personalize sourcing, supplier discovery, delivery, and purchasing analytics.',
            icon: Icons.shopping_bag_outlined,
            color: AppColors.accentBlue,
          ),
      };
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.identity,
    required this.name,
    required this.email,
    required this.kycStatus,
  });
  final _RoleIdentity identity;
  final String name;
  final String email;
  final String kycStatus;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: identity.color.withValues(alpha: .12),
              child: Icon(identity.icon, color: identity.color, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  Text(email),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, children: [
                    Chip(label: Text(identity.title.toUpperCase())),
                    Chip(label: Text('KYC ${kycStatus.toUpperCase()}')),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      );
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.role, required this.kycStatus});
  final String role;
  final String kycStatus;

  @override
  Widget build(BuildContext context) {
    final verified = kycStatus.toLowerCase() == 'verified';
    return Card(
      child: ListTile(
        leading: Icon(
          verified ? Icons.verified_user : Icons.gpp_maybe_outlined,
          color: verified ? Colors.green : Colors.orange,
        ),
        title: Text(verified ? '$role identity verified' : 'Verification pending'),
        subtitle: Text(
          verified
              ? 'Your account can access KYC-gated production operations.'
              : 'KYC status cannot be self-edited. Payments, payouts and regulated export actions remain unavailable until server verification.',
        ),
      ),
    );
  }
}

class _ProfileField {
  const _ProfileField(this.key, this.label, this.icon, {this.numeric = false});
  final String key;
  final String label;
  final IconData icon;
  final bool numeric;
}

class _RoleIdentity {
  const _RoleIdentity({
    required this.title,
    required this.sectionTitle,
    required this.description,
    required this.icon,
    required this.color,
  });
  final String title;
  final String sectionTitle;
  final String description;
  final IconData icon;
  final Color color;
}
