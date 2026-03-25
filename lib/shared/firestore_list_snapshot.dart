class FirestoreListSnapshot<T> {
  const FirestoreListSnapshot({
    required this.items,
    required this.isFromCache,
    required this.hasPendingWrites,
    required this.pendingIds,
  });

  final List<T> items;
  final bool isFromCache;
  final bool hasPendingWrites;
  final Set<String> pendingIds;
}
