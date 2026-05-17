// This file is kept for reference only.
// The offline-first layer (Hive + Dio) has been replaced by
// Cloud Firestore which provides built-in offline persistence.
//
// Previously: HiveCacheManager + DioApiClient + OfflineRepository
// Now: FirebaseFirestore with persistenceEnabled: true (see FirestoreService)