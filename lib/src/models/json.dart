/// Small helpers for the loosely typed JSON Telegram sends.
int? jsonInt(Object? v) => switch (v) {
      int i => i,
      num n => n.toInt(),
      String s => int.tryParse(s),
      _ => null,
    };

double? jsonDouble(Object? v) => switch (v) {
      num n => n.toDouble(),
      String s => double.tryParse(s),
      _ => null,
    };

bool? jsonBool(Object? v) => switch (v) {
      bool b => b,
      String s => s == 'true' || s == '1',
      num n => n != 0,
      _ => null,
    };

String? jsonString(Object? v) => v?.toString();

Map<String, Object?>? jsonMap(Object? v) => switch (v) {
      Map<String, Object?> m => m,
      Map<Object?, Object?> m => m.map((k, val) => MapEntry(k.toString(), val)),
      _ => null,
    };
