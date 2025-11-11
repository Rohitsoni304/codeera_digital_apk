import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtm/agora_rtm.dart';

/// 🔑 Your Agora credentials
const String kAgoraAppId = '8517bf53f4c9491593699910f4766cb8';
const String? kRtmToken = '007eJxTYChgueInoGV5XLP9IMeNx+/nyXY2BE8r2/3jBkuW+uzZ17wVGCxMDc2T0kyN00ySLU0sDU0tjc0sLS0NDdJMzM3MkpMszLmEMxsCGRkyU28xMTJAIIjPwpCckVjCwAAA7Kgddw=='; // Optional, can be null for testing

class AgoraChatScreen extends StatefulWidget {
  const AgoraChatScreen({Key? key}) : super(key: key);

  @override
  State<AgoraChatScreen> createState() => _AgoraChatScreenState();
}

class _AgoraChatScreenState extends State<AgoraChatScreen> {
  late final TextEditingController _userIdCtr;
  late final TextEditingController _channelCtr;
  late final TextEditingController _msgCtr;

  AgoraRtmClient? _rtmClient;
  AgoraRtmChannel? _rtmChannel;

  final List<_ChatMessage> _messages = [];
  bool _isLoggedIn = false;
  bool _isJoined = false;
  RtmConnectionState _connState = RtmConnectionState.disconnected;

  @override
  void initState() {
    super.initState();
    _userIdCtr = TextEditingController(
        text: 'user_${DateTime.now().millisecondsSinceEpoch % 10000}');
    _channelCtr = TextEditingController(text: 'global');
    _msgCtr = TextEditingController();
    _initRtmClient();
  }

  Future<void> _initRtmClient() async {
    _rtmClient = await AgoraRtmClient.createInstance(kAgoraAppId);

    // Handle peer messages
    _rtmClient?.onMessageReceived =
        (RtmMessage message, String peerId) {
      _pushMsg(_ChatMessage(
        author: peerId,
        text: message.text ?? '',
        isLocal: false,
      ));
    };



    // Connection state
    _rtmClient!.onConnectionStateChanged2 =
        (RtmConnectionState state, RtmConnectionChangeReason reason) {
      setState(() => _connState = state);
      if (state == RtmConnectionState.aborted ||
          state == RtmConnectionState.disconnected) {
        setState(() {
          _isLoggedIn = false;
          _isJoined = false;
        });
      }
    };
  }

  Future<void> _login() async {
    if (_rtmClient == null) return;

    final userId = _userIdCtr.text.trim();
    if (userId.isEmpty) {
      _toast('User ID cannot be empty', isError: true);
      return;
    }

    try {
      print(kRtmToken);
      await _rtmClient!.login(kRtmToken, userId);
      setState(() => _isLoggedIn = true);
      _toast('✅ Logged in as $userId');
    } on AgoraRtmClientException catch (e) {
      // Print exact code and message
      print('Agora RTM Login Error -> code: ${e.code}, message: ${e}');
      _toast('Login failed [${e.code}] ${e}', isError: true);
    } catch (e) {
      print('Unknown login error: $e');
      _toast('Login failed: $e', isError: true);
    }
  }

  Future<void> _logout() async {
    try {
      await _leaveChannel();
      await _rtmClient?.logout();
      setState(() => _isLoggedIn = false);
      _toast('Logged out');
    } catch (e) {
      _toast('Logout failed: $e', isError: true);
    }
  }

  Future<void> _joinChannel() async {
    if (!_isLoggedIn) {
      _toast('Please login first', isError: true);
      return;
    }
    final channelId = _channelCtr.text.trim();
    if (channelId.isEmpty) return;

    try {
      _rtmChannel = await _rtmClient?.createChannel(channelId);

      _rtmChannel?.onMessageReceived =
          (RtmMessage message, RtmChannelMember member) {
        _pushMsg(_ChatMessage(
          author: member.userId,
          text: message.text ?? '',
          isLocal: false,
        ));
      };

      _rtmChannel?.onMemberJoined = (RtmChannelMember member) {
        _pushSys('🟢 ${member.userId} joined');
      };
      _rtmChannel?.onMemberLeft = (RtmChannelMember member) {
        _pushSys('🔴 ${member.userId} left');
      };

      await _rtmChannel?.join();
      setState(() => _isJoined = true);
      _pushSys('✅ Joined channel: $channelId');
    } catch (e) {
      _toast('Join failed: $e', isError: true);
    }
  }

  Future<void> _leaveChannel() async {
    try {
      await _rtmChannel?.leave();
      await _rtmChannel?.release();
    } catch (_) {}
    setState(() => _isJoined = false);
  }

  Future<void> _sendChannelMessage() async {
    final text = _msgCtr.text.trim();
    if (text.isEmpty || !_isJoined) return;
    try {
      await _rtmChannel?.sendMessage(RtmMessage.fromText(text));
      _pushMsg(_ChatMessage(
        author: _userIdCtr.text.trim(),
        text: text,
        isLocal: true,
      ));
      _msgCtr.clear();
    } catch (e) {
      _toast('Send failed: $e', isError: true);
    }
  }

  void _pushMsg(_ChatMessage m) {
    setState(() => _messages.add(m));
  }

  void _pushSys(String s) {
    setState(() => _messages
        .add(_ChatMessage(author: 'system', text: s, isSystem: true)));
  }

  void _toast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.black87,
      ),
    );
  }

  @override
  void dispose() {
    _leaveChannel();
    _rtmClient?.logout();
    _rtmClient?.release();
    _userIdCtr.dispose();
    _channelCtr.dispose();
    _msgCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canLogin = !_isLoggedIn;
    final canJoin = _isLoggedIn && !_isJoined;
    final canSend = _isJoined;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora RTM Chat'),
        backgroundColor: Colors.blueAccent,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                _connState.name.toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _box(
                        child: TextField(
                          controller: _userIdCtr,
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_isLoggedIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _box(
                        child: TextField(
                          controller: _channelCtr,
                          decoration: const InputDecoration(
                            labelText: 'Channel ID',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_isJoined,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canLogin ? _login : _logout,
                        icon: Icon(canLogin ? Icons.login : Icons.logout),
                        label: Text(canLogin ? 'Login' : 'Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          canLogin ? Colors.green : Colors.redAccent,
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canJoin
                            ? _joinChannel
                            : (_isJoined ? _leaveChannel : null),
                        icon: Icon(canJoin
                            ? Icons.meeting_room
                            : Icons.exit_to_app),
                        label: Text(canJoin
                            ? 'Join Channel'
                            : (_isJoined
                            ? 'Leave Channel'
                            : 'Join Channel')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          canJoin ? Colors.blueAccent : Colors.orange,
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Messages
          Expanded(
            child: Container(
              color: const Color(0xFFF7F9FC),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  if (m.isSystem) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Center(
                        child: Text(
                          m.text,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return Align(
                    alignment: m.isLocal
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: m.isLocal
                            ? Colors.blueAccent
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: m.isLocal
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.author,
                            style: TextStyle(
                              fontSize: 11,
                              color: m.isLocal
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: m.isLocal
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Input
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtr,
                      enabled: canSend,
                      decoration: InputDecoration(
                        hintText:
                        canSend ? 'Type a message…' : 'Join a channel to chat',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendChannelMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: canSend ? _sendChannelMessage : null,
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: child,
  );
}

class _ChatMessage {
  final String author;
  final String text;
  final bool isLocal;
  final bool isSystem;

  _ChatMessage({
    required this.author,
    required this.text,
    this.isLocal = false,
    this.isSystem = false,
  });
}
