// lib/screens/groom/access_verification_page.dart
import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class AccessVerificationPage extends StatefulWidget {
  final Widget destinationPage;
  final String pageTitle;

  const AccessVerificationPage({
    Key? key,
    required this.destinationPage,
    required this.pageTitle,
  }) : super(key: key);

  @override
  State<AccessVerificationPage> createState() => _AccessVerificationPageState();
}

class _AccessVerificationPageState extends State<AccessVerificationPage> {
  final _passwordController = TextEditingController();
  bool _isVerifying = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyAccess() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'يرجى إدخال كلمة مرور الوصول';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      // Check if user is super admin (they bypass verification)
      final role = await ApiService.getUserRole();
      
      if (role == 'super_admin') {
        // Super admin can access without password
        _navigateToDestination();
        return;
      }

      // Verify access password
      final isValid = await ApiService.validateSpecialPageAccess(
        _passwordController.text,
      );

      if (isValid) {
        _navigateToDestination();
      } else {
        setState(() {
          _errorMessage = 'كلمة مرور الوصول غير صحيحة';
          _isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isVerifying = false;
      });
    }
  }

  void _navigateToDestination() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => widget.destinationPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق من الوصول'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lock Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'صفحة محمية',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    widget.pageTitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'يتطلب الوصول إلى هذه الصفحة كلمة مرور خاصة',
                            style: TextStyle(color: Colors.blue, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Password Input
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة مرور الوصول',
                      hintText: 'أدخل كلمة مرور الوصول',
                      prefixIcon: const Icon(Icons.key),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: _errorMessage,
                    ),
                    onSubmitted: (_) => _verifyAccess(),
                  ),

                  const SizedBox(height: 24),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyAccess,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'تحقق والدخول',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Help Text
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('المساعدة'),
                          content: const Text(
                            'كلمة مرور الوصول هي كلمة مرور خاصة يتم توفيرها من قبل مدير العشيرة.\n\n'
                            'إذا لم تكن لديك كلمة المرور، يرجى الاتصال بمدير العشيرة.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('فهمت'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.help_outline, size: 18),
                    label: const Text('لا أملك كلمة المرور؟'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper Widget: Protected Page Wrapper
class ProtectedPage extends StatelessWidget {
  final Widget child;
  final String pageTitle;

  const ProtectedPage({
    Key? key,
    required this.child,
    required this.pageTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AccessVerificationPage(
      destinationPage: child,
      pageTitle: pageTitle,
    );
  }
}

// Extension for easy navigation to protected pages
extension ProtectedNavigation on BuildContext {
  Future<void> navigateToProtectedPage({
    required Widget page,
    required String title,
  }) async {
    await Navigator.push(
      this,
      MaterialPageRoute(
        builder: (context) => AccessVerificationPage(
          destinationPage: page,
          pageTitle: title,
        ),
      ),
    );
  }
}