import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminBookingGuard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onAdminDetected;

  const AdminBookingGuard({
    Key? key,
    required this.child,
    this.onAdminDetected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is admin
    if (authProvider.isAdmin) {
      // If there's a custom handler, call it
      if (onAdminDetected != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onAdminDetected!();
        });
      } else {
        // Default behavior: show a snackbar and go back
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin tidak dapat melakukan pemesanan'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.of(context).pop();
        });
      }
      
      // Return an empty container or loading indicator
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // If not admin, render the child widget
    return child;
  }
}
