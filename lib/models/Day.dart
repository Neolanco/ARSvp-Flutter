// models/Day.dart
class Day {
  final String date;
  final List<SubPlan> subPlans;

  Day({required this.date, required this.subPlans});
}

// models/SubPlan.dart
class SubPlan {
  final String course;
  final String position;
  final String subject;
  final String teacher;
  final String room;
  final String type;
  final String remark;

  SubPlan({
    required this.course,
    required this.position,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.type,
    required this.remark,
  });
}
