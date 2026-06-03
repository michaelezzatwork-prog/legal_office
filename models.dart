// ════════════════════════════════════════
// CASE MODEL
// ════════════════════════════════════════
class CaseModel {
  final String id;
  final String caseNumber;
  final int year;
  final String court;
  final String title;
  final String type; // مدني, عمالية, جنائي, تجاري, إداري
  final String status; // active, closed, suspended
  final String clientId;
  final String clientName;
  final DateTime? nextSession;
  final String? notes;
  final DateTime createdAt;

  CaseModel({
    required this.id,
    required this.caseNumber,
    required this.year,
    required this.court,
    required this.title,
    required this.type,
    this.status = 'active',
    required this.clientId,
    required this.clientName,
    this.nextSession,
    this.notes,
    required this.createdAt,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) => CaseModel(
    id: json['_id'] ?? json['id'] ?? '',
    caseNumber: json['caseNumber'] ?? '',
    year: json['year'] ?? DateTime.now().year,
    court: json['court'] ?? '',
    title: json['title'] ?? '',
    type: json['type'] ?? 'مدني',
    status: json['status'] ?? 'active',
    clientId: json['clientId'] ?? '',
    clientName: json['clientName'] ?? '',
    nextSession: json['nextSession'] != null
        ? DateTime.parse(json['nextSession'])
        : null,
    notes: json['notes'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'caseNumber': caseNumber,
    'year': year,
    'court': court,
    'title': title,
    'type': type,
    'status': status,
    'clientId': clientId,
    'clientName': clientName,
    'nextSession': nextSession?.toIso8601String(),
    'notes': notes,
  };

  Map<String, dynamic> toLocalDb() => {
    'id': id,
    'case_number': caseNumber,
    'year': year,
    'court': court,
    'title': title,
    'type': type,
    'status': status,
    'client_id': clientId,
    'client_name': clientName,
    'next_session': nextSession?.toIso8601String(),
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'synced': 1,
  };

  factory CaseModel.fromLocalDb(Map<String, dynamic> map) => CaseModel(
    id: map['id'],
    caseNumber: map['case_number'],
    year: map['year'],
    court: map['court'],
    title: map['title'],
    type: map['type'],
    status: map['status'],
    clientId: map['client_id'] ?? '',
    clientName: map['client_name'] ?? '',
    nextSession: map['next_session'] != null
        ? DateTime.parse(map['next_session'])
        : null,
    notes: map['notes'],
    createdAt: DateTime.parse(map['created_at']),
  );
}

// ════════════════════════════════════════
// CLIENT MODEL
// ════════════════════════════════════════
class ClientModel {
  final String id;
  final String name;
  final String type; // individual, company, group
  final String? phone;
  final String? email;
  final String? nationalId;
  final String? address;
  final String? notes;
  final String status; // active, inactive
  final DateTime createdAt;

  ClientModel({
    required this.id,
    required this.name,
    this.type = 'individual',
    this.phone,
    this.email,
    this.nationalId,
    this.address,
    this.notes,
    this.status = 'active',
    required this.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
    id: json['_id'] ?? json['id'] ?? '',
    name: json['name'] ?? '',
    type: json['type'] ?? 'individual',
    phone: json['phone'],
    email: json['email'],
    nationalId: json['nationalId'],
    address: json['address'],
    notes: json['notes'],
    status: json['status'] ?? 'active',
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'phone': phone,
    'email': email,
    'nationalId': nationalId,
    'address': address,
    'notes': notes,
    'status': status,
  };
}

// ════════════════════════════════════════
// SESSION MODEL
// ════════════════════════════════════════
class SessionModel {
  final String id;
  final String type; // جلسة محاكمة, استشارة عميل, اجتماع داخلي
  final String title;
  final String? caseId;
  final String? caseTitle;
  final String? clientId;
  final String? clientName;
  final DateTime sessionDate;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? notes;
  final String status; // upcoming, completed, cancelled

  SessionModel({
    required this.id,
    required this.type,
    required this.title,
    this.caseId,
    this.caseTitle,
    this.clientId,
    this.clientName,
    required this.sessionDate,
    this.startTime,
    this.endTime,
    this.location,
    this.notes,
    this.status = 'upcoming',
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    id: json['_id'] ?? json['id'] ?? '',
    type: json['type'] ?? 'جلسة محاكمة',
    title: json['title'] ?? '',
    caseId: json['caseId'],
    caseTitle: json['caseTitle'],
    clientId: json['clientId'],
    clientName: json['clientName'],
    sessionDate: DateTime.parse(json['sessionDate']),
    startTime: json['startTime'],
    endTime: json['endTime'],
    location: json['location'],
    notes: json['notes'],
    status: json['status'] ?? 'upcoming',
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    'caseId': caseId,
    'clientId': clientId,
    'sessionDate': sessionDate.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'location': location,
    'notes': notes,
    'status': status,
  };
}

// ════════════════════════════════════════
// INVOICE MODEL
// ════════════════════════════════════════
class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final String? caseId;
  final double amount;
  final double paidAmount;
  final String status; // pending, partial, paid, cancelled
  final DateTime? dueDate;
  final String? notes;
  final DateTime createdAt;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    this.caseId,
    required this.amount,
    this.paidAmount = 0,
    this.status = 'pending',
    this.dueDate,
    this.notes,
    required this.createdAt,
  });

  double get remainingAmount => amount - paidAmount;
  double get collectionRate => amount > 0 ? (paidAmount / amount) * 100 : 0;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
    id: json['_id'] ?? json['id'] ?? '',
    invoiceNumber: json['invoiceNumber'] ?? '',
    clientId: json['clientId'] ?? '',
    clientName: json['clientName'] ?? '',
    caseId: json['caseId'],
    amount: (json['amount'] ?? 0).toDouble(),
    paidAmount: (json['paidAmount'] ?? 0).toDouble(),
    status: json['status'] ?? 'pending',
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    notes: json['notes'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'caseId': caseId,
    'amount': amount,
    'paidAmount': paidAmount,
    'status': status,
    'dueDate': dueDate?.toIso8601String(),
    'notes': notes,
  };
}

// ════════════════════════════════════════
// DOCUMENT MODEL
// ════════════════════════════════════════
class DocumentModel {
  final String id;
  final String title;
  final String type; // نموذج, مذكرة, تقرير, عقد, توكيل
  final String? filePath;
  final String? caseId;
  final String? clientId;
  final bool isTemplate;
  final String? description;
  final DateTime createdAt;

  DocumentModel({
    required this.id,
    required this.title,
    required this.type,
    this.filePath,
    this.caseId,
    this.clientId,
    this.isTemplate = false,
    this.description,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
    id: json['_id'] ?? json['id'] ?? '',
    title: json['title'] ?? '',
    type: json['type'] ?? 'مستند',
    filePath: json['filePath'],
    caseId: json['caseId'],
    clientId: json['clientId'],
    isTemplate: json['isTemplate'] ?? false,
    description: json['description'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );
}

// ════════════════════════════════════════
// DASHBOARD STATS MODEL
// ════════════════════════════════════════
class DashboardStats {
  final int activeCases;
  final int totalCases;
  final int totalClients;
  final double collectedFees;
  final double pendingFees;
  final double collectionRate;

  DashboardStats({
    required this.activeCases,
    required this.totalCases,
    required this.totalClients,
    required this.collectedFees,
    required this.pendingFees,
    required this.collectionRate,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
    activeCases: json['activeCases'] ?? 0,
    totalCases: json['totalCases'] ?? 0,
    totalClients: json['totalClients'] ?? 0,
    collectedFees: (json['collectedFees'] ?? 0).toDouble(),
    pendingFees: (json['pendingFees'] ?? 0).toDouble(),
    collectionRate: (json['collectionRate'] ?? 0).toDouble(),
  );
}
