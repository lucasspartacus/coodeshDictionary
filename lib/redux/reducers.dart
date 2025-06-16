import 'app_state.dart';
import 'actions.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is LoadWordsAction) {
    return state.copyWith(words: action.words, isLoading: false);
  }

  else if (action is AddToFavoritesAction) {
    final userFavorites = state.favoritesByUser[action.userId] ?? [];
    final updatedFavorites = {...userFavorites, action.word}.toList();
    final updatedFavoritesByUser = Map<String, List<String>>.from(state.favoritesByUser)
      ..[action.userId] = updatedFavorites;

    return state.copyWith(favoritesByUser: updatedFavoritesByUser);
  }

  else if (action is RemoveFromFavoritesAction) {
    final userFavorites = state.favoritesByUser[action.userId] ?? [];
    final updatedFavorites = userFavorites.where((w) => w != action.word).toList();
    final updatedFavoritesByUser = Map<String, List<String>>.from(state.favoritesByUser)
      ..[action.userId] = updatedFavorites;

    return state.copyWith(favoritesByUser: updatedFavoritesByUser);
  }

  else if (action is AddToHistoryAction) {
    final currentHistory = state.historyByUser[action.userId] ?? [];
    final updatedHistory = List<String>.from(currentHistory)..add(action.word);

    final updatedHistoryByUser = Map<String, List<String>>.from(state.historyByUser)
      ..[action.userId] = updatedHistory;

    return state.copyWith(historyByUser: updatedHistoryByUser);
  }

  else if (action is SetCurrentUserAction) {
    return state.copyWith(currentUserId: action.userId);
  }

  else if (action is SetFavoritesAction) {
    final updatedFavoritesByUser = Map<String, List<String>>.from(state.favoritesByUser)
      ..[action.userId] = action.favorites;

    return state.copyWith(favoritesByUser: updatedFavoritesByUser);
  }

  else if (action is SetHistoryAction) {
    final updatedHistoryByUser = Map<String, List<String>>.from(state.historyByUser);
    updatedHistoryByUser[action.userId] = List<String>.from(action.history);
    return state.copyWith(historyByUser: updatedHistoryByUser);
  }

  return state;
}
