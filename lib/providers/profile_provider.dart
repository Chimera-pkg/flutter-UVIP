import 'package:flutter/material.dart';

class ProfileProvider with ChangeNotifier {
  // Mock Data
  String _name = "Herry Tan";
  String _role = "Admin";
  String _phone = "+629298298398";
  String _email = "herrytan@gmail.com";
  String _address = "Jalan Ijen Malang";

  // Getters
  String get name => _name;
  String get role => _role;
  String get phone => _phone;
  String get email => _email;
  String get address => _address;

  // Setters (if needed later for edit profile)
  void updateProfile({
    String? name,
    String? role,
    String? phone,
    String? email,
    String? address,
  }) {
    if (name != null) _name = name;
    if (role != null) _role = role;
    if (phone != null) _phone = phone;
    if (email != null) _email = email;
    if (address != null) _address = address;
    notifyListeners();
  }
}
