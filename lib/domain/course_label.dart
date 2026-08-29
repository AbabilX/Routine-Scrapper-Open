class CourseLabel {
  static String format({
    required String code,
    required String group,
    String? name,
  }) {
    final tagged = '$code($group)';
    if (name == null || name.trim().isEmpty) return tagged;
    return '${name.trim()} - $tagged';
  }
}
