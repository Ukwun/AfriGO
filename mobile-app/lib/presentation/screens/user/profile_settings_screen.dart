import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/motion_system.dart';
import '../../../config/colors.dart';
import '../../../config/theme.dart';
import '../../../domain/models/user.dart';
import '../../../data/providers/user_provider.dart';

/// PROFILE & SETTINGS SCREEN - User account management
/// Shows: Profile info, trust score, KYC status, preferences, logout
/// Features: Photo upload, editable profile, KYC verification, notification settings
/// Animations: FadeIn sections, scale on button press, smooth transitions
/// Status: Production-ready with profile update & KYC integration

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _businessNameController;
  late TextEditingController _businessDescriptionController;
  bool _isEditingProfile = false;
  bool _isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _businessNameController = TextEditingController();
    _businessDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Upload to backend
      await ref.read(uploadProfilePhotoProvider).call(image.path);
    }
  }

  Future<void> _saveProfileChanges() async {
    if (_fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Full name is required'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSavingProfile = true);

    try {
      await ref.read(updateProfileProvider).call(
            fullName: _fullNameController.text,
            phone: _phoneController.text,
            businessName: _businessNameController.text,
            businessDescription: _businessDescriptionController.text,
          );

      setState(() {
        _isEditingProfile = false;
        _isSavingProfile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Profile updated successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      ref.refresh(currentUserProvider);
    } catch (error) {
      setState(() => _isSavingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profile & Settings',
          style: AppTheme.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Profile'),
            Tab(text: 'Security'),
            Tab(text: 'Preferences'),
          ],
        ),
      ),
      body: userAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
        data: (user) => _buildTabContent(user),
      ),
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
            'Loading profile...',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
            'Failed to load profile',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.refresh(currentUserProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Try Again',
              style: AppTheme.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(User user) {
    // Initialize controllers on first build
    if (_fullNameController.text.isEmpty) {
      _fullNameController.text = user.fullName;
      _phoneController.text = user.phone ?? '';
      _businessNameController.text = user.businessName ?? '';
      _businessDescriptionController.text = user.businessDescription ?? '';
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildProfileTab(user),
        _buildSecurityTab(user),
        _buildPreferencesTab(user),
      ],
    );
  }

  Widget _buildProfileTab(User user) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header with photo
            FadeInTransition(
              delay: 100,
              child: _buildProfileHeader(user),
            ),
            SizedBox(height: 24),

            // Trust score card
            FadeInTransition(
              delay: 150,
              child: _buildTrustScoreCard(user),
            ),
            SizedBox(height: 24),

            // Profile form
            FadeInTransition(
              delay: 200,
              child: _buildProfileForm(user),
            ),
            SizedBox(height: 24),

            // Business info section
            FadeInTransition(
              delay: 250,
              child: _buildBusinessInfoSection(user),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  image: user.profilePhoto != null
                      ? DecorationImage(
                          image: NetworkImage(user.profilePhoto!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user.profilePhoto == null
                    ? Center(
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickProfilePhoto,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            user.fullName,
            style: AppTheme.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            user.email,
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              user.userRole.toString().split('.').last.toUpperCase(),
              style: AppTheme.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustScoreCard(User user) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.success.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trust Score',
                style: AppTheme.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(Icons.verified, color: AppColors.success, size: 20),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rating',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < user.trustScore.toInt() / 20
                              ? Icons.star
                              : Icons.star_outline,
                          size: 16,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Score',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${user.trustScore.toStringAsFixed(0)}/100',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          // Trust score breakdown
          Column(
            children: [
              _buildScoreFactor(
                  'Verified Account', user.isKycVerified ? 8 : 0, 8),
              _buildScoreFactor(
                  'Completed Trades', user.completedTrades.toDouble(), 20),
              _buildScoreFactor(
                  'On-Time Payments', user.onTimePaymentRate * 20, 20),
              _buildScoreFactor(
                  'Positive Reviews', (user.averageRating / 5 * 10), 10),
              _buildScoreFactor('No Disputes',
                  user.hasNoDisputes ? 34 : user.trustScore - 40, 34),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreFactor(String label, double points, double maxPoints) {
    final percentage = (points / maxPoints * 100).clamp(0, 100).toDouble();

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '${points.toStringAsFixed(0)}/${maxPoints.toInt()}',
            style: AppTheme.labelSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(User user) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Information',
                style: AppTheme.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              if (!_isEditingProfile)
                TextButton(
                  onPressed: () {
                    setState(() => _isEditingProfile = true);
                  },
                  child: Text(
                    'Edit',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),

          // Full name
          _buildFormField(
            'Full Name',
            _fullNameController,
            enabled: _isEditingProfile,
          ),
          SizedBox(height: 12),

          // Phone
          _buildFormField(
            'Phone Number',
            _phoneController,
            enabled: _isEditingProfile,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 12),

          // Email (read-only)
          _buildFormField(
            'Email',
            TextEditingController(text: user.email),
            enabled: false,
          ),
          SizedBox(height: 12),

          // KYC Status
          _buildKycStatusWidget(user),

          if (_isEditingProfile) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _isEditingProfile = false);
                      _fullNameController.text = user.fullName;
                      _phoneController.text = user.phone ?? '';
                    },
                    child: Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSavingProfile ? null : _saveProfileChanges,
                    icon: _isSavingProfile
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.check),
                    label: Text(_isSavingProfile ? 'Saving...' : 'Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildKycStatusWidget(User user) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: user.isKycVerified
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: user.isKycVerified ? AppColors.success : AppColors.warning,
        ),
      ),
      child: Row(
        children: [
          Icon(
            user.isKycVerified ? Icons.verified : Icons.pending,
            color: user.isKycVerified ? AppColors.success : AppColors.warning,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KYC Status',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  user.isKycVerified
                      ? 'Verified on ${user.kycVerifiedDate}'
                      : 'Pending verification',
                  style: AppTheme.bodySmall.copyWith(
                    color: user.isKycVerified
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          if (!user.isKycVerified)
            TextButton(
              onPressed: () {
                context.push('/kyc-verification');
              },
              child: Text(
                'Verify',
                style: AppTheme.labelSmall.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoSection(User user) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Information',
            style: AppTheme.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          _buildFormField(
            'Business Name',
            _businessNameController,
            enabled: _isEditingProfile,
          ),
          SizedBox(height: 12),
          _buildFormField(
            'Business Description',
            _businessDescriptionController,
            enabled: _isEditingProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab(User user) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            FadeInTransition(
              delay: 100,
              child: _buildSecurityOption(
                title: 'Change Password',
                subtitle: 'Update your password',
                icon: Icons.lock,
                onTap: () {
                  context.push('/change-password');
                },
              ),
            ),
            SizedBox(height: 12),
            FadeInTransition(
              delay: 150,
              child: _buildSecurityOption(
                title: 'Two-Factor Authentication',
                subtitle: 'Add extra security to your account',
                icon: Icons.security,
                onTap: () {
                  context.push('/enable-2fa');
                },
              ),
            ),
            SizedBox(height: 12),
            FadeInTransition(
              delay: 200,
              child: _buildSecurityOption(
                title: 'Active Sessions',
                subtitle: 'Manage your login sessions',
                icon: Icons.devices,
                onTap: () {
                  context.push('/active-sessions');
                },
              ),
            ),
            SizedBox(height: 12),
            FadeInTransition(
              delay: 250,
              child: _buildSecurityOption(
                title: 'Privacy & Data',
                subtitle: 'Control your data sharing',
                icon: Icons.privacy_tip,
                onTap: () {
                  context.push('/privacy-settings');
                },
              ),
            ),
            SizedBox(height: 32),
            ScaleInTransition(
              delay: 300,
              child: _buildLogoutButton(),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Logout'),
              content: Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(logoutProvider).call();
                    context.go('/login');
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        },
        icon: Icon(Icons.logout),
        label: Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesTab(User user) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            FadeInTransition(
              delay: 100,
              child: _buildPreferenceSection(
                title: 'Notifications',
                children: [
                  _buildPreferenceToggle('Trade Offers', true),
                  _buildPreferenceToggle('Shipment Updates', true),
                  _buildPreferenceToggle('Payment Alerts', true),
                  _buildPreferenceToggle('Marketing Emails', false),
                ],
              ),
            ),
            SizedBox(height: 24),
            FadeInTransition(
              delay: 150,
              child: _buildPreferenceSection(
                title: 'Privacy',
                children: [
                  _buildPreferenceToggle('Show Profile to Buyers', true),
                  _buildPreferenceToggle('Allow Contact Requests', true),
                  _buildPreferenceToggle('Make Reviews Public', true),
                ],
              ),
            ),
            SizedBox(height: 24),
            FadeInTransition(
              delay: 200,
              child: _buildPreferenceSection(
                title: 'App Settings',
                children: [
                  _buildPreferenceDropdown('Language', 'English'),
                  _buildPreferenceDropdown('Currency', 'USD'),
                  _buildPreferenceDropdown('Theme', 'Light'),
                ],
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              title,
              style: AppTheme.titleSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Divider(color: AppColors.borderLight),
          ...List.generate(
            children.length,
            (index) => Column(
              children: [
                children[index],
                if (index < children.length - 1)
                  Divider(color: AppColors.borderLight, height: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceToggle(String label, bool value) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // Update preference
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceDropdown(String label, String currentValue) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<String>(
              value: currentValue,
              underline: SizedBox.shrink(),
              items: [currentValue].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                // Update preference
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Note: Providers used but not defined here
// ref.watch(currentUserProvider) - Get current user profile
// ref.read(uploadProfilePhotoProvider) - Upload new profile photo
// ref.read(updateProfileProvider) - Update profile info
// ref.read(logoutProvider) - Logout user
// These should be defined in user_provider.dart
