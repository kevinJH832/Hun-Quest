enum TodoType {
  important, //  오늘 꼭 할 일
  normal, //  일반 할 일
  schedule, //  스케줄/약속
  habit, //  습관
}

class TodoItem {
  String title; // 할일 제목
  bool isCompleted; // 완료 여부
  TodoType type; // 할일 타입
  List<int>? habitDays; // 습관용 요일들 (1=월요일, 7=일요일)

  // 생성자
  TodoItem({
    required this.title,
    this.isCompleted = false,
    this.type = TodoType.normal,
    this.habitDays,
  });

  // JSON으로 변환 (저장용)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'type': type.index, // enum을 숫자로 저장
      'habitDays': habitDays,
    };
  }

  // JSON에서 객체로 변환 (불러오기용)
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      type: TodoType.values[json['type'] ?? 0], // 숫자를 enum으로 변환
      habitDays: json['habitDays'] != null
          ? List<int>.from(json['habitDays'])
          : null,
    );
  }
}
