// import 'package:agora_rtm/agora_rtm.dart';
//
// class AgoraRtmService {
//   static final AgoraRtmService _instance = AgoraRtmService._internal();
//   factory AgoraRtmService() => _instance;
//   AgoraRtmService._internal();
//
//   final String appId = "8517bf53f4c9491593699910f4766cb8";
//
//   late RtmClient _client;
//   RtmChannel? _channel;
//   // Note: I removed _eventHandler variable since we may set handlers directly
//
//   Future<void> init(String userId) async {
//     _client = await RtmClient.createInstance(appId);
//
//     _client.onMessageReceived = (RtmMessage message, String fromPeerId) {
//       print("Message from $fromPeerId: ${message.text}");
//     };
//     _client.onConnectionStateChanged = (RtmConnectionState state, RtmConnectionChangeReason reason) {
//       print('Connection changed: $state, reason: $reason');
//     };
//
//     await _client.login(token: null, uid: userId);
//   }
//
//   Future<void> logout() async {
//     await _client.logout();
//   }
//
//   Future<void> createChannel(
//       String channelName,
//       void Function(RtmMessage message, String fromUser) onMessageReceived,
//       ) async {
//     _channel = await _client.createChannel(channelName);
//
//     _channel!.onMessageReceived = (RtmMessage message, RtmMember member) {
//       onMessageReceived(message, member.userId);
//     };
//     _channel!.onMemberJoined = (RtmMember member) {
//       print("Member joined: ${member.userId}");
//     };
//     _channel!.onMemberLeft = (RtmMember member) {
//       print("Member left: ${member.userId}");
//     };
//
//     await _channel!.join();
//   }
//
//   Future<void> sendPeerMessage(String peerId, String text) async {
//     try {
//       final msg = RtmMessage.fromText(text);
//       final result = await _client.sendMessageToPeer(peerId, msg);
//       if (!result.hasPeerReceived) {
//         print("Send peer message failed: ${result.errorCode}");
//       }
//     } catch (e) {
//       print("Error sending peer message: $e");
//     }
//   }
//
//   Future<void> sendChannelMessage(String text) async {
//     if (_channel != null) {
//       final msg = RtmMessage.fromText(text);
//       final result = await _channel!.sendMessage(msg);
//       // Depending on API: maybe result.success or result.errorCode
//       if (!(result is RtmSendChannelMessageResult && result.success)) {
//         print("Send channel message failed: ${result}");
//       }
//     }
//   }
//
//   Future<void> leaveChannel() async {
//     await _channel?.leave();
//     _channel = null;
//   }
//
//   Future<void> destroy() async {
//     await _client.logout();
//     await _client.release();  // or _client.destroy(); check actual API
//   }
// }
