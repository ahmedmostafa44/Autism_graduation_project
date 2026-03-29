import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';
import '../bloc/chat_bloc.dart';
import '../../data/models/chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _ChatHeader(isDark: isDark),
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (_, state) {
                if (state is ChatLoaded) _scrollToBottom();
              },
              builder: (context, state) {
               
                if (state is ChatLoaded) {
                  return Column(children: [
                    _AiBadge(state: state, isDark: isDark),
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        itemCount:
                            state.messages.length + (state.isBotTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.messages.length &&
                              state.isBotTyping) {
                            return _TypingIndicator(isDark: isDark);
                          }
                          return _MessageBubble(
                              message: state.messages[index], isDark: isDark);
                        },
                      ),
                    ),
                  ]);
                }
                return const SizedBox();
              },
            ),
          ),
          _ChatInput(
              isDark: isDark, controller: _controller, onSend: _sendMessage),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();
    context.read<ChatBloc>().add(ChatMessageSent(text.trim()));
  }
}

// ── AI mode badge ─────────────────────────────────────────────────────────────
class _AiBadge extends StatelessWidget {
  final ChatLoaded state;
  final bool isDark;
  const _AiBadge({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {

    // if (!isOnDevice) {
    //   // No model -> offer download
    //   return GestureDetector(
    //     onTap: () => context.read<ChatBloc>().add(ChatModelDownloadStarted()),
    //     child: Container(
    //       margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
    //       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    //       decoration: BoxDecoration(
    //         gradient: LinearGradient(colors: [
    //           GalaxyColors.nebulaViolet.withOpacity(0.15),
    //           GalaxyColors.cosmicBlue.withOpacity(0.15),
    //         ]),
    //         borderRadius: BorderRadius.circular(14),
    //         border:
    //             Border.all(color: GalaxyColors.nebulaViolet.withOpacity(0.4)),
    //       ),
    //       child: Row(children: [
    //         const Text('🤖', style: TextStyle(fontSize: 18)),
    //         const SizedBox(width: 10),
    //         Expanded(
    //             child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //               Text('Set Up Buddy\'s Brain',
    //                   style: TextStyle(
    //                     fontSize: 13,
    //                     fontWeight: FontWeight.w800,
    //                     color: GalaxyColors.textPrimary(isDark),
    //                     fontFamily: 'Nunito',
    //                   )),
    //               Text(
    //                 'Download Gemma 3 (~300MB) to chat offline!',
    //                 style: TextStyle(
    //                     fontSize: 10,
    //                     color: GalaxyColors.textSecond(isDark),
    //                     fontFamily: 'Nunito'),
    //               ),
    //             ])),
    //         Container(
    //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    //           decoration: BoxDecoration(
    //             gradient: const LinearGradient(colors: [
    //               GalaxyColors.nebulaViolet,
    //               GalaxyColors.cosmicBlue
    //             ]),
    //             borderRadius: BorderRadius.circular(10),
    //           ),
    //           child: const Text('Download',
    //               style: TextStyle(
    //                 color: Colors.white,
    //                 fontSize: 11,
    //                 fontWeight: FontWeight.w800,
    //                 fontFamily: 'Nunito',
    //               )),
    //         ),
    //       ]),
    //     ),
    //   );
    // }

    // Show on-device badge
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: GalaxyColors.auroraGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GalaxyColors.auroraGreen.withOpacity(0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('🤖 On-Device AI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: GalaxyColors.auroraGreen,
              fontFamily: 'Nunito',
            )),
        const SizedBox(width: 6),
        Text('• No internet needed',
            style: TextStyle(
              fontSize: 10,
              color: GalaxyColors.textSecond(isDark),
              fontFamily: 'Nunito',
            )),
      ]),
    );
  }
}

// ── Download progress screen ──────────────────────────────────────────────────
class _DownloadScreen extends StatelessWidget {
  final double progress;
  final bool isDark;
  const _DownloadScreen({required this.progress, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GalaxyCard(
          glowing: true,
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🤖', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('Setting up Buddy\'s Brain!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: GalaxyColors.textPrimary(isDark),
                  fontFamily: 'Nunito',
                )),
            const SizedBox(height: 8),
            Text(
              'Downloading Gemma 3 AI model (~300MB)\nThis happens only once!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: GalaxyColors.textSecond(isDark),
                  fontFamily: 'Nunito'),
            ),
            const SizedBox(height: 24),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress > 0
                    ? progress
                    : null, // indeterminate until started
                backgroundColor: GalaxyColors.border(isDark),
                valueColor:
                    const AlwaysStoppedAnimation(GalaxyColors.nebulaViolet),
                minHeight: 14,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              progress > 0 ? '$pct% downloaded...' : 'Starting download...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: GalaxyColors.nebulaViolet,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'After this, Buddy works offline with no API limits! 🚀',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  color: GalaxyColors.textSecond(isDark),
                  fontFamily: 'Nunito'),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final bool isDark;
  const _ChatHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: GalaxyColors.surface(isDark),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GalaxyColors.border(isDark)),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: GalaxyColors.textPrimary(isDark)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      GalaxyColors.nebulaPurple,
                      GalaxyColors.cosmicBlue
                    ],
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: GalaxyColors.nebulaPurple.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: const Icon(Icons.smart_toy_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Buddy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: GalaxyColors.textPrimary(isDark),
                          fontFamily: 'Nunito',
                        )),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: GalaxyColors.auroraGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      GalaxyColors.auroraGreen.withOpacity(0.7),
                                  blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text('Online',
                            style: TextStyle(
                              fontSize: 11,
                              color: GalaxyColors.auroraGreen,
                              fontFamily: 'Nunito',
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              const _ThemeToggleMini(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleMini extends StatelessWidget {
  const _ThemeToggleMini();
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    return GestureDetector(
      onTap: () => context.read<ThemeBloc>().add(ThemeToggled()),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: GalaxyColors.surface(isDark),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: GalaxyColors.border(isDark)),
        ),
        child: Icon(
          isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
          size: 18,
          color: isDark ? GalaxyColors.nebulaViolet : GalaxyColors.solarGold,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;
  const _MessageBubble({required this.message, required this.isDark});

  bool get isUser => message.sender == MessageSender.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  GalaxyColors.nebulaPurple,
                  GalaxyColors.cosmicBlue
                ]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  size: 15, color: Colors.white),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(colors: [
                            GalaxyColors.nebulaPurple,
                            GalaxyColors.cosmicBlue
                          ])
                        : null,
                    color: isUser ? null : GalaxyColors.surface(isDark),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: GalaxyColors.border(isDark), width: 0.5),
                    boxShadow: isUser && isDark
                        ? [
                            BoxShadow(
                              color: GalaxyColors.nebulaPurple.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: -2,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(message.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUser
                            ? Colors.white
                            : GalaxyColors.textPrimary(isDark),
                        height: 1.4,
                        fontFamily: 'Nunito',
                      )),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_fmt(message.time),
                        style: TextStyle(
                          fontSize: 10,
                          color: GalaxyColors.textSecond(isDark),
                          fontFamily: 'Nunito',
                        )),
                    if (message.hasAudio && !isUser) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.volume_up_rounded,
                          size: 11, color: GalaxyColors.textSecond(isDark)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }
}

class _TypingIndicator extends StatefulWidget {
  final bool isDark;
  const _TypingIndicator({required this.isDark});
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [GalaxyColors.nebulaPurple, GalaxyColors.cosmicBlue]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                size: 15, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: GalaxyColors.surface(widget.isDark),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: GalaxyColors.border(widget.isDark), width: 0.5),
            ),
            child: Row(
              children: List.generate(
                  3,
                  (i) => AnimatedBuilder(
                        animation: _ctrl,
                        builder: (context, _) {
                          final v =
                              math.sin((_ctrl.value * math.pi * 2) - i * 0.8);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            width: 7,
                            height: 7 + v.abs() * 4,
                            decoration: BoxDecoration(
                              color: GalaxyColors.nebulaViolet
                                  .withOpacity(0.3 + v.abs() * 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      )),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final bool isDark;
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  const _ChatInput(
      {required this.isDark, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  GalaxyColors.nebulaPurple,
                  GalaxyColors.stardustPink
                ]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: GalaxyColors.nebulaPurple.withOpacity(0.4),
                      blurRadius: 12),
                ],
              ),
              child:
                  const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(
                    color: GalaxyColors.textPrimary(isDark),
                    fontFamily: 'Nunito'),
                decoration:
                    const InputDecoration(hintText: 'Type a message...'),
                onSubmitted: onSend,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onSend(controller.text),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    GalaxyColors.nebulaViolet,
                    GalaxyColors.cosmicBlue
                  ]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: GalaxyColors.nebulaViolet.withOpacity(0.5),
                        blurRadius: 12),
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
