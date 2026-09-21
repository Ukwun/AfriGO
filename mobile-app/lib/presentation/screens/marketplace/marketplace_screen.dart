import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/providers/lots_provider.dart';
import '../../../domain/models/lot_model.dart';
import '../../../config/colors.dart';
import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _selectedCategory = 'All markets';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final lotsAsync = ref.watch(lotsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      body: Column(
        children: [
          Expanded(
            child: lotsAsync.when(
              loading: () => const _MarketplaceLoading(),
              error: (_, __) => _MarketplaceUnavailable(
                onRetry: () => ref.invalidate(lotsProvider),
              ),
              data: (lots) => _MarketplaceContents(
                lots: lots,
                currentUser: user,
                selectedCategory: _selectedCategory,
                query: _query,
                onCategoryChanged: (value) {
                  if (value == 'Buyer requests') {
                    // RFQs are a separate live resource; route to their
                    // real-time list instead of fabricating request cards.
                    context.push('/rfqs');
                    return;
                  }
                  setState(() => _selectedCategory = value);
                },
                onQueryChanged: (value) => setState(() => _query = value),
                onRefresh: () async {
                  ref.invalidate(lotsProvider);
                  await ref.read(lotsProvider.future);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _MarketplaceNavigation(
        onHome: () => context.go(_homeRouteFor(user?.roles.firstOrNull)),
        onTrades: () => context.push('/quotes'),
        onSupport: () => context.push('/support'),
        onProfile: () => context.push('/profile'),
      ),
    );
  }
}

String _homeRouteFor(String? role) => switch (role) {
      'supplier' => '/supplier/home',
      'exporter' => '/exporter/home',
      _ => '/buyer/home',
    };

class _MarketplaceContents extends StatelessWidget {
  const _MarketplaceContents({
    required this.lots,
    required this.currentUser,
    required this.selectedCategory,
    required this.query,
    required this.onCategoryChanged,
    required this.onQueryChanged,
    required this.onRefresh,
  });

  final List<LotModel> lots;
  final AuthUser? currentUser;
  final String selectedCategory;
  final String query;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onQueryChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    const categories = ['All markets', 'Products', 'Buyer requests'];
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = lots.where((lot) {
      // Lots are inventory products. Buyer requests are a separate Firestore
      // resource and should not be presented as fake product results here.
      final categoryMatches = selectedCategory != 'Buyer requests';
      final text =
          '${lot.productName} ${lot.productType} ${lot.location} ${lot.sellerName}'
              .toLowerCase();
      return categoryMatches &&
          (normalizedQuery.isEmpty || text.contains(normalizedQuery));
    }).toList(growable: false);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AfriGoOSMark(),
                    const SizedBox(height: 28),
                    Text('Trade opportunities',
                        style: AfrigoTypography.soraHeading2
                            .copyWith(color: AfrigoColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(
                        'Search products or buyer requests across Africa.',
                        style: AfrigoTypography.interBody1
                            .copyWith(color: AfrigoColors.textSecondary)),
                    const SizedBox(height: 22),
                    TextField(
                      onChanged: onQueryChanged,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search products or buyer requests...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                                color: AfrigoColors.borderLight)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                                color: AfrigoColors.borderLight)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: categories
                              .map((category) => Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: ChoiceChip(
                                      selected: category == selectedCategory,
                                      onSelected: (_) =>
                                          onCategoryChanged(category),
                                      avatar: Icon(
                                          category == 'All markets'
                                              ? Icons.public_rounded
                                              : category == 'Products'
                                                  ? Icons.inventory_2_outlined
                                                  : Icons.people_alt_outlined,
                                          size: 18,
                                          color: category == selectedCategory
                                              ? Colors.white
                                              : AfrigoColors.primary),
                                      label: Text(category),
                                      selectedColor: AfrigoColors.primary,
                                      backgroundColor:
                                          AfrigoColors.primary.withOpacity(.07),
                                      labelStyle: TextStyle(
                                          color: category == selectedCategory
                                              ? Colors.white
                                              : AfrigoColors.primary,
                                          fontWeight: FontWeight.w700),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          side: BorderSide(
                                              color:
                                                  category == selectedCategory
                                                      ? AfrigoColors.primary
                                                      : Colors.transparent)),
                                    ),
                                  ))
                              .toList()),
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      Text('Live listings',
                          style: AfrigoTypography.soraHeading5
                              .copyWith(color: AfrigoColors.textPrimary)),
                      const Spacer(),
                      Text(
                          '${filtered.length} result${filtered.length == 1 ? '' : 's'}',
                          style: AfrigoTypography.interBody2
                              .copyWith(color: AfrigoColors.textSecondary)),
                    ]),
                  ]),
            ),
          ),
          if (filtered.isEmpty)
            const SliverFillRemaining(
                hasScrollBody: false, child: _MarketplaceEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                itemBuilder: (context, index) => LotCard(lot: filtered[index]),
                separatorBuilder: (_, __) => const SizedBox(height: 4),
              ),
            ),
        ],
      ),
    );
  }
}

class _AfriGoOSMark extends StatelessWidget {
  const _AfriGoOSMark();
  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(
            width: 45,
            height: 45,
            child: Image.asset('assets/images/Afrigolg1.png',
                fit: BoxFit.contain)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AfriGoOS',
              style: AfrigoTypography.soraHeading5
                  .copyWith(color: AfrigoColors.primary, height: 1)),
          Text('Africa Trades Together',
              style: AfrigoTypography.interBody2Semi
                  .copyWith(color: AfrigoColors.primary)),
        ]),
      ]);
}

class _MarketplaceLoading extends StatelessWidget {
  const _MarketplaceLoading();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _MarketplaceUnavailable extends StatelessWidget {
  const _MarketplaceUnavailable({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off_rounded,
              size: 52, color: AfrigoColors.textSecondary),
          const SizedBox(height: 16),
          Text('Live opportunities are unavailable',
              style: AfrigoTypography.soraHeading5),
          const SizedBox(height: 8),
          Text(
              'We could not reach the marketplace right now. Your account and previous activity are safe.',
              textAlign: TextAlign.center,
              style: AfrigoTypography.interBody2
                  .copyWith(color: AfrigoColors.textSecondary)),
          const SizedBox(height: 18),
          FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh listings')),
        ]),
      ));
}

class _MarketplaceEmpty extends StatelessWidget {
  const _MarketplaceEmpty();
  @override
  Widget build(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.travel_explore_rounded,
              size: 56, color: AfrigoColors.primary),
          const SizedBox(height: 16),
          Text('No matching live listings',
              style: AfrigoTypography.soraHeading5),
          const SizedBox(height: 8),
          Text(
              'Try another search or check back when a business publishes an opportunity.',
              textAlign: TextAlign.center,
              style: AfrigoTypography.interBody2
                  .copyWith(color: AfrigoColors.textSecondary)),
        ]),
      ));
}

class _MarketplaceNavigation extends StatelessWidget {
  const _MarketplaceNavigation(
      {required this.onHome,
      required this.onTrades,
      required this.onSupport,
      required this.onProfile});
  final VoidCallback onHome;
  final VoidCallback onTrades;
  final VoidCallback onSupport;
  final VoidCallback onProfile;
  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              onHome();
            case 2:
              onTrades();
            case 3:
              onSupport();
            case 4:
              onProfile();
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.search_rounded), label: 'Explore'),
          NavigationDestination(
              icon: Icon(Icons.swap_horiz_rounded), label: 'Trades'),
          NavigationDestination(
              icon: Icon(Icons.headset_mic_outlined), label: 'Support'),
          NavigationDestination(
              icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      );
}

class LotCard extends StatefulWidget {
  final LotModel lot;

  const LotCard({required this.lot, super.key});

  @override
  State<LotCard> createState() => _LotCardState();
}

String _fallbackLotImage(LotModel lot) {
  final product = '${lot.productName} ${lot.productType}'.toLowerCase();
  if (product.contains('construction') || product.contains('building')) {
    return 'assets/images/construction-work-site.jpg';
  }
  if (product.contains('export') || product.contains('logistics')) {
    return 'assets/images/photorealistic-scene-with-warehouse-logistics-operations.jpg';
  }
  return 'assets/images/pexels-zahrah-nandoo-2147929825-29833299.jpg';
}

class _LotCardState extends State<LotCard> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> contactSupplier() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.lot.sellerId.isEmpty) return;
    if (user.uid == widget.lot.sellerId) {
      context.push('/lots/detail/${widget.lot.id}');
      return;
    }
    final ids = [user.uid, widget.lot.sellerId]..sort();
    final conversationId = '${ids[0]}_${ids[1]}_${widget.lot.id}';
    try {
      final userProfile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final ownName =
          (userProfile.data()?['fullName'] ?? user.displayName ?? user.email)
              .toString();
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .set({
        'id': conversationId,
        'participantIds': ids,
        'participantNames': {
          user.uid: ownName,
          widget.lot.sellerId: widget.lot.sellerName,
        },
        'lotId': widget.lot.id,
        'lotName': widget.lot.productName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) context.push('/messages/$conversationId');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation could not be opened. Please retry.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => controller.forward(),
        onTapUp: (_) {
          controller.reverse();
          context.push('/lots/detail/${widget.lot.id}');
        },
        onTapCancel: () => controller.reverse(),
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AfrigoColors.borderLight),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 190,
            child: LayoutBuilder(builder: (context, constraints) {
              final imageWidth = constraints.maxWidth < 390 ? 112.0 : 132.0;
              final image = widget.lot.imageUrl?.trim();
              return Row(children: [
                SizedBox(
                  width: imageWidth,
                  height: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(18)),
                    child: image != null && image.isNotEmpty
                        ? Image.network(image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _fallbackImage(widget.lot, imageWidth))
                        : _fallbackImage(widget.lot, imageWidth),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AfrigoColors.primary.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text('Product',
                                style: AfrigoTypography.interBody3Semi
                                    .copyWith(color: AfrigoColors.primary)),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded,
                              color: AfrigoColors.textSecondary),
                        ]),
                        const SizedBox(height: 8),
                        Text(widget.lot.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AfrigoTypography.soraHeading6.copyWith(
                                color: AfrigoColors.textPrimary)),
                        const Spacer(),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 19, color: AfrigoColors.textSecondary),
                          const SizedBox(width: 5),
                          Expanded(
                              child: Text(widget.lot.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AfrigoTypography.interBody2.copyWith(
                                      color: AfrigoColors.textSecondary))),
                        ]),
                        const SizedBox(height: 5),
                        Row(children: [
                          const Icon(Icons.inventory_2_outlined,
                              size: 19, color: AfrigoColors.textSecondary),
                          const SizedBox(width: 5),
                          Expanded(
                              child: Text(
                                  '${widget.lot.quantity.toStringAsFixed(0)} ${widget.lot.unit} available',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AfrigoTypography.interBody2.copyWith(
                                      color: AfrigoColors.textSecondary))),
                        ]),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () =>
                                context.push('/lots/detail/${widget.lot.id}'),
                            icon: const Icon(Icons.arrow_forward_ios_rounded,
                                size: 12),
                            label: const Text('View details'),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.secondaryGold,
                                visualDensity: VisualDensity.compact),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]);
            }),
          ),
        ),
      ),
    );
  }

  Widget _fallbackImage(LotModel lot, double width) => Image.asset(
        _fallbackLotImage(lot),
        width: width,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AfrigoColors.bgLightAlt,
          child: const Icon(Icons.inventory_2_outlined,
              color: AfrigoColors.primary, size: 40),
        ),
      );
}
