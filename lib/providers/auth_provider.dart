import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Pengaturan Operasional Toko & Kasir (POS Preferences)
  bool _enableTaxPpn = false;
  bool _printStoreHeaderOnReceipt = true;
  bool _enableLowStockAlert = true;
  bool _enablePosSoundEffects = true;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDemoMode => _authService.isDemoMode;

  bool get enableTaxPpn => _enableTaxPpn;
  bool get printStoreHeaderOnReceipt => _printStoreHeaderOnReceipt;
  bool get enableLowStockAlert => _enableLowStockAlert;
  bool get enablePosSoundEffects => _enablePosSoundEffects;

  void toggleTaxPpn(bool value) {
    _enableTaxPpn = value;
    notifyListeners();
  }

  void togglePrintStoreHeader(bool value) {
    _printStoreHeaderOnReceipt = value;
    notifyListeners();
  }

  void toggleLowStockAlert(bool value) {
    _enableLowStockAlert = value;
    notifyListeners();
  }

  void togglePosSoundEffects(bool value) {
    _enablePosSoundEffects = value;
    notifyListeners();
  }

  Future<void> checkExistingSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authService.signIn(
        emailOrUsername: emailOrUsername,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String storeName,
    required String storeAddress,
    required String bio,
    required String role,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = _currentUser!.copyWith(
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        storeName: storeName.trim(),
        storeAddress: storeAddress.trim(),
        bio: bio.trim(),
        role: role.trim().toLowerCase(),
        avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
      );
      _currentUser = await _authService.updateProfile(updated);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAvatarUrl(String newAvatarUrl) async {
    if (_currentUser == null) return false;
    try {
      final updated = _currentUser!.copyWith(avatarUrl: newAvatarUrl);
      _currentUser = await _authService.updateProfile(updated);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    String role = 'admin',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authService.signUp(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
