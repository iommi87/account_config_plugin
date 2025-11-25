class AccountModel {
  final int id;
  final String name;
  final String passCode;
  final String shortInitial;

  AccountModel({required this.id, required this.name, required this.passCode, required this.shortInitial});

  factory AccountModel.fromMap(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as int,
      name: json['name'] as String,
      passCode: json['pass_code'] as String,
      shortInitial: json['short_initial'] as String,
    );
  }
}
