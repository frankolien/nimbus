import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final bool isNew;
  final String? newTag;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    this.isNew = false,
    this.newTag,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconPath,
        isNew,
        newTag,
      ];
}
