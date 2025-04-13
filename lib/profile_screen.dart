import 'package:flutter/material.dart';
import 'auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isChangingPassword = false;
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  void _changePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });

      try {
        await _authService.changePassword(_newPasswordController.text);
        setState(() {
          _successMessage = 'Password changed successfully!';
          _isChangingPassword = false;
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final email = user?.email ?? 'No email available';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Email: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            email,
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            if (!_isChangingPassword)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isChangingPassword = true;
                    _errorMessage = null;
                    _successMessage = null;
                  });
                },
                icon: Icon(Icons.lock),
                label: Text('Change Password'),
              )
            else
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _passwordFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your new password';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        if (_errorMessage != null)
                          Container(
                            padding: EdgeInsets.all(8),
                            color: Colors.red[100],
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red[900]),
                            ),
                          ),
                        if (_successMessage != null)
                          Container(
                            padding: EdgeInsets.all(8),
                            color: Colors.green[100],
                            child: Text(
                              _successMessage!,
                              style: TextStyle(color: Colors.green[900]),
                            ),
                          ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isChangingPassword = false;
                                  _errorMessage = null;
                                  _successMessage = null;
                                });
                              },
                              child: Text('Cancel'),
                            ),
                            SizedBox(width: 8),
                            _isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: _changePassword,
                                    child: Text('Update Password'),
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
}
