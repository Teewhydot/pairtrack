import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );
  GoogleSignInAccount? _user;
  String? _errorMessage;
  String? _userName;
  String? _userEmail;
  String? _userPhotoUrl;
  String? _userID;
  bool showLoading = false;

  void startLoading() {
    showLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    showLoading = false;
    notifyListeners();
  }

  GoogleSignInAccount get user => _user!;
  String? get errorMessage => _errorMessage;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhotoUrl => _userPhotoUrl;
  String? get userID => _userID;

  GoogleSignInService() {
    _loadUserDetails();
  }
  Future<void> signInSilently() async {
    try {
      showLoading = true;
      notifyListeners();
      _user = await _googleSignIn.signInSilently();
      showLoading = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      showLoading = false;
      notifyListeners();
    }
  }
  void renderButton() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _user = account;
      notifyListeners();
    });
    _googleSignIn.signInSilently();
  }

  Future<void> signInWithGoogle() async {
    try {
      startLoading();
      _user = await _googleSignIn.signIn();
      if (_user == null) return;
      final GoogleSignInAuthentication googleAuth = await _user!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .whenComplete(() async {
        _userName = _user?.displayName;
        _userEmail = _user?.email;
        _userPhotoUrl = _user?.photoUrl;
        _userID = FirebaseAuth.instance.currentUser!.uid;
        _errorMessage = null;
        await _saveUserDetails();
        stopLoading();
        notifyListeners();
      });
    } catch (error) {
      _errorMessage = error.toString();
      stopLoading();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut().whenComplete(() async {
      await FirebaseAuth.instance.signOut().whenComplete(() async {
        _user = null;
        _userName = null;
        _userEmail = null;
        _userPhotoUrl = null;
        _errorMessage = null;
        _userID = null;
        await _clearUserDetails();
        notifyListeners();
      });
    });
  }

  bool isUserSignedIn() {
    return _userName!.isNotEmpty && _userEmail!.isNotEmpty;
  }

  Future<void> _saveUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName ?? '');
    await prefs.setString('userEmail', _userEmail ?? '');
    await prefs.setString('userPhotoUrl', _userPhotoUrl ?? '');
    await prefs.setString('userID', _userID ?? '');
  }

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    _userPhotoUrl = prefs.getString('userPhotoUrl');
    _userID = prefs.getString('userID');
    notifyListeners();
  }

  Future<void> _clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userPhotoUrl');
    await prefs.remove('userID');
  }
}
