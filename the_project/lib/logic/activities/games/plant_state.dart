class PlantState {
  final int availablePoints;
  final double water;    // 0..1
  final double sunlight; // 0..1
  final int stage;       // 0 = Sprout, then grows

  const PlantState({
    this.availablePoints = 0,
    this.water = 0,
    this.sunlight = 0,
    this.stage = 0,
  });

  String get stageLabel {
    switch (stage) {
      case 0:
        return 'Sprout';
      case 1:
        return 'Growing';
      case 2:
        return 'Blooming';
      default:
        return 'Big tree';
    }
  }

  PlantState copyWith({
    int? availablePoints,
    double? water,
    double? sunlight,
    int? stage,
  }) {
    return PlantState(
      availablePoints: availablePoints ?? this.availablePoints,
      water: water ?? this.water,
      sunlight: sunlight ?? this.sunlight,
      stage: stage ?? this.stage,
    );
  }
}
