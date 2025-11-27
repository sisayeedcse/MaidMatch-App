import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String customerId;
  final String providerId;
  final String serviceType;
  final DateTime date;
  final String timeSlot;
  final String duration;
  final int totalPrice;
  final String address;
  final String specialInstructions;
  final String
  status; // 'pending', 'accepted', 'active', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Customer info (denormalized for faster queries)
  final String customerName;
  final String customerPhone;

  // Provider info (denormalized for faster queries)
  final String providerName;
  final String providerPhone;
  final String providerSkill;

  // Timestamps for status changes
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  const BookingModel({
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.serviceType,
    required this.date,
    required this.timeSlot,
    required this.duration,
    required this.totalPrice,
    required this.address,
    this.specialInstructions = '',
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.customerName,
    required this.customerPhone,
    required this.providerName,
    required this.providerPhone,
    required this.providerSkill,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  // Factory constructor from Firestore document
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      bookingId: doc.id,
      customerId: data['customerId'] ?? '',
      providerId: data['providerId'] ?? '',
      serviceType: data['serviceType'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      duration: data['duration'] ?? '',
      totalPrice: data['totalPrice'] ?? 0,
      address: data['address'] ?? '',
      specialInstructions: data['specialInstructions'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      providerName: data['providerName'] ?? '',
      providerPhone: data['providerPhone'] ?? '',
      providerSkill: data['providerSkill'] ?? '',
      acceptedAt: data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
      startedAt: data['startedAt'] != null
          ? (data['startedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      cancelledAt: data['cancelledAt'] != null
          ? (data['cancelledAt'] as Timestamp).toDate()
          : null,
      cancellationReason: data['cancellationReason'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> data = {
      'customerId': customerId,
      'providerId': providerId,
      'serviceType': serviceType,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'duration': duration,
      'totalPrice': totalPrice,
      'address': address,
      'specialInstructions': specialInstructions,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'providerName': providerName,
      'providerPhone': providerPhone,
      'providerSkill': providerSkill,
    };

    if (updatedAt != null) data['updatedAt'] = Timestamp.fromDate(updatedAt!);
    if (acceptedAt != null)
      data['acceptedAt'] = Timestamp.fromDate(acceptedAt!);
    if (startedAt != null) data['startedAt'] = Timestamp.fromDate(startedAt!);
    if (completedAt != null) {
      data['completedAt'] = Timestamp.fromDate(completedAt!);
    }
    if (cancelledAt != null) {
      data['cancelledAt'] = Timestamp.fromDate(cancelledAt!);
    }
    if (cancellationReason != null) {
      data['cancellationReason'] = cancellationReason;
    }

    return data;
  }

  // CopyWith method for immutable updates
  BookingModel copyWith({
    String? bookingId,
    String? customerId,
    String? providerId,
    String? serviceType,
    DateTime? date,
    String? timeSlot,
    String? duration,
    int? totalPrice,
    String? address,
    String? specialInstructions,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerName,
    String? customerPhone,
    String? providerName,
    String? providerPhone,
    String? providerSkill,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      serviceType: serviceType ?? this.serviceType,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      duration: duration ?? this.duration,
      totalPrice: totalPrice ?? this.totalPrice,
      address: address ?? this.address,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      providerName: providerName ?? this.providerName,
      providerPhone: providerPhone ?? this.providerPhone,
      providerSkill: providerSkill ?? this.providerSkill,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  // Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final bookingDate = DateTime(date.year, date.month, date.day);

    if (bookingDate == today) {
      return 'Today';
    } else if (bookingDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FBBF24'; // Yellow
      case 'accepted':
      case 'active':
        return '#10B981'; // Green
      case 'completed':
        return '#6366F1'; // Indigo
      case 'cancelled':
        return '#EF4444'; // Red
      default:
        return '#6B7280'; // Gray
    }
  }

  // Get status display text
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}
