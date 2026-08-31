class TeacherInfo {
  const TeacherInfo({
    required this.initial,
    required this.name,
    this.designation = '',
    this.id = '',
    this.cell = '',
    this.email = '',
    this.room = '',
    this.imageUrl = '',
  });

  final String initial;
  final String name;
  final String designation;
  final String id;
  final String cell;
  final String email;
  final String room;
  final String imageUrl;

  String get titleWithInitial {
    if (initial.isEmpty) return name;
    if (name.isEmpty) return initial;
    if (name.toUpperCase().contains('($initial)') ||
        name.toUpperCase().endsWith(' $initial')) {
      return name;
    }
    return '$name ($initial)';
  }

  factory TeacherInfo.fromJson(
    Map<String, dynamic> json, [
    String? fallbackInitial,
  ]) {
    final rawNameInitial =
        json['Name_Initial'] ??
        json['name_initial'] ??
        json['Name'] ??
        json['name'] ??
        json['teacher_name'] ??
        '';

    String parsedInitial = '';
    String parsedName = '$rawNameInitial'.trim();

    if (parsedName.isNotEmpty) {
      final parenMatch = RegExp(r'\(([A-Za-z0-9_-]+)\)').firstMatch(parsedName);
      if (parenMatch != null) {
        parsedInitial = parenMatch.group(1)!.trim().toUpperCase();
        parsedName = parsedName
            .replaceAll(RegExp(r'\s*\([A-Za-z0-9_-]+\)\s*'), '')
            .trim();
      }
    }

    final rawInitial =
        json['Initial'] ??
        json['initial'] ??
        json['initials'] ??
        json['teacher_initial'] ??
        (parsedInitial.isNotEmpty ? parsedInitial : (fallbackInitial ?? ''));

    if (parsedName.isEmpty) {
      parsedName = '$rawInitial'.trim();
    }

    final rawDesig =
        json['Designation'] ??
        json['designation'] ??
        json['Desig'] ??
        json['desig'] ??
        json['designation_name'] ??
        '';

    final rawId =
        json['Employee ID'] ??
        json['Employee_ID'] ??
        json['EmployeeId'] ??
        json['ID'] ??
        json['id'] ??
        json['teacher_id'] ??
        json['employee_id'] ??
        '';

    final rawCell =
        json['Cell'] ??
        json['cell'] ??
        json['Phone'] ??
        json['phone'] ??
        json['Mobile'] ??
        json['mobile'] ??
        json['Contact'] ??
        '';

    final rawEmail =
        json['Email'] ?? json['email'] ?? json['Mail'] ?? json['mail'] ?? '';

    final rawRoom =
        json['Assigned Room Number'] ??
        json['Assigned_Room_Number'] ??
        json['Room'] ??
        json['room'] ??
        json['room_number'] ??
        '';

    final rawImage =
        json['Image'] ??
        json['image'] ??
        json['Image_Url'] ??
        json['image_url'] ??
        json['Photo'] ??
        json['photo'] ??
        json['Avatar'] ??
        json['avatar'] ??
        '';

    return TeacherInfo(
      initial: '$rawInitial'.trim().toUpperCase(),
      name: parsedName,
      designation: '$rawDesig'.trim(),
      id: '$rawId'.trim(),
      cell: '$rawCell'.trim(),
      email: '$rawEmail'.trim(),
      room: '$rawRoom'.trim(),
      imageUrl: '$rawImage'.trim(),
    );
  }

  Map<String, dynamic> toJson() => {
    'initial': initial,
    'name': name,
    'designation': designation,
    'id': id,
    'cell': cell,
    'email': email,
    'room': room,
    'image_url': imageUrl,
  };
}
