import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global Data Manager with hybrid local+cloud storage
class ProjectDataManager {
  static final ProjectDataManager _instance = ProjectDataManager._internal();
  factory ProjectDataManager() => _instance;
  ProjectDataManager._internal() {
    _tableData = Map.from(_defaultTableData);
    _initializeDataManager();
  }

  static const String _storageKey = 'project_table_data';
  static const String _firestoreCollection = 'project_data';
  static const String _firestoreDocument = 'bess_projects';

  // Firebase and local storage instances
  FirebaseFirestore? _firestore;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Data change listeners
  final List<VoidCallback> _listeners = [];

  // Debounce timer for cloud saves
  Timer? _cloudSaveTimer;

  // Default table data
  final Map<String, List<Map<String, String>>> _defaultTableData = {
    'Project Overview': [
      {'description': 'Project Name', 'data': 'Tamil Nadu BESS Project'},
      {'description': 'Total Capacity', 'data': '250 MW / 500 MWh'},
      {'description': 'Project Type', 'data': 'Battery Energy Storage System'},
      {'description': 'Location', 'data': 'Tamil Nadu, India'},
      {'description': 'Status', 'data': 'Under Development'},
    ],
    'Anuppankulam': [
      {'description': 'Site Name', 'data': 'Anuppankulam BESS'},
      {'description': 'Capacity', 'data': '83.33 MW / 166.66 MWh'},
      {'description': 'Phase', 'data': 'Phase 1'},
      {'description': 'Location', 'data': 'Anuppankulam, Tamil Nadu'},
      {'description': 'Status', 'data': 'Under Development'},
    ],
    'Ettayapuram': [
      {'description': 'Site Name', 'data': 'Ettayapuram BESS'},
      {'description': 'Capacity', 'data': '83.33 MW / 166.66 MWh'},
      {'description': 'Phase', 'data': 'Phase 2'},
      {'description': 'Location', 'data': 'Ettayapuram, Tamil Nadu'},
      {'description': 'Status', 'data': 'Planning Stage'},
    ],
    'Kayathar': [
      {'description': 'Site Name', 'data': 'Kayathar BESS'},
      {'description': 'Capacity', 'data': '83.34 MW / 166.68 MWh'},
      {'description': 'Phase', 'data': 'Phase 3'},
      {'description': 'Location', 'data': 'Kayathar, Tamil Nadu'},
      {'description': 'Status', 'data': 'Feasibility Study'},
    ],
  };

  // Current table data
  Map<String, List<Map<String, String>>> _tableData = {};

  // Initialize Firebase and SharedPreferences
  Future<void> _initializeDataManager() async {
    try {
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // Try to initialize Firebase (handle gracefully if not configured)
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        }
        _firestore = FirebaseFirestore.instance;
        _setupFirestoreListener();
        debugPrint('Firebase initialized successfully');
      } catch (e) {
        debugPrint('Firebase not configured, using local storage only: $e');
      }

      // Load data from local storage first
      await _loadFromLocalStorage();

      // Then sync with cloud if available
      if (_firestore != null) {
        await _syncWithCloud();
      }

      _isInitialized = true;
      _notifyListeners();
    } catch (e) {
      debugPrint('Error initializing data manager: $e');
      _isInitialized = true;
    }
  }

  // Setup Firestore real-time listener
  void _setupFirestoreListener() {
    if (_firestore == null) return;

    _firestore!
        .collection(_firestoreCollection)
        .doc(_firestoreDocument)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _updateFromCloudData(snapshot.data()!);
      }
    }, onError: (error) {
      debugPrint('Firestore listener error: $error');
    });
  }

  // Update local data from cloud
  void _updateFromCloudData(Map<String, dynamic> cloudData) {
    try {
      if (cloudData.containsKey('tableData')) {
        Map<String, dynamic> rawData = cloudData['tableData'];
        Map<String, List<Map<String, String>>> newData = {};

        rawData.forEach((key, value) {
          if (value is List) {
            newData[key] = List<Map<String, String>>.from(
              value.map((item) => Map<String, String>.from(item))
            );
          }
        });

        _tableData = newData;
        _saveToLocalStorage();
        _notifyListeners();
        debugPrint('Data synchronized from cloud');
      }
    } catch (e) {
      debugPrint('Error updating from cloud data: $e');
    }
  }

  // Getters
  Map<String, List<Map<String, String>>> get tableData => Map.from(_tableData);
  bool get isInitialized => _isInitialized;

  List<Map<String, String>>? getLocationData(String location) {
    return _tableData[location]?.map((e) => Map<String, String>.from(e)).toList();
  }

  // Listener management
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    // Only notify listeners if we actually have data changes
    if (_listeners.isNotEmpty) {
      for (var listener in _listeners) {
        listener();
      }
    }
  }

  // Update methods
  void updateCell(String location, int rowIndex, String column, String value) {
    if (_tableData[location] != null &&
        rowIndex >= 0 &&
        rowIndex < _tableData[location]!.length) {
      _tableData[location]![rowIndex][column] = value;
      _saveData();
      _notifyListeners();
    }
  }

  void addRow(String location, {String description = '', String data = ''}) {
    if (_tableData[location] != null) {
      _tableData[location]!.add({'description': description, 'data': data});
      _saveData();
      _notifyListeners();
    }
  }

  void removeRow(String location, int rowIndex) {
    if (_tableData[location] != null &&
        _tableData[location]!.length > 1 &&
        rowIndex >= 0 &&
        rowIndex < _tableData[location]!.length) {
      _tableData[location]!.removeAt(rowIndex);
      _saveData();
      _notifyListeners();
    }
  }

  // Save data to both local and cloud storage
  void _saveData() {
    _saveToLocalStorage(); // Save locally immediately
    _debouncedCloudSave(); // Debounce cloud saves
  }

  // Debounced cloud save - only saves after user stops typing
  void _debouncedCloudSave() {
    _cloudSaveTimer?.cancel();
    _cloudSaveTimer = Timer(Duration(seconds: 2), () {
      _saveToCloud();
    });
  }

  // Save to local storage (SharedPreferences)
  Future<void> _saveToLocalStorage() async {
    try {
      if (_prefs != null) {
        String jsonData = jsonEncode(_tableData);
        await _prefs!.setString(_storageKey, jsonData);
        // print('Data saved to local storage'); // Commented for performance
      }
    } catch (e) {
      debugPrint('Error saving to local storage: $e');
    }
  }

  // Load from local storage
  Future<void> _loadFromLocalStorage() async {
    try {
      if (_prefs != null) {
        String? jsonData = _prefs!.getString(_storageKey);
        if (jsonData != null && jsonData.isNotEmpty) {
          Map<String, dynamic> decoded = jsonDecode(jsonData);
          _tableData = decoded.map((key, value) {
            return MapEntry(key, List<Map<String, String>>.from(
              value.map((item) => Map<String, String>.from(item))
            ));
          });
          debugPrint('Data loaded from local storage');
        } else {
          debugPrint('No local data found, using defaults');
        }
      }
    } catch (e) {
      debugPrint('Error loading from local storage: $e');
      _tableData = Map.from(_defaultTableData);
    }
  }

  // Save to cloud storage (Firestore)
  Future<void> _saveToCloud() async {
    try {
      if (_firestore != null) {
        await _firestore!
            .collection(_firestoreCollection)
            .doc(_firestoreDocument)
            .set({
          'tableData': _tableData,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        debugPrint('Data saved to cloud');
      }
    } catch (e) {
      debugPrint('Error saving to cloud: $e');
    }
  }

  // Sync with cloud storage
  Future<void> _syncWithCloud() async {
    try {
      if (_firestore != null) {
        DocumentSnapshot doc = await _firestore!
            .collection(_firestoreCollection)
            .doc(_firestoreDocument)
            .get();

        if (doc.exists && doc.data() != null) {
          _updateFromCloudData(doc.data() as Map<String, dynamic>);
        } else {
          // No cloud data exists, upload current data
          await _saveToCloud();
        }
      }
    } catch (e) {
      debugPrint('Error syncing with cloud: $e');
    }
  }

  // Public save method for explicit saves (like save button)
  bool saveData() {
    try {
      _saveData();
      debugPrint('Data explicitly saved successfully: ${_tableData.length} locations');
      return true;
    } catch (e) {
      debugPrint('Error saving data: $e');
      return false;
    }
  }

  // Reset to default data
  void resetToDefaults() {
    _tableData = Map.from(_defaultTableData);
    _saveData();
    _notifyListeners();
    // Data reset to defaults
  }

  // Force refresh from cloud
  Future<void> refreshFromCloud() async {
    if (_firestore != null) {
      await _syncWithCloud();
    }
  }
}