import 'package:equatable/equatable.dart';

class Drawing extends Equatable {
  final String id;
  final String fileName;
  final String customer;
  final String storagePath;
  final String? signedUrl;
  final DateTime? urlExpiresAt;
  final String fileType;
  final int? fileSize;
  final String rev;
  final String? uploadedBy;
  final DateTime? createdAt;

  const Drawing({
    required this.id,
    required this.fileName,
    required this.customer,
    required this.storagePath,
    this.signedUrl,
    this.urlExpiresAt,
    required this.fileType,
    this.fileSize,
    required this.rev,
    this.uploadedBy,
    this.createdAt,
  });

  String get extension => fileName.contains('.')
      ? fileName.split('.').last.toUpperCase()
      : fileType.toUpperCase();

  String get formattedSize {
    if (fileSize == null) return '';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  factory Drawing.fromJson(Map<String, dynamic> json) => Drawing(
        id: json['id'] as String,
        fileName: json['file_name'] as String,
        customer: (json['customer'] as String?) ?? '',
        storagePath: json['storage_path'] as String,
        signedUrl: json['signed_url'] as String?,
        urlExpiresAt: json['url_expires_at'] != null
            ? DateTime.tryParse(json['url_expires_at'] as String)
            : null,
        fileType: json['file_type'] as String,
        fileSize: json['file_size'] as int?,
        rev: (json['rev'] as String?) ?? 'rev 1',
        uploadedBy: json['uploaded_by'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'file_name': fileName,
        'customer': customer,
        'storage_path': storagePath,
        'signed_url': signedUrl,
        'url_expires_at': urlExpiresAt?.toIso8601String(),
        'file_type': fileType,
        'file_size': fileSize,
        'rev': rev,
        'uploaded_by': uploadedBy,
        'created_at': createdAt?.toIso8601String(),
      };

  Drawing copyWith({
    String? id,
    String? fileName,
    String? customer,
    String? storagePath,
    String? signedUrl,
    DateTime? urlExpiresAt,
    String? fileType,
    int? fileSize,
    String? rev,
    String? uploadedBy,
    DateTime? createdAt,
  }) =>
      Drawing(
        id: id ?? this.id,
        fileName: fileName ?? this.fileName,
        customer: customer ?? this.customer,
        storagePath: storagePath ?? this.storagePath,
        signedUrl: signedUrl ?? this.signedUrl,
        urlExpiresAt: urlExpiresAt ?? this.urlExpiresAt,
        fileType: fileType ?? this.fileType,
        fileSize: fileSize ?? this.fileSize,
        rev: rev ?? this.rev,
        uploadedBy: uploadedBy ?? this.uploadedBy,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        fileName,
        customer,
        storagePath,
        signedUrl,
        urlExpiresAt,
        fileType,
        fileSize,
        rev,
        uploadedBy,
        createdAt,
      ];
}
