import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class DragDropState {
  /// zoneId → labelId (null = boş)
  final Map<String, String?> placements;

  /// "Kontrol Et" basıldıktan sonra true olur
  final bool isChecked;

  /// zoneId → doğru mu? (sadece isChecked true iken geçerli)
  final Map<String, bool> results;

  const DragDropState({
    required this.placements,
    this.isChecked = false,
    this.results = const {},
  });

  /// Havuza dönmemiş, bir zone'a yerleştirilmiş label ID'leri
  Set<String> get placedLabelIds =>
      placements.values.whereType<String>().toSet();

  /// Tüm zone'lar dolu mu?
  bool get allFilled => placements.values.every((v) => v != null);

  /// Kaç zone doğru? (isChecked = true iken geçerli)
  int get score => results.values.where((v) => v).length;

  DragDropState copyWith({
    Map<String, String?>? placements,
    bool? isChecked,
    Map<String, bool>? results,
  }) =>
      DragDropState(
        placements: placements ?? this.placements,
        isChecked: isChecked ?? this.isChecked,
        results: results ?? this.results,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class DragDropNotifier extends StateNotifier<DragDropState> {
  DragDropNotifier() : super(const DragDropState(placements: {}));

  /// Ekran oluşturulduğunda zone ID listesiyle başlat
  void init(List<String> zoneIds) {
    state = DragDropState(
      placements: {for (final id in zoneIds) id: null},
    );
  }

  /// [labelId]'yi [zoneId]'ye yerleştir.
  /// Label başka bir zone'daysa önce oradan kaldırılır.
  void placeLabel(String zoneId, String labelId) {
    final next = Map<String, String?>.from(state.placements);
    for (final key in next.keys) {
      if (next[key] == labelId) next[key] = null;
    }
    next[zoneId] = labelId;
    state = state.copyWith(placements: next, isChecked: false, results: {});
  }

  /// [zoneId]'deki label'ı kaldırıp havuza geri döndür
  void removeLabel(String zoneId) {
    final next = Map<String, String?>.from(state.placements)..[zoneId] = null;
    state = state.copyWith(placements: next, isChecked: false, results: {});
  }

  /// Yerleştirmeleri [correctAnswers] (zoneId → doğru labelId) ile karşılaştır
  void checkAnswers(Map<String, String> correctAnswers) {
    final results = <String, bool>{
      for (final zoneId in state.placements.keys)
        zoneId: state.placements[zoneId] == correctAnswers[zoneId],
    };
    state = state.copyWith(isChecked: true, results: results);
  }

  /// Her şeyi sıfırla
  void reset() {
    final zoneIds = state.placements.keys.toList();
    state = DragDropState(
      placements: {for (final id in zoneIds) id: null},
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final dragDropProvider =
    StateNotifierProvider.autoDispose<DragDropNotifier, DragDropState>(
  (ref) => DragDropNotifier(),
);
