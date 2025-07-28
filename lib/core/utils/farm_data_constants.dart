class FarmData {
  static const List<String> pigGenders = ['Female', 'Male', 'Castrated Male'];

  // This map remains the single source of truth for gender/status logic
  static final Map<String, List<String>> gendersByStatus = {
    'Sow': ['Female'],
    'Gilt': ['Female'],
    'Boar': ['Male'],
    'Weaner': ['Female', 'Male', 'Castrated Male'],
    'Grower': ['Female', 'Male', 'Castrated Male'],
    'Finisher': ['Female', 'Male', 'Castrated Male'],
    'Active': ['Female', 'Male', 'Castrated Male'],
    'Quarantined': ['Female', 'Male', 'Castrated Male'],
    'Sold': ['Female', 'Male', 'Castrated Male'],
    'Deceased': ['Female', 'Male', 'Castrated Male'],
  };

  // This list is useful for general purpose editing
  static final List<String> allStatuses = gendersByStatus.keys.toList();

  static const List<String> purchaseStatuses = [
    'Sow',
    'Gilt',
    'Boar',
    'Weaner',
    'Grower',
    'Finisher',
    'Active',
    'Quarantined',
  ];

  static const List<String> pigBreeds = [
    'Duroc',
    'Yorkshire',
    'Landrace',
    'Hampshire',
    'Berkshire',
    'Crossbreed',
    'Other',
  ];
}
