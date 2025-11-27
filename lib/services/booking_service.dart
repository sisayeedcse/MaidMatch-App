import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bookings';

  // Create a new booking
  Future<BookingModel?> createBooking({
    required String customerId,
    required String providerId,
    required String serviceType,
    required DateTime date,
    required String timeSlot,
    required String duration,
    required int totalPrice,
    required String address,
    String specialInstructions = '',
    required String customerName,
    required String customerPhone,
    required String providerName,
    required String providerPhone,
    required String providerSkill,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc();

      final booking = BookingModel(
        bookingId: docRef.id,
        customerId: customerId,
        providerId: providerId,
        serviceType: serviceType,
        date: date,
        timeSlot: timeSlot,
        duration: duration,
        totalPrice: totalPrice,
        address: address,
        specialInstructions: specialInstructions,
        status: 'pending',
        createdAt: DateTime.now(),
        customerName: customerName,
        customerPhone: customerPhone,
        providerName: providerName,
        providerPhone: providerPhone,
        providerSkill: providerSkill,
      );

      await docRef.set(booking.toFirestore());
      return booking;
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  // Get bookings for a specific user (customer or provider)
  Stream<List<BookingModel>> getBookingsStream({
    required String userId,
    required bool isProvider,
    String? status,
  }) {
    try {
      Query query = _firestore.collection(_collection);

      // Filter by user role
      if (isProvider) {
        query = query.where('providerId', isEqualTo: userId);
      } else {
        query = query.where('customerId', isEqualTo: userId);
      }

      // Filter by status if provided
      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      // Order by creation date (newest first)
      query = query.orderBy('createdAt', descending: true);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error getting bookings stream: $e');
      rethrow;
    }
  }

  // Get bookings for customer by status
  Future<List<BookingModel>> getCustomerBookings({
    required String customerId,
    String? status,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('customerId', isEqualTo: customerId);

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting customer bookings: $e');
      rethrow;
    }
  }

  // Get bookings for provider by status
  Future<List<BookingModel>> getProviderBookings({
    required String providerId,
    String? status,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('providerId', isEqualTo: providerId);

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting provider bookings: $e');
      rethrow;
    }
  }

  // Get a single booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting booking by ID: $e');
      rethrow;
    }
  }

  // Update booking status
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
    String? cancellationReason,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add timestamp for status change
      switch (status) {
        case 'accepted':
          updateData['acceptedAt'] = FieldValue.serverTimestamp();
          break;
        case 'active':
          updateData['startedAt'] = FieldValue.serverTimestamp();
          break;
        case 'completed':
          updateData['completedAt'] = FieldValue.serverTimestamp();
          break;
        case 'cancelled':
          updateData['cancelledAt'] = FieldValue.serverTimestamp();
          if (cancellationReason != null) {
            updateData['cancellationReason'] = cancellationReason;
          }
          break;
      }

      await _firestore
          .collection(_collection)
          .doc(bookingId)
          .update(updateData);
    } catch (e) {
      print('Error updating booking status: $e');
      rethrow;
    }
  }

  // Accept booking (provider action)
  Future<void> acceptBooking(String bookingId) async {
    await updateBookingStatus(bookingId: bookingId, status: 'accepted');
  }

  // Decline booking (provider action)
  Future<void> declineBooking(String bookingId, String reason) async {
    await updateBookingStatus(
      bookingId: bookingId,
      status: 'cancelled',
      cancellationReason: reason,
    );
  }

  // Start job (provider action)
  Future<void> startJob(String bookingId) async {
    await updateBookingStatus(bookingId: bookingId, status: 'active');
  }

  // Complete job (provider action)
  Future<void> completeJob(String bookingId) async {
    await updateBookingStatus(bookingId: bookingId, status: 'completed');
  }

  // Cancel booking (customer action)
  Future<void> cancelBooking(String bookingId, String reason) async {
    await updateBookingStatus(
      bookingId: bookingId,
      status: 'cancelled',
      cancellationReason: reason,
    );
  }

  // Get provider statistics
  Future<Map<String, dynamic>> getProviderStats(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('providerId', isEqualTo: providerId)
          .get();

      int totalJobs = 0;
      int completedJobs = 0;
      int totalEarnings = 0;
      int monthEarnings = 0;
      int todayEarnings = 0;

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfDay = DateTime(now.year, now.month, now.day);

      for (var doc in snapshot.docs) {
        final booking = BookingModel.fromFirestore(doc);
        totalJobs++;

        if (booking.isCompleted) {
          completedJobs++;
          totalEarnings += booking.totalPrice;

          if (booking.completedAt != null) {
            if (booking.completedAt!.isAfter(startOfMonth)) {
              monthEarnings += booking.totalPrice;
            }
            if (booking.completedAt!.isAfter(startOfDay)) {
              todayEarnings += booking.totalPrice;
            }
          }
        }
      }

      return {
        'totalJobs': totalJobs,
        'completedJobs': completedJobs,
        'totalEarnings': totalEarnings,
        'monthEarnings': monthEarnings,
        'todayEarnings': todayEarnings,
      };
    } catch (e) {
      print('Error getting provider stats: $e');
      return {
        'totalJobs': 0,
        'completedJobs': 0,
        'totalEarnings': 0,
        'monthEarnings': 0,
        'todayEarnings': 0,
      };
    }
  }

  // Check if provider has conflicting bookings
  Future<bool> hasConflictingBooking({
    required String providerId,
    required DateTime date,
    required String timeSlot,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(_collection)
          .where('providerId', isEqualTo: providerId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', whereIn: ['pending', 'accepted', 'active'])
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking conflicting bookings: $e');
      return false;
    }
  }

  // Delete a booking (admin only - for testing)
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).delete();
    } catch (e) {
      print('Error deleting booking: $e');
      rethrow;
    }
  }

  // Get upcoming bookings count
  Future<int> getUpcomingBookingsCount(String userId, bool isProvider) async {
    try {
      Query query = _firestore.collection(_collection);

      if (isProvider) {
        query = query.where('providerId', isEqualTo: userId);
      } else {
        query = query.where('customerId', isEqualTo: userId);
      }

      query = query.where('status', whereIn: ['pending', 'accepted', 'active']);

      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting upcoming bookings count: $e');
      return 0;
    }
  }
}
