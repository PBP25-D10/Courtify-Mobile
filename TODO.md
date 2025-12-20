# TODO: Fix Flutter Linting Issues

## Files to Edit

### 1. lib/module/booking/screens/booking_create_screen.dart
- [x] Fix use_build_context_synchronously in _fetchBookedHours: Add mounted check before ScaffoldMessenger.of(context)
- [x] Fix use_build_context_synchronously in _submitBooking: Add mounted checks before ScaffoldMessenger.of(context) and Navigator.pop

### 2. lib/module/booking/screens/booking_dashboard_screen.dart
- [ ] Remove unused import: 'package:courtify_mobile/module/lapangan/screens/lapangan_form_screen.dart'
- [ ] Fix use_build_context_synchronously in _handleCancelBooking: Add mounted checks before ScaffoldMessenger.of(context)
- [ ] Replace deprecated withOpacity in BoxShadow at lines 229 and 302: Use Colors.grey.withAlpha(25) instead of Colors.grey.withOpacity(0.1)

### 3. lib/module/booking/services/booking_api_service.dart
- [ ] Remove unused import: 'dart:convert'

### 4. lib/module/booking/widgets/booking_card.dart
- [ ] Replace deprecated withOpacity in BoxShadow at line 50: Use Colors.grey.withAlpha(25) instead of Colors.grey.withOpacity(0.1)

### 5. lib/module/lapangan/screens/lapangan_list_screen.dart
- [ ] Remove unused variable 'request' at line 35
- [ ] Fix use_build_context_synchronously in _deleteLapangan: Add mounted checks before Navigator.pop and ScaffoldMessenger.of(context)

### 6. lib/services/auth_service.dart
- [ ] Remove unused import: 'package:http/http.dart'

### 7. lib/widgets/right_drawer.dart
- [ ] Remove unused import: 'package:courtify_mobile/module/booking/screens/booking_create_screen.dart'
