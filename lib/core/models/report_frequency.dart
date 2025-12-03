enum Frequency {
  daily(1, 'يوميًا', "daily" , 1),
  onceAWeek(2, 'أسبوعيًا', "onceAWeek", 7),
  twiceAWeek(3, 'مرتين بالأسبوع', "twiceAWeek" , 3),
  thriceAWeek(4, 'ثلاث مرات بالأسبوع', "thriceAWeek" , 2);

  final int id;
  final String labelAr;
  final String label;
  final int daysCount;
  const Frequency(this.id, this.labelAr, this.label , this.daysCount);

  static Frequency fromId(int id) {
    return Frequency.values.firstWhere((e) => e.id == id, orElse: () => daily);
  }

  static Frequency fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'onceAWeek':
      case 'مرة بالأسبوع':
      case 'أسبوعيًا':
        return Frequency.onceAWeek;
      case 'twiceAWeek':
      case 'مرتين بالأسبوع':
        return Frequency.twiceAWeek;
      case 'thriceAWeek':
      case 'ثلاث مرات بالأسبوع':
        return Frequency.thriceAWeek;
      default:
        return Frequency.daily;
    }
  }
}
