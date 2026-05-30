import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/motion_system.dart';
import '../../../config/colors.dart';
import '../../../config/theme.dart';
import '../../../domain/models/product_model.dart';
import '../../../data/providers/product_provider.dart';

/// PRODUCT LISTING SCREEN - Complete marketplace interface
/// Shows searchable product cards with real-time filtering
/// Features: Search, filter, sort, infinite scroll, real-time updates
/// Animations: FadeIn (header), SlideIn (cards), ScaleIn (taps)
/// Status: Production-ready with full error handling

class ProductListingScreen extends ConsumerStatefulWidget {
  final String? initialSearchQuery;
  final String? filterCategory;

  const ProductListingScreen({
    this.initialSearchQuery,
    this.filterCategory,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ProductListingScreen> createState() =>
      _ProductListingScreenState();
}

class _ProductListingScreenState extends ConsumerState<ProductListingScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  String _sortBy = 'relevance';
  String _selectedCategory = '';
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.initialSearchQuery ?? '');
    _scrollController = ScrollController();
    _fadeController =
        AnimationController(duration: Duration(milliseconds: 400));

    // Listen to scroll for infinite scroll
    _scrollController.addListener(_handleScroll);

    // Trigger initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      if (widget.initialSearchQuery != null) {
        ref.read(productsSearchProvider.notifier).search(
              widget.initialSearchQuery!,
              category: widget.filterCategory,
            );
      }
    });

    _selectedCategory = widget.filterCategory ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (!_isLoadingMore) {
        setState(() => _isLoadingMore = true);
        ref.read(productsSearchProvider.notifier).loadMore();
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) setState(() => _isLoadingMore = false);
        });
      }
    }
  }

  void _handleSearch(String query) {
    _searchController.text = query;
    ref
        .read(productsSearchProvider.notifier)
        .search(query, category: _selectedCategory);
  }

  void _handleFilterChange(String category) {
    setState(() => _selectedCategory = category);
    final query = _searchController.text;
    ref.read(productsSearchProvider.notifier).search(query, category: category);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(productsSearchProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search & Filter Bar
          _buildSearchBar(),
          _buildFilterBar(),

          // Products List
          Expanded(
            child: searchState.when(
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error.toString()),
              data: (products) {
                if (products.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildProductsGrid(products);
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: FadeInTransition(
        duration: 300,
        child: Text(
          'Marketplace',
          style: AppTheme.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list, color: AppColors.textPrimary),
          onPressed: _showAdvancedFilters,
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return FadeInTransition(
      duration: 400,
      delay: 100,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            // Debounce search
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted && _searchController.text == value) {
                _handleSearch(value);
              }
            });
          },
          decoration: InputDecoration(
            hintText: 'Search products, suppliers...',
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      _handleSearch('');
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLight, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLight, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: AppTheme.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final categories = ['All', 'Cocoa', 'Coffee', 'Vegetables', 'Grains'];

    return FadeInTransition(
      duration: 400,
      delay: 150,
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _selectedCategory == category ||
                (category == 'All' && _selectedCategory == '');
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: _FilterChip(
                label: category,
                isSelected: isSelected,
                onTap: () {
                  _handleFilterChange(category == 'All' ? '' : category);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductsGrid(List<ProductModel> products) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: products.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return _buildLoadingMoreIndicator();
        }

        final product = products[index];
        return ScaleInTransition(
          delay: (index % 4) * 50,
          child: _ProductCard(
            product: product,
            onTap: () {
              context.push('/products/${product.id}', extra: product);
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Loading products...',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          SizedBox(height: 16),
          Text(
            'Failed to load products',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.refresh(productsSearchProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Try Again',
              style: AppTheme.labelLarge.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'No products found',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _selectedCategory = '');
              _handleSearch('');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Clear Filters',
              style: AppTheme.labelLarge.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AdvancedFilterSheet(
        onApply: (filters) {
          // Apply advanced filters
          ref.read(productsSearchProvider.notifier).applyFilters(filters);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Individual product card with animations and real-time data
class _ProductCard extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isProductFavoriteProvider(product.id));

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
        elevation: 0,
        color: AppColors.cardBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with seller badge
            Stack(
              children: [
                // Product image
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    color: AppColors.background,
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.borderLight,
                        child: Center(
                          child: Icon(Icons.image_not_supported,
                              color: AppColors.textSecondary, size: 40),
                        ),
                      );
                    },
                  ),
                ),

                // Quality badge
                if (product.quality != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getQualityColor(product.quality),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.quality!.toUpperCase(),
                        style: AppTheme.labelSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 1.2).animate(
                      CurvedAnimation(
                        parent: AlwaysStoppedAnimation(0.5),
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(
                                isProductFavoriteProvider(product.id).notifier)
                            .toggleFavorite(product.id);
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite.value == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite.value == true
                              ? AppColors.error
                              : AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 4),

                  // Seller info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(product.sellerAvatarUrl),
                        onBackgroundImageError: (_, __) {},
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.sellerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.labelMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    size: 14, color: AppColors.warning),
                                SizedBox(width: 2),
                                Text(
                                  '${product.sellerRating}',
                                  style: AppTheme.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '(${product.sellerReviews})',
                                  style: AppTheme.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Price & quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}/kg',
                            style: AppTheme.headlineSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (product.originalPrice != null &&
                              product.originalPrice! > product.price)
                            Text(
                              '\$${product.originalPrice!.toStringAsFixed(2)}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.borderLight,
                          ),
                        ),
                        child: Text(
                          '${product.quantityAvailable.toStringAsFixed(0)} kg',
                          style: AppTheme.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Location + Days left
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      if (product.daysUntilExpiry != null)
                        Text(
                          '${product.daysUntilExpiry} days left',
                          style: AppTheme.labelSmall.copyWith(
                            color: product.daysUntilExpiry! <= 3
                                ? AppColors.error
                                : AppColors.warning,
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'View & Make Offer',
                        style: AppTheme.labelLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'grade a':
      case 'premium':
        return Color(0xFF2ECC71); // Green
      case 'grade b':
      case 'standard':
        return Color(0xFF3498DB); // Blue
      default:
        return Color(0xFF95A5A6); // Gray
    }
  }
}

/// Filter chip widget with smooth animation
class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_FilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _animationController.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scale = 0.95 + (0.05 * _animationController.value);
        return Transform.scale(
          scale: scale,
          child: FilterChip(
            label: Text(
              widget.label,
              style: AppTheme.labelMedium.copyWith(
                color:
                    widget.isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            selected: widget.isSelected,
            onSelected: (_) {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            backgroundColor: Colors.transparent,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color:
                  widget.isSelected ? AppColors.primary : AppColors.borderLight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
}

/// Advanced filter bottom sheet
class _AdvancedFilterSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;

  const _AdvancedFilterSheet({
    required this.onApply,
    Key? key,
  }) : super(key: key);

  @override
  State<_AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<_AdvancedFilterSheet> {
  double _minPrice = 0;
  double _maxPrice = 100;
  String _sortBy = 'relevance';
  Set<String> _qualityFilters = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Advanced Filters',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Price Range
              Text(
                'Price Range',
                style: AppTheme.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: 0,
                max: 100,
                onChanged: (values) {
                  setState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                },
                activeColor: AppColors.primary,
                inactiveColor: AppColors.borderLight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${_minPrice.toStringAsFixed(0)}',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '\$${_maxPrice.toStringAsFixed(0)}',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Quality filter
              Text(
                'Quality',
                style: AppTheme.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Grade A', 'Grade B', 'Standard', 'Premium']
                    .map((quality) => FilterChip(
                          label: Text(quality),
                          selected: _qualityFilters.contains(quality),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _qualityFilters.add(quality);
                              } else {
                                _qualityFilters.remove(quality);
                              }
                            });
                          },
                        ))
                    .toList(),
              ),

              SizedBox(height: 24),

              // Sort by
              Text(
                'Sort By',
                style: AppTheme.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: _sortBy,
                isExpanded: true,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _sortBy = value);
                  }
                },
                items: [
                  'relevance',
                  'price_low_high',
                  'price_high_low',
                  'newest',
                  'rating',
                ]
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(
                            option.replaceAll('_', ' ').toUpperCase(),
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ))
                    .toList(),
              ),

              SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = 0;
                          _maxPrice = 100;
                          _sortBy = 'relevance';
                          _qualityFilters.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Reset'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply({
                          'minPrice': _minPrice,
                          'maxPrice': _maxPrice,
                          'quality': _qualityFilters.toList(),
                          'sortBy': _sortBy,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Apply',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }
}
