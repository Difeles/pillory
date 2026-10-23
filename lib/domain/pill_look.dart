/// The silhouette of a pill.
enum PillShape { round, oval, caplet, capsule, square }

/// The score on a tablet: none, one groove, or a cross. A capsule has none.
enum PillScore { none, line, cross }

/// How the user drew a medicine's pill: shape, colour (and a second colour
/// for the other half of a capsule) and score.
class PillLook {
  const PillLook({
    this.shape = PillShape.round,
    this.color = 0xFFFFFFFF,
    this.color2,
    this.score = PillScore.none,
  });

  final PillShape shape;

  /// ARGB.
  final int color;

  /// Only a capsule has a second colour; null means the same as [color].
  final int? color2;
  final PillScore score;

  bool get isCapsule => shape == PillShape.capsule;

  PillLook copyWith({
    PillShape? shape,
    int? color,
    int? Function()? color2,
    PillScore? score,
  }) => PillLook(
    shape: shape ?? this.shape,
    color: color ?? this.color,
    color2: color2 == null ? this.color2 : color2(),
    score: score ?? this.score,
  );

  /// "round:ffffffff::line", stored in one column and in backups.
  String encode() =>
      '${shape.name}:${color.toRadixString(16)}:'
      '${color2?.toRadixString(16) ?? ''}:${score.name}';

  /// Null for nothing or text that is not a look.
  static PillLook? tryParse(String? text) {
    if (text == null) return null;
    final p = text.split(':');
    if (p.length != 4) return null;
    final shape = PillShape.values.asNameMap()[p[0]];
    final score = PillScore.values.asNameMap()[p[3]];
    final color = int.tryParse(p[1], radix: 16);
    final color2 = p[2].isEmpty ? null : int.tryParse(p[2], radix: 16);
    if (shape == null || score == null || color == null) return null;
    if (p[2].isNotEmpty && color2 == null) return null;
    return PillLook(shape: shape, color: color, color2: color2, score: score);
  }

  @override
  bool operator ==(Object other) =>
      other is PillLook &&
      other.shape == shape &&
      other.color == color &&
      other.color2 == color2 &&
      other.score == score;

  @override
  int get hashCode => Object.hash(shape, color, color2, score);
}

/// The colours offered for a pill.
const pillColors = <int>[
  0xFFFFFFFF,
  0xFFF3E2C0,
  0xFFF6CF4A,
  0xFFF08A4B,
  0xFFE5566D,
  0xFFF3A0BE,
  0xFF8E6BDB,
  0xFF4F8EF0,
  0xFF4FC1BA,
  0xFF5DBB63,
  0xFF8A6A4F,
  0xFF3A3A44,
];
