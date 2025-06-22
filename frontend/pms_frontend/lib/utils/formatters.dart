class Formatters {
  /// Format ID to 4-digit string with leading zeros
  static String formatId(dynamic id) {
    if (id == null) return "0000";
    
    int idValue = 0;
    if (id is int) {
      idValue = id;
    } else if (id is String) {
      idValue = int.tryParse(id) ?? 0;
    }
    
    return idValue.toString().padLeft(4, '0');
  }
}