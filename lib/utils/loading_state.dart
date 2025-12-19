/// Enum for managing loading states in providers
enum LoadingState {
  /// Initial state before any data is loaded
  initial,

  /// Data is currently being loaded
  loading,

  /// Data has been successfully loaded
  loaded,

  /// An error occurred while loading data
  error,

  /// Data is being refreshed (pull to refresh)
  refreshing,
}

/// Extension methods for LoadingState
extension LoadingStateExtension on LoadingState {
  /// Check if currently loading
  bool get isLoading => this == LoadingState.loading || this == LoadingState.refreshing;

  /// Check if data is loaded
  bool get isLoaded => this == LoadingState.loaded;

  /// Check if there's an error
  bool get isError => this == LoadingState.error;

  /// Check if in initial state
  bool get isInitial => this == LoadingState.initial;

  /// Check if refreshing
  bool get isRefreshing => this == LoadingState.refreshing;
}
