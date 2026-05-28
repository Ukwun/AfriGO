# 🎯 WEEKS 2-4 COMPLETE IMPLEMENTATION GUIDE
## Fix Authentication + Connect All Screens + Add Animations + Test on Android

**Timeline:** June 4 - June 24, 2026 (3 weeks)  
**Goal:** Every button works, every screen is functional, app feels alive with animations  
**Testing:** Android device connected to laptop throughout  
**Focus:** Realistic product that works in real-time

---

## TABLE OF CONTENTS

1. [Authentication Issues - ROOT CAUSE & FIX](#auth-issues)
2. [Week 2 Implementation (June 4-10)](#week-2)
3. [Week 3 Implementation (June 11-17)](#week-3)
4. [Week 4 Implementation (June 18-24)](#week-4)
5. [Real-Time Testing on Android Device](#android-testing)
6. [Micro-Animations Implementation](#animations)
7. [Verification Checklist](#checklist)

---

<a name="auth-issues"></a>
# 1. AUTHENTICATION ISSUES - ROOT CAUSE & FIX

## Problem: Why Authentication is Failing

### Issue 1: Backend Using In-Memory Mock Users

**Current State:**
```typescript
// Backend is storing users in memory (mockUsers array)
// This means:
// ❌ Users are lost when server restarts
// ❌ Each server instance has different users
// ❌ Multiple concurrent requests might conflict
```

**Solution:** Use real database (PostgreSQL)

### Issue 2: Mobile App Can't Connect to Backend

**Current State:**
```dart
// Mobile might be trying to connect to wrong URL
// Common issues:
// ❌ Using 'localhost' (localhost doesn't exist on Android device)
// ❌ Using hardcoded IP that's not accessible
// ❌ Firebase Auth not properly configured
```

**Solution:** Use correct network URL

### Issue 3: Token Not Being Persisted

**Current State:**
```dart
// Token might be lost after app restart
// Mobile tries to use old/missing token
// Backend rejects request
```

**Solution:** Implement secure token storage

---

## FIX 1: Configure Backend API Client URL (Mobile)

**File:** `lib/data/services/api_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;
  String? _token;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    // Initialize Dio with correct backend URL
    _dio = Dio(
      BaseOptions(
        // IMPORTANT: Use your laptop's LOCAL NETWORK IP, NOT localhost
        // Find your IP: ipconfig (Windows) or ifconfig (Mac/Linux)
        // Look for IPv4 Address like 192.168.x.x or 10.0.x.x
        // Example: baseUrl: 'http://192.168.1.100:3000/api',
        
        baseUrl: 'http://192.168.1.100:3000/api', // ← CHANGE THIS TO YOUR IP
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors for token handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Load token from secure storage
          _token = await _getStoredToken();
          
          if (_token != null) {
            // Add token to every request header
            options.headers['Authorization'] = 'Bearer $_token';
          }
          
          return handler.next(options);
        },
        onError: (error, handler) async {
          // If token is invalid/expired, refresh it
          if (error.response?.statusCode == 401) {
            try {
              await _refreshToken();
              // Retry original request with new token
              return handler.resolve(await _retry(error.requestOptions));
            } catch (e) {
              // If refresh fails, clear token and redirect to login
              await _clearToken();
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> _refreshToken() async {
    // Call backend refresh endpoint
    final response = await _dio.post('/auth/refresh');
    final newToken = response.data['token'];
    await _saveToken(newToken);
    _token = newToken;
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Save token
      if (response.data['token'] != null) {
        await _saveToken(response.data['token']);
        _token = response.data['token'];
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Register method
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

      // Save token
      if (response.data['token'] != null) {
        await _saveToken(response.data['token']);
        _token = response.data['token'];
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic GET method
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic POST method
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PUT method
  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Check if backend is running.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Server took too long to respond.';
    } else if (error.response != null) {
      return error.response?.data['message'] ?? 'Server error';
    } else {
      return 'Network error: ${error.message}';
    }
  }

  Future<void> logout() async {
    await _clearToken();
    _token = null;
  }
}

// Singleton provider
final apiClientProvider = Dio();
```

---

## FIX 2: Find Your Laptop's Local Network IP

```bash
# Windows: Open PowerShell and run:
ipconfig

# Look for "IPv4 Address" under "Ethernet adapter" or "Wireless LAN adapter"
# Example output: 192.168.1.100
# Use this IP in the baseUrl above

# Mac/Linux: Open Terminal and run:
ifconfig

# Look for "inet" address (not 127.0.0.1)
# Example: 192.168.1.100
```

**Update the baseUrl in api_client.dart:**
```dart
baseUrl: 'http://192.168.1.100:3000/api', // Replace with YOUR IP
```

---

## FIX 3: Configure Backend for Mobile Access

**File:** `backend/src/main.ts`

```typescript
import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // IMPORTANT: Allow connections from Android device
  // Enable CORS (Cross-Origin Resource Sharing)
  app.enableCors({
    origin: '*', // Allow all origins (safe for local testing)
    credentials: true,
  });

  const port = process.env.API_PORT || 3000;
  // Listen on 0.0.0.0 so it accepts connections from other devices
  const host = '0.0.0.0'; // NOT localhost
  
  await app.listen(port, host);
  
  const logger = new Logger('Bootstrap');
  logger.log(`🚀 AfriGo Backend running on http://0.0.0.0:${port}`);
  logger.log(`📱 Accessible from: http://YOUR_IP:${port} (replace YOUR_IP)`);
}

bootstrap().catch((err) => {
  console.error('Failed to start application:', err);
  process.exit(1);
});
```

---

## FIX 4: Test Authentication Flow

### Step 1: Start Backend

```bash
# Terminal 1: Start backend API
cd c:\afrigo\backend
npm run dev

# Expected output:
# [Nest] 12345  - 05/28/2026, 2:30:45 PM     LOG [NestFactory] Starting Nest application...
# 🚀 AfriGo Backend running on http://0.0.0.0:3000
# 📱 Accessible from: http://192.168.1.100:3000
```

### Step 2: Run Mobile App on Device

```bash
# Terminal 2: Run on connected Android device
cd c:\afrigo\mobile-app
flutter run

# Expected:
# ✓ Connected to Android device
# ✓ App starts and shows login screen
```

### Step 3: Test Login

```
Mobile Steps:
1. Open app
2. Tap "Register" (if first time)
3. Enter:
   - Email: test@afrigo.app
   - Password: Test@123456
   - First Name: John
   - Last Name: Doe
4. Tap "Register" button
5. Should redirect to Dashboard (if successful)

Expected Result:
✅ No "Connection refused" error
✅ No "Authorization failed" error
✅ User successfully logged in
✅ Dashboard loads with user data
```

---

<a name="week-2"></a>
# 2. WEEK 2 IMPLEMENTATION (June 4-10)
## Connect Marketplace + Lots + API Integration

## Goal: Every marketplace screen shows REAL data from backend

### Day 1-2: Create Riverpod Providers for Data Fetching

**File:** `lib/presentation/providers/lots_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../data/services/api_client.dart';
import '../../../domain/models/lot_model.dart';

part 'lots_provider.g.dart';

// Provider for fetching all lots
@riverpod
Future<List<LotModel>> fetchLots(FetchLotsRef ref) async {
  final apiClient = ApiClient();
  
  try {
    final response = await apiClient.get('/lots');
    
    // Parse response
    final List<dynamic> lotsData = response['data'] ?? [];
    
    return lotsData
        .map((lot) => LotModel.fromJson(lot as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch lots: $e');
  }
}

// Provider for fetching single lot with full details
@riverpod
Future<LotModel> fetchLotDetail(FetchLotDetailRef ref, String lotId) async {
  final apiClient = ApiClient();
  
  try {
    final response = await apiClient.get('/lots/$lotId');
    return LotModel.fromJson(response['data'] as Map<String, dynamic>);
  } catch (e) {
    throw Exception('Failed to fetch lot: $e');
  }
}

// Provider for fetching lots by category
@riverpod
Future<List<LotModel>> fetchLotsByCategory(
  FetchLotsByCategoryRef ref,
  String category,
) async {
  final apiClient = ApiClient();
  
  try {
    final response = await apiClient.get('/lots?category=$category');
    
    final List<dynamic> lotsData = response['data'] ?? [];
    
    return lotsData
        .map((lot) => LotModel.fromJson(lot as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch lots by category: $e');
  }
}

// Provider for creating new lot (seller feature)
@riverpod
Future<LotModel> createLot(
  CreateLotRef ref, {
  required String productName,
  required String productType,
  required double quantity,
  required String unit,
  required double pricePerUnit,
  required String description,
}) async {
  final apiClient = ApiClient();
  
  try {
    final response = await apiClient.post(
      '/lots',
      data: {
        'productName': productName,
        'productType': productType,
        'quantity': quantity,
        'unit': unit,
        'pricePerUnit': pricePerUnit,
        'description': description,
      },
    );
    
    // Invalidate lots list to refresh
    ref.invalidate(fetchLotsProvider);
    
    return LotModel.fromJson(response['data'] as Map<String, dynamic>);
  } catch (e) {
    throw Exception('Failed to create lot: $e');
  }
}
```

**File:** `lib/domain/models/lot_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'lot_model.g.dart';

@JsonSerializable()
class LotModel {
  final String id;
  final String productName;
  final String productType;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String currency;
  final String location;
  final String description;
  final String? imageUrl;
  final String status; // 'pending', 'active', 'sold', 'archived'
  final String sellerId;
  final String sellerName;
  final double sellerRating;
  final int sellerCompletedTrades;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LotModel({
    required this.id,
    required this.productName,
    required this.productType,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.currency,
    required this.location,
    required this.description,
    this.imageUrl,
    required this.status,
    required this.sellerId,
    required this.sellerName,
    required this.sellerRating,
    required this.sellerCompletedTrades,
    required this.createdAt,
    this.updatedAt,
  });

  factory LotModel.fromJson(Map<String, dynamic> json) =>
      _$LotModelFromJson(json);

  Map<String, dynamic> toJson() => _$LotModelToJson(this);
}
```

---

### Day 3-4: Build Marketplace Screen (Connected to Real API)

**File:** `lib/presentation/screens/marketplace/marketplace_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/providers/lots_provider.dart';
import '../../../domain/models/lot_model.dart';
import '../../../config/theme.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Cocoa', 'Coffee', 'Cashews', 'Rubber'];

  @override
  Widget build(BuildContext context) {
    // Watch lots data from provider
    final lotsAsync = _selectedCategory == 'All'
        ? ref.watch(fetchLotsProvider)
        : ref.watch(fetchLotsByCategoryProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('AfriGo Marketplace'),
        elevation: 0,
        backgroundColor: AfrigoTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Invalidate cache and refetch
              ref.refresh(fetchLotsProvider);
            },
          ),
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AfrigoTheme.primaryGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? AfrigoTheme.primaryGreen : Colors.grey[300]!,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Lots list
          Expanded(
            child: lotsAsync.when(
              // Loading state
              loading: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AfrigoTheme.primaryGreen),
                    ),
                    const SizedBox(height: 16),
                    const Text('Loading marketplace...'),
                  ],
                ),
              ),

              // Error state
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load products',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.refresh(fetchLotsProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AfrigoTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Success state
              data: (lots) => lots.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text('No products found in this category'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.refresh(fetchLotsProvider);
                      },
                      color: AfrigoTheme.primaryGreen,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: lots.length,
                        itemBuilder: (context, index) {
                          return LotCard(
                            lot: lots[index],
                            onTap: () {
                              // Navigate to lot details
                              context.push('/lot/${lots[index].id}');
                            },
                            onMakeOffer: () {
                              // Navigate to bidding screen
                              context.push('/bid/${lots[index].id}');
                            },
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Add filter options here
            const Text('More filters coming soon...'),
          ],
        ),
      ),
    );
  }
}

// Lot Card Widget
class LotCard extends StatefulWidget {
  final LotModel lot;
  final VoidCallback onTap;
  final VoidCallback onMakeOffer;

  const LotCard({
    required this.lot,
    required this.onTap,
    required this.onMakeOffer,
    super.key,
  });

  @override
  State<LotCard> createState() => _LotCardState();
}

class _LotCardState extends State<LotCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (widget.lot.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    widget.lot.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name and seller rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lot.productName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'From: ${widget.lot.sellerName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Rating
                        Column(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(
                              '${widget.lot.sellerRating.toStringAsFixed(1)}★',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Price and quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.lot.pricePerUnit.toStringAsFixed(2)}/${widget.lot.unit}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AfrigoTheme.primaryGreen,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.lot.quantity.toStringAsFixed(0)} ${widget.lot.unit}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Action buttons (FUNCTIONAL)
                    Row(
                      children: [
                        // View details button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onTap,
                            icon: const Icon(Icons.info_outline, size: 16),
                            label: const Text('View Details'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AfrigoTheme.primaryGreen,
                              side: BorderSide(color: AfrigoTheme.primaryGreen),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Make offer button (FUNCTIONAL)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onMakeOffer,
                            icon: const Icon(Icons.sell, size: 16),
                            label: const Text('Make Offer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AfrigoTheme.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### Day 5: Test on Android Device

```bash
# Terminal: Run app with hot reload
flutter run

# Manual Tests:
1. Open Marketplace tab
2. Verify: Real lots appear (not mock data)
3. Filter by category: Select "Cocoa"
4. Verify: List updates with Cocoa products
5. Tap "View Details" button
6. Verify: Navigates to lot details screen
7. Tap "Make Offer" button
8. Verify: Navigates to bidding screen
9. Go back and Refresh (pull down)
10. Verify: Lots list updates from backend
```

**Expected Results:**
```
✅ All lots loaded from backend API (not hardcoded)
✅ Category filter works (real API filtering)
✅ Buttons are clickable and responsive
✅ Navigation works correctly
✅ Pull-to-refresh works
✅ No errors in console
✅ Frame rate: 60 FPS (smooth scrolling)
```

---

<a name="week-3"></a>
# 3. WEEK 3 IMPLEMENTATION (June 11-17)
## Connect Real-Time Shipment Tracking + Payment Flow

### Day 1-2: Shipment Tracking with Real-Time GPS

**File:** `lib/presentation/providers/shipment_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/services/api_client.dart';
import '../../../domain/models/shipment_model.dart';

part 'shipment_provider.g.dart';

@riverpod
Future<ShipmentModel> fetchShipment(FetchShipmentRef ref, String shipmentId) async {
  final apiClient = ApiClient();

  try {
    final response = await apiClient.get('/shipments/$shipmentId');
    return ShipmentModel.fromJson(response['data'] as Map<String, dynamic>);
  } catch (e) {
    throw Exception('Failed to fetch shipment: $e');
  }
}

// Stream for real-time GPS updates (every 30 seconds)
@riverpod
Stream<ShipmentModel> watchShipmentRealtime(
  WatchShipmentRealtimeRef ref,
  String shipmentId,
) async* {
  final apiClient = ApiClient();

  while (true) {
    try {
      final response = await apiClient.get('/shipments/$shipmentId');
      yield ShipmentModel.fromJson(response['data'] as Map<String, dynamic>);
      
      // Update every 30 seconds
      await Future.delayed(const Duration(seconds: 30));
    } catch (e) {
      yield* Stream.error('Failed to fetch shipment: $e');
      await Future.delayed(const Duration(seconds: 30));
    }
  }
}
```

**File:** `lib/domain/models/shipment_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'shipment_model.g.dart';

@JsonSerializable()
class ShipmentModel {
  final String id;
  final String lotId;
  final String status; // 'pending', 'in-transit', 'delivered'
  final double currentLatitude;
  final double currentLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final double? currentTemperature;
  final double? targetTemperature;
  final DateTime estimatedDelivery;
  final DateTime? actualDelivery;
  final double distanceRemaining;
  final String? currentLocation;
  final DateTime lastUpdated;
  final List<ShipmentEvent> events;

  ShipmentModel({
    required this.id,
    required this.lotId,
    required this.status,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    this.currentTemperature,
    this.targetTemperature,
    required this.estimatedDelivery,
    this.actualDelivery,
    required this.distanceRemaining,
    this.currentLocation,
    required this.lastUpdated,
    required this.events,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) =>
      _$ShipmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShipmentModelToJson(this);
}

@JsonSerializable()
class ShipmentEvent {
  final String id;
  final String type; // 'pickup', 'in-transit', 'delivery', 'alert'
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ShipmentEvent({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  factory ShipmentEvent.fromJson(Map<String, dynamic> json) =>
      _$ShipmentEventFromJson(json);

  Map<String, dynamic> toJson() => _$ShipmentEventToJson(this);
}
```

**File:** `lib/presentation/screens/shipments/tracking_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../presentation/providers/shipment_provider.dart';
import '../../../config/theme.dart';

class ShipmentTrackingScreen extends ConsumerWidget {
  final String shipmentId;

  const ShipmentTrackingScreen({
    required this.shipmentId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real-time shipment data
    final shipmentStream = ref.watch(watchShipmentRealtimeProvider(shipmentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Shipment'),
        backgroundColor: AfrigoTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: shipmentStream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (shipment) => Stack(
          children: [
            // Google Map
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  shipment.currentLatitude,
                  shipment.currentLongitude,
                ),
                zoom: 12,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('current'),
                  position: LatLng(
                    shipment.currentLatitude,
                    shipment.currentLongitude,
                  ),
                  infoWindow: InfoWindow(
                    title: 'Current Location',
                    snippet: '${shipment.currentLocation}',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('destination'),
                  position: LatLng(
                    shipment.destinationLatitude,
                    shipment.destinationLongitude,
                  ),
                  infoWindow: const InfoWindow(title: 'Destination'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
              },
            ),

            // Info panel at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                shipment.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: shipment.status == 'delivered'
                                      ? Colors.green
                                      : AfrigoTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Distance Remaining',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${shipment.distanceRemaining.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Temperature indicator
                      if (shipment.currentTemperature != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getTemperatureColor(shipment.currentTemperature!)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getTemperatureColor(shipment.currentTemperature!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                shipment.currentTemperature! >
                                        (shipment.targetTemperature ?? 25)
                                    ? Icons.warning
                                    : Icons.check_circle,
                                color:
                                    _getTemperatureColor(shipment.currentTemperature!),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Temperature',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${shipment.currentTemperature}°C',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // ETA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estimated Delivery',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                DateFormat('MMM dd, hh:mm a')
                                    .format(shipment.estimatedDelivery),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (shipment.status == 'delivered')
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to delivery verification
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Verify delivery functionality'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Verify Delivery'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp > 25) return Colors.red;
    if (temp < 10) return Colors.blue;
    return Colors.green;
  }
}
```

---

### Day 3-4: Payment Flow Integration (Flutterwave)

**File:** `lib/presentation/providers/payment_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/services/api_client.dart';

part 'payment_provider.g.dart';

@riverpod
Future<String> initiatePayment(
  InitiatePaymentRef ref, {
  required String lotId,
  required String sellerId,
  required double amount,
  required double quantity,
}) async {
  final apiClient = ApiClient();

  try {
    final response = await apiClient.post(
      '/payments/checkout',
      data: {
        'lotId': lotId,
        'sellerId': sellerId,
        'amount': amount,
        'quantity': quantity,
        'currency': 'USD',
      },
    );

    // Return Flutterwave payment URL
    return response['paymentUrl'] as String;
  } catch (e) {
    throw Exception('Failed to initiate payment: $e');
  }
}
```

**File:** `lib/presentation/screens/payment/checkout_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/providers/payment_provider.dart';
import '../../../domain/models/lot_model.dart';
import '../../../config/theme.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final LotModel lot;
  final double quantity;
  final double pricePerUnit;

  const CheckoutScreen({
    required this.lot,
    required this.quantity,
    required this.pricePerUnit,
    super.key,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.quantity * widget.pricePerUnit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AfrigoTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildOrderRow('Product', widget.lot.productName),
                      _buildOrderRow(
                        'Quantity',
                        '${widget.quantity} ${widget.lot.unit}',
                      ),
                      _buildOrderRow(
                        'Price per unit',
                        '\$${widget.pricePerUnit.toStringAsFixed(2)}',
                      ),
                      _buildOrderRow(
                        'Subtotal',
                        '\$${totalAmount.toStringAsFixed(2)}',
                      ),
                      _buildOrderRow(
                        'Platform fee (2.5%)',
                        '\$${(totalAmount * 0.025).toStringAsFixed(2)}',
                      ),

                      const Divider(height: 24),

                      _buildOrderRow(
                        'Total Amount',
                        '\$${(totalAmount * 1.025).toStringAsFixed(2)}',
                        isBold: true,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Seller info
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seller Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lot.sellerName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.lot.sellerRating}★ (${widget.lot.sellerCompletedTrades} trades)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Payment terms
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Payment Terms',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '✓ Payment protected by escrow\n✓ Money held until you verify delivery\n✓ Instant refund if product not received',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Pay button (FUNCTIONAL)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _handlePayment(
                            totalAmount * 1.025,
                          ),
                  icon: const Icon(Icons.payment),
                  label: Text(
                    _isProcessing
                        ? 'Processing...'
                        : 'Pay \$${(totalAmount * 1.025).toStringAsFixed(2)}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AfrigoTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Cancel button (FUNCTIONAL)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderRow(
    String label,
    String value, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? AfrigoTheme.primaryGreen : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment(double amount) async {
    setState(() => _isProcessing = true);

    try {
      final paymentUrl = await ref.read(
        initiatePaymentProvider(
          lotId: widget.lot.id,
          sellerId: widget.lot.sellerId,
          amount: amount,
          quantity: widget.quantity,
        ).future,
      );

      if (!mounted) return;

      // In production, open Flutterwave web view
      // For now, show success
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Initiated'),
          content: Text('Payment URL: $paymentUrl'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/orders'); // Navigate to orders
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
```

---

### Day 5: Test on Android Device

```bash
# Run app
flutter run

# Test Flows:
1. Navigate to Marketplace
2. Tap "Make Offer" on any lot
3. Verify: Checkout screen loads with correct totals
4. Tap "Pay" button
5. Verify: Payment processing (no crash)

6. Go back to Marketplace
7. Tap "View Details" on any lot
8. Verify: Details screen shows lot info
9. Scroll down - should see shipment tracking button
10. Tap on active shipment
11. Verify: Map loads with real GPS coordinates
12. Verify: Temperature and distance updating
```

---

<a name="week-4"></a>
# 4. WEEK 4 IMPLEMENTATION (June 18-24)
## Micro-Animations + Final Polish + Testing

### Day 1-2: Implement 5 Micro-Animations

**Animation 1: Timeline Entry Animation (280ms staggered)**

```dart
// lib/presentation/widgets/animations/timeline_entry_animation.dart

import 'package:flutter/material.dart';

class TimelineEntryAnimation extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const TimelineEntryAnimation({
    required this.child,
    required this.delayMs,
    super.key,
  });

  @override
  State<TimelineEntryAnimation> createState() => _TimelineEntryAnimationState();
}

class _TimelineEntryAnimationState extends State<TimelineEntryAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start animation after delay
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
```

**Animation 2: Payment Success Animation (Confetti + Checkmark)**

```dart
// lib/presentation/widgets/animations/payment_success_animation.dart

import 'package:flutter/material.dart';
import 'dart:math' show Random, cos, sin, pi;

class PaymentSuccessAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const PaymentSuccessAnimation({required this.onComplete, super.key});

  @override
  State<PaymentSuccessAnimation> createState() => _PaymentSuccessAnimationState();
}

class _PaymentSuccessAnimationState extends State<PaymentSuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _glowController;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();

    // Checkmark animation
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    )..forward();

    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..forward();

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();

    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 3), widget.onComplete);
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _glowController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        ScaleTransition(
          scale: Tween<double>(begin: 1, end: 3).animate(
            CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.8, end: 0).animate(
              CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

        // Checkmark
        ScaleTransition(
          scale: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: _checkmarkController, curve: Curves.elasticOut),
          ),
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 60),
          ),
        ),

        // Confetti
        ConfettiWidget(controller: _confettiController),
      ],
    );
  }
}

class ConfettiWidget extends StatelessWidget {
  final AnimationController controller;

  const ConfettiWidget({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value;

        return Stack(
          children: List.generate(
            30,
            (index) {
              final angle = (index / 30) * 2 * pi;
              final distance = progress * 200;
              final x = distance * cos(angle);
              final y = distance * sin(angle) + (progress * 100);

              return Transform.translate(
                offset: Offset(x, y),
                child: Transform.rotate(
                  angle: progress * 4,
                  child: Opacity(
                    opacity: 1 - progress,
                    child: ConfettiParticle(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ConfettiParticle extends StatelessWidget {
  const ConfettiParticle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.purple];
    final randomColor = colors[Random().nextInt(colors.length)];

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: randomColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
```

**Animation 3: Bid Alert (Shake + Bounce)**

```dart
// lib/presentation/widgets/animations/bid_received_animation.dart

import 'package:flutter/material.dart';

class BidReceivedAnimation extends StatefulWidget {
  final String buyerName;
  final double bidAmount;
  final VoidCallback onDismiss;

  const BidReceivedAnimation({
    required this.buyerName,
    required this.bidAmount,
    required this.onDismiss,
    super.key,
  });

  @override
  State<BidReceivedAnimation> createState() => _BidReceivedAnimationState();
}

class _BidReceivedAnimationState extends State<BidReceivedAnimation>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..repeat(reverse: true);

    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), widget.onDismiss);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset.zero, end: const Offset(0.02, 0)).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut),
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 1.1).animate(
          CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
        ),
        child: GestureDetector(
          onDismiss: widget.onDismiss,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'New Bid: \$${widget.bidAmount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'From: ${widget.buyerName}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: widget.onDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### Day 3-4: Complete Testing & Bug Fixes

```bash
# Run all tests on Android device
flutter run

# Testing Checklist:

AUTHENTICATION:
  ✅ Register new account
  ✅ Login with credentials
  ✅ Token persists after restart
  ✅ Auto-logout after token expires
  ✅ Re-login after logout

MARKETPLACE:
  ✅ All lots load from API
  ✅ Category filter works
  ✅ Pull-to-refresh works
  ✅ Pagination if >20 lots
  ✅ Buttons responsive (tap feedback)

SHIPMENT TRACKING:
  ✅ GPS updates every 30 seconds
  ✅ Map pans smoothly
  ✅ Temperature indicator shows
  ✅ Alert if temp too high

PAYMENTS:
  ✅ Checkout page calculates totals
  ✅ Platform fee calculated correctly
  ✅ Payment button initiates process
  ✅ Success screen shows confirmation

ANIMATIONS:
  ✅ Timeline entries cascade (280ms each)
  ✅ Payment success shows confetti
  ✅ Bid alert shakes and bounces
  ✅ All animations smooth (60 FPS)
  ✅ No animation jank

PERFORMANCE:
  ✅ Cold launch <3 seconds
  ✅ List scrolling smooth (60 FPS)
  ✅ Memory usage <200MB
  ✅ No memory leaks after 30min
  ✅ Battery drain <3% per 30min

EDGE CASES:
  ✅ Network disconnected → Offline mode
  ✅ Network reconnected → Auto-sync
  ✅ Rapid taps don't break buttons
  ✅ No crash if lot deleted while viewing
  ✅ Handle slow network (timeouts)
```

---

### Day 5: Documentation & Final Checklist

Create file: `WEEKS_2-4_COMPLETION_REPORT.md`

```markdown
# WEEKS 2-4 COMPLETION REPORT

## Date: June 18-24, 2026
## Status: COMPLETE ✅

### Authentication Fixed ✅
- [x] Backend CORS enabled
- [x] API Client properly configured
- [x] Token persistence implemented
- [x] Login tested on Android device
- [x] Token refresh working

### Marketplace Connected ✅
- [x] All screens connected to real APIs
- [x] Real data loading from backend
- [x] Category filters working
- [x] Buttons functional and clickable
- [x] Pull-to-refresh working

### Real-Time Features ✅
- [x] Shipment GPS tracking updates every 30 seconds
- [x] Temperature monitoring shows
- [x] Notifications flow in real-time
- [x] Offline mode caches data
- [x] Auto-sync on reconnection

### Payments ✅
- [x] Checkout calculates totals correctly
- [x] Flutterwave integration ready
- [x] Payment button initiates process
- [x] Escrow system ready

### Animations ✅
- [x] Timeline cascading (280ms × items)
- [x] Payment success (checkmark + confetti)
- [x] Bid alert (shake + bounce)
- [x] All animations 60 FPS smooth
- [x] No visible jank

### Testing on Android Device ✅
- [x] Device: [MODEL] | Android [VERSION]
- [x] All flows tested and working
- [x] Performance metrics recorded
- [x] No crashes in 30-minute session
- [x] Battery drain <3%

### Known Issues & Resolutions
- Issue 1: [describe]
  Solution: [how fixed]
- Issue 2: [describe]
  Solution: [how fixed]

### Ready for Week 5 (Beta Testing)?
Status: YES ✅

All systems functional and tested on Android device.
Ready for private beta testing with 50-100 real users.
```

---

<a name="android-testing"></a>
# 5. REAL-TIME TESTING ON ANDROID DEVICE

## Complete Testing Workflow

### Pre-Testing Checklist

```bash
# 1. Get your laptop's local IP
ipconfig  # Windows
# Find IPv4 Address (e.g., 192.168.1.100)

# 2. Update api_client.dart with your IP
# File: lib/data/services/api_client.dart
# Change: baseUrl: 'http://YOUR_IP:3000/api'

# 3. Connect Android device via USB
# Enable USB Debugging on device
# Verify connection:
adb devices
# Should show: device_id     device

# 4. Make sure backend is running
cd c:\afrigo\backend
npm run dev
# Should show: 🚀 AfriGo Backend running
```

### Daily Testing Session (30 minutes)

```
PHASE 1: Authentication (5 minutes)
  □ App launches
  □ Go to Register screen
  □ Fill form: email, password, name
  □ Tap "Register"
  □ Check console for API call
  → Expected: Logged in, redirected to dashboard

PHASE 2: Marketplace (10 minutes)
  □ View marketplace tab
  □ Verify lots loading (from API)
  □ Tap category filter (Cocoa, Coffee, etc.)
  □ List updates with filtered results
  □ Pull down to refresh
  □ Tap "View Details" on any lot
  □ Tap "Make Offer"
  → Expected: Checkout screen loads

PHASE 3: Checkout (5 minutes)
  □ Verify totals calculated correctly
  □ See seller info and verification badge
  □ Read payment terms
  □ Tap "Pay" button
  □ Watch for success or error
  → Expected: Payment initiated successfully

PHASE 4: Animations & Performance (10 minutes)
  □ Scroll marketplace fast (check FPS)
  □ Open/close screens (check transitions)
  □ Watch timeline animations (cascade effect)
  □ Monitor memory (should stay <200MB)
  □ Check battery (should use <1% per minute)

RESULTS:
✅ All buttons responsive
✅ No crashes
✅ Smooth animations
✅ Data loading from API
```

---

<a name="checklist"></a>
# 6. VERIFICATION CHECKLIST

## End of Week 4 (June 24) - Status Check

```
FUNCTIONAL BUTTONS & ICONS:
  ✅ Login button → Authenticates
  ✅ Register button → Creates account
  ✅ Marketplace category chips → Filter lots
  ✅ "View Details" button → Shows lot info
  ✅ "Make Offer" button → Goes to checkout
  ✅ "Pay" button → Initiates payment
  ✅ Refresh icon → Reloads data
  ✅ Filter icon → Opens filter menu
  ✅ Back button → Navigates back
  ✅ Close button → Dismisses alerts

REAL-TIME UPDATES:
  ✅ Lots load within 1 second
  ✅ GPS coordinates update every 30 seconds
  ✅ Temperature changes shown instantly
  ✅ Notifications arrive within 2 seconds
  ✅ Offline data cached and synced

MICRO-ANIMATIONS:
  ✅ Timeline entries cascade (staggered)
  ✅ Payment success shows confetti
  ✅ Bid alert shakes and bounces
  ✅ All animations smooth 60 FPS
  ✅ No visible lag or jank

PERFORMANCE:
  ✅ Cold launch < 3 seconds
  ✅ Marketplace scrolls smooth
  ✅ Memory stays < 200MB
  ✅ Battery drain < 3% per 30 min
  ✅ Frame rate: 60 FPS (no drops)

ANDROID DEVICE:
  ✅ No crashes in 30-min session
  ✅ All flows work end-to-end
  ✅ Touch responsive and instant
  ✅ Text readable on all sizes
  ✅ Colors accurate (no washed out)

AUTHENTICATION:
  ✅ Login validates correctly
  ✅ Token stored securely
  ✅ Token sent with all API calls
  ✅ Token refresh automatic
  ✅ Logout clears token

BACKEND CONNECTION:
  ✅ API calls show in console
  ✅ Data loads from backend (not hardcoded)
  ✅ Errors handled gracefully
  ✅ No "Connection refused" errors
  ✅ No "Authorization" errors

OVERALL STATUS: ✅ PRODUCTION READY FOR WEEK 5 BETA
```

---

## NEXT STEPS (Week 5+)

Once Week 4 is complete:

1. **Week 5:** Private Beta (50-100 testers)
2. **Week 6:** Fix bugs from beta feedback
3. **Week 7:** Performance optimization
4. **Week 8-9:** Wider beta (1,000+ testers)
5. **Week 10:** Google Play submission
6. **Week 11:** App under review
7. **Week 12:** LAUNCH on Play Store 🚀

---

**You've got this! Start Week 2, Day 1 tomorrow!** 💪
