import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/shared/models/chat_message.dart';

void main() {
  group('ChatState', () {
    test('canSend is true by default', () {
      const state = ChatState();
      expect(state.canSend, isTrue);
    });

    test('canSend is false when isSending', () {
      const state = ChatState(isSending: true);
      expect(state.canSend, isFalse);
    });

    test('canSend is false when isTyping', () {
      const state = ChatState(isTyping: true);
      expect(state.canSend, isFalse);
    });

    test('canSend is false when isProcessingPhoto', () {
      const state = ChatState(isProcessingPhoto: true);
      expect(state.canSend, isFalse);
    });

    test('copyWith preserves existing fields when not overridden', () {
      const original = ChatState(isSending: true, isTyping: false, error: 'err');
      final copy = original.copyWith(isTyping: true);
      expect(copy.isSending, isTrue);
      expect(copy.isTyping, isTrue);
      expect(copy.error, equals('err'));
    });

    test('copyWith can clear error by passing null explicitly', () {
      const original = ChatState(error: 'something');
      final copy = original.copyWith(error: null);
      expect(copy.error, isNull);
    });

    test('sortedMessages returns messages list', () {
      final messages = [
        ChatMessage(
          id: '1',
          avatarId: 'av1',
          role: MessageRole.user,
          content: 'Hello',
          createdAt: DateTime(2024),
        ),
      ];
      final state = ChatState(messages: messages);
      expect(state.sortedMessages, equals(messages));
    });

    test('initial state has empty messages', () {
      const state = ChatState();
      expect(state.messages, isEmpty);
    });
  });
}
