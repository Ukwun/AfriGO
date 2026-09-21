import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';

/// The second registration step establishes a real trading identity.  It is
/// intentionally stored on the authenticated user's Firestore document: no
/// sample business is created and no other user can edit this profile.
class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _business = TextEditingController();
  String _country = 'Nigeria';
  String _type = 'Producer / Exporter';
  String _category = 'Agriculture & food';
  bool _sells = true;
  bool _buys = false;
  bool _saving = false;

  static const _countries = [
    'Nigeria',
    'Ghana',
    'Côte d’Ivoire',
    'Senegal',
    'Benin',
    'Togo'
  ];
  static const _types = [
    'Producer / Exporter',
    'Importer / Buyer',
    'Manufacturer',
    'Cooperative / Aggregator',
    'Trade-service provider'
  ];
  static const _categories = [
    'Agriculture & food',
    'Manufacturing',
    'Textiles & apparel',
    'Minerals & metals',
    'Consumer goods',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _business.text = user?.displayName?.trim() ?? '';
  }

  @override
  void dispose() {
    _business.dispose();
    super.dispose();
  }

  String _homeFor(Map<String, dynamic> profile) {
    final role = (profile['role'] ?? 'buyer').toString();
    return switch (role) {
      'supplier' => '/supplier/home',
      'exporter' => '/exporter/home',
      _ => '/buyer/home',
    };
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_sells && !_buys) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Select at least one trading activity.')));
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }
    setState(() => _saving = true);
    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final existing = await ref.get();
      final capabilities = <String>[if (_sells) 'seller', if (_buys) 'buyer'];
      await ref.set({
        'organization': _business.text.trim(),
        'businessProfile': {
          'country': _country,
          'businessType': _type,
          'category': _category,
          'tradingCapabilities': capabilities,
          'completedAt': FieldValue.serverTimestamp(),
        },
        'profileCompletion': 75,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) context.go(_homeFor(existing.data() ?? const {}));
    } on FirebaseException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Your profile could not be saved. Check your connection and try again.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: IconButton(
                onPressed: () => context.pop(),
                icon:
                    const Icon(Icons.arrow_back, color: AfrigoColors.primary))),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    const _Brand(),
                    const SizedBox(height: 28),
                    const _Progress(),
                    const SizedBox(height: 36),
                    Text('Business profile',
                        style: AfrigoTypography.soraHeading2
                            .copyWith(color: AfrigoColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(
                        'Tell us about your business. This information makes your trading identity clear to the right partners.',
                        style: AfrigoTypography.interBody1
                            .copyWith(color: AfrigoColors.textSecondary)),
                    const SizedBox(height: 28),
                    _field(
                        'Business name',
                        TextFormField(
                            controller: _business,
                            textCapitalization: TextCapitalization.words,
                            decoration: _decoration(
                                'Your registered or trading name',
                                Icons.business_outlined),
                            validator: (value) =>
                                value == null || value.trim().length < 2
                                    ? 'Enter your business name'
                                    : null)),
                    _field(
                        'Country',
                        _menu(_country, _countries, Icons.location_on_outlined,
                            (value) => setState(() => _country = value!))),
                    _field(
                        'Business type',
                        _menu(_type, _types, Icons.business_center_outlined,
                            (value) => setState(() => _type = value!))),
                    _field(
                        'Category',
                        _menu(_category, _categories, Icons.eco_outlined,
                            (value) => setState(() => _category = value!))),
                    const SizedBox(height: 4),
                    Text('What do you do on AfriGoOS?',
                        style: AfrigoTypography.interBody2Semi
                            .copyWith(color: AfrigoColors.textPrimary)),
                    const SizedBox(height: 12),
                    LayoutBuilder(builder: (context, box) {
                      final stacked = box.maxWidth < 430;
                      final children = [
                        _capability('I sell', Icons.shopping_cart_outlined,
                            _sells, () => setState(() => _sells = !_sells)),
                        _capability('I buy', Icons.inventory_2_outlined, _buys,
                            () => setState(() => _buys = !_buys))
                      ];
                      return stacked
                          ? Column(children: [
                              children[0],
                              const SizedBox(height: 10),
                              children[1]
                            ])
                          : Row(children: [
                              Expanded(child: children[0]),
                              const SizedBox(width: 12),
                              Expanded(child: children[1])
                            ]);
                    }),
                    const SizedBox(height: 28),
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AfrigoColors.primary.withOpacity(.06),
                            borderRadius: BorderRadius.circular(16)),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.verified_user_outlined,
                                  color: AfrigoColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(
                                      'Your business profile is visible only where a trading interaction requires it. Verification remains pending until AfriGoOS reviews submitted evidence.',
                                      style: AfrigoTypography.interBody2
                                          .copyWith(
                                              color:
                                                  AfrigoColors.textSecondary)))
                            ])),
                    const SizedBox(height: 28),
                    SizedBox(
                        height: 56,
                        child: FilledButton(
                            onPressed: _saving ? null : _save,
                            child: _saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('Save and continue'))),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _field(String label, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: AfrigoTypography.interBody2Semi
                .copyWith(color: AfrigoColors.textPrimary)),
        const SizedBox(height: 8),
        child
      ]));
  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFFCFDFD),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AfrigoColors.borderLight)));
  Widget _menu(String value, List<String> values, IconData icon,
          ValueChanged<String?> change) =>
      DropdownButtonFormField<String>(
          initialValue: value,
          items: values
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: change,
          decoration: _decoration('', icon));
  Widget _capability(
          String text, IconData icon, bool active, VoidCallback onTap) =>
      Semantics(
          selected: active,
          button: true,
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 74,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: active
                          ? AfrigoColors.primary.withOpacity(.08)
                          : Colors.white,
                      border: Border.all(
                          color: active
                              ? AfrigoColors.primary
                              : AfrigoColors.borderLight,
                          width: active ? 2 : 1)),
                  child: Row(children: [
                    Icon(icon, color: AfrigoColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(text,
                            style: AfrigoTypography.interBody2Semi
                                .copyWith(color: AfrigoColors.primary))),
                    Icon(active ? Icons.check_circle : Icons.circle_outlined,
                        color: active
                            ? AfrigoColors.primary
                            : AfrigoColors.textTertiary)
                  ]))));
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: 45,
            height: 45,
            child: Image.asset('assets/images/Afrigolg1.png',
                fit: BoxFit.contain)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AfriGoOS',
              style: AfrigoTypography.soraHeading5
                  .copyWith(color: AfrigoColors.primary)),
          Text('Africa Trades Together',
              style: AfrigoTypography.interBody3
                  .copyWith(color: AfrigoColors.primary))
        ])
      ]);
}

class _Progress extends StatelessWidget {
  const _Progress();
  @override
  Widget build(BuildContext context) => const Row(children: [
        Expanded(child: _Step(label: '1. Account', complete: true)),
        Expanded(child: _Step(label: '2. Business profile', active: true)),
        Expanded(child: _Step(label: '3. Preferences'))
      ]);
}

class _Step extends StatelessWidget {
  const _Step(
      {required this.label, this.complete = false, this.active = false});
  final String label;
  final bool complete;
  final bool active;
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: complete || active
                    ? AfrigoColors.primary
                    : AfrigoColors.borderLight),
            child: Icon(complete ? Icons.check : null,
                color: Colors.white, size: 18)),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11,
                color:
                    active ? AfrigoColors.primary : AfrigoColors.textSecondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500))
      ]);
}
