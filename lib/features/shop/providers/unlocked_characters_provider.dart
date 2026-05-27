import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pally/shared/models/mochi_character.dart';

const _storage = FlutterSecureStorage();
const _kUnlockedKey = 'unlocked_mochi_characters';

class UnlockedCharactersNotifier extends AsyncNotifier<Set<MochiCharacter>> {
  @override
  Future<Set<MochiCharacter>> build() async => _load();

  Future<Set<MochiCharacter>> _load() async {
    final raw = await _storage.read(key: _kUnlockedKey);
    if (raw == null) {
      final defaults = MochiCharacter.values.where((c) => !c.isLockedByDefault).toSet();
      await _persist(defaults);
      return defaults;
    }
    return raw.split(',').where((s) => s.isNotEmpty).map((s) {
      try { return MochiCharacter.fromJson(s); } catch (_) { return null; }
    }).whereType<MochiCharacter>().toSet();
  }

  Future<void> unlock(MochiCharacter character) async {
    final current = state.valueOrNull ?? {};
    final updated = {...current, character};
    await _persist(updated);
    state = AsyncData(updated);
  }

  bool isUnlocked(MochiCharacter character) {
    if (!character.isLockedByDefault) return true;
    return state.valueOrNull?.contains(character) ?? false;
  }

  Future<void> _persist(Set<MochiCharacter> chars) async {
    await _storage.write(key: _kUnlockedKey, value: chars.map((c) => c.jsonValue).join(','));
  }
}

final unlockedCharactersProvider =
    AsyncNotifierProvider<UnlockedCharactersNotifier, Set<MochiCharacter>>(UnlockedCharactersNotifier.new);
