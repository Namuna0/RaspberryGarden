import 'package:flutter/material.dart';
import '../models/discord_message.dart';
import '../widgets/ui_helpers.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.isMyMessage,
  });

  final List<DiscordMessage> messages;
  final ScrollController scrollController;
  final bool Function(DiscordMessage message) isMyMessage;

  String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _normalizeDiscordText(String text) {
    return text
        .replaceAll(':game_die:', '🎲')
        .replaceAll(':smile:', '😄')
        .replaceAll(':heart:', '❤️');
  }

  Widget _buildAvatar(DiscordMessage msg) {
    final iconUrl = msg.iconUrl;

    if (iconUrl != null && iconUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.black26,
        backgroundImage: NetworkImage(iconUrl),
      );
    }

    return const CircleAvatar(
      radius: 18,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildBubble(DiscordMessage msg, bool mine, String normalizedContent) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: mine
            ? Colors.pink.withOpacity(0.70)
            : Colors.black.withOpacity(0.60),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '${msg.user}  ${_formatTime(msg.time.toLocal())}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            normalizedContent,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final mine = isMyMessage(msg);
        final normalizedContent = _normalizeDiscordText(msg.content);

        final avatar = _buildAvatar(msg);
        final bubble = _buildBubble(msg, mine, normalizedContent);

        return GestureDetector(
          onLongPress: () => copyToClipboard(context, normalizedContent),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment:
                  mine ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: mine
                  ? [
                      Flexible(child: bubble),
                      const SizedBox(width: 8),
                      avatar,
                    ]
                  : [
                      avatar,
                      const SizedBox(width: 8),
                      Flexible(child: bubble),
                    ],
            ),
          ),
        );
      },
    );
  }
}
