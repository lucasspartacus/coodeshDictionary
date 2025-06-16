class AppState {
  final List<String> words;
  final Map<String, List<String>> favoritesByUser;
  final Map<String, List<String>> historyByUser;
  final String? selectedWord;
  final bool isLoading;
  final String currentUserId;

  AppState({
    required this.words,
    required this.favoritesByUser,
    required this.historyByUser,
    this.selectedWord,
    this.isLoading = false,
    this.currentUserId = '',
  });

  factory AppState.initial() {
    return AppState(
      words: [],
      favoritesByUser: {},
      historyByUser: {},
      selectedWord: null,
      isLoading: false,
      currentUserId: '',
    );
  }

  AppState copyWith({
    List<String>? words,
    Map<String, List<String>>? favoritesByUser,
    Map<String, List<String>>? historyByUser,
    String? selectedWord,
    bool? isLoading,
    String? currentUserId,
  }) {
    return AppState(
      words: words ?? this.words,
      favoritesByUser: favoritesByUser ?? this.favoritesByUser,
      historyByUser: historyByUser ?? this.historyByUser,
      selectedWord: selectedWord ?? this.selectedWord,
      isLoading: isLoading ?? this.isLoading,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}
