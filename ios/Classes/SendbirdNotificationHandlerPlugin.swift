import Flutter
import UIKit

public class SendbirdNotificationHandlerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    var _eventChannel : FlutterEventSink? = nil
    var _initialMessage: BirdMessage?
    
    let remoteNotificationKey = UIApplication.LaunchOptionsKey.remoteNotification
    let notificationContentKey = "value"
    
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sendbird_notification_handler", binaryMessenger: registrar.messenger())
      let eventChannel = FlutterEventChannel(name: "sendbird_notification_handler_events", binaryMessenger: registrar.messenger())
    let instance = SendbirdNotificationHandlerPlugin()
      eventChannel.setStreamHandler(instance)
      
      print("SENDBIRD HANDLER REGISTERED")

    registrar.addMethodCallDelegate(instance, channel: channel)
  }
    
    @objc func didFinish(_ notification: NSNotification) {
        print("APP FINISHED LAUNCH")
        guard let remoteNotification = (notification.userInfo?[remoteNotificationKey] as? NSDictionary ) else {
            print("NO INITIAL NOTIFICATION RECIEVED")
            return
        }

        guard let sendbird = remoteNotification["sendbird"] as? [String: Any] else {
            print("Not sendbird Notification")
            return
        }
        
        _initialMessage = buildBirdMessage(content: sendbird)
    }



  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getInitialMessage":
        result(handleInitialNotification());
    default:
      result(FlutterMethodNotImplemented)
    }
  }
    
    
    
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventChannel = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    
    
    
    func handleInitialNotification() -> String? {
        
        if(_initialMessage == nil) {
            return nil
        }
        let jsonEncoder = JSONEncoder()

        
        do {
            let jsonData = try jsonEncoder.encode(_initialMessage)
            let jsonString = String(data: jsonData, encoding: .utf8)
            _initialMessage = nil
            return jsonString
        } catch {
            return nil
        }
    }
    
    func buildBirdMessage(content: [String: Any]) -> BirdMessage {
        let message = content["message"] as! String
        let senderInfo = content["sender"] as! [String: Any]
        let channelInfo = content["channel"] as! [String: Any]
        let channelUrl = channelInfo["channel_url"] as! String
        let senderId = senderInfo["id"] as! String
        let senderName = senderInfo["name"] as? String
        let senderProfilePhoto = senderInfo["profile_url"] as? String
        let type = content["type"] as! String
        return BirdMessage(channelUrl: channelUrl, type: type, senderId: senderId, senderName: senderName, senderProfileUrl: senderProfilePhoto, message: message)
    }

}


struct BirdMessage: Codable {
    var channelUrl : String
    var type: String
    var senderId: String
    var senderName: String?
    var senderProfileUrl: String?
    var message: String
}


