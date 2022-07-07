import ZendeskSDKMessaging
import ZendeskSDK

@objc(ZendeskMessaging)
class ZendeskMessaging: NSObject { 
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }

  @objc
  func initialize(_ channelKey:String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    Zendesk.initialize(withChannelKey: channelKey,
                      messagingFactory: DefaultMessagingFactory()) { result in
      if case let .failure(error) = result {
        reject("error","\(error)",nil)
        print("Messaging did not initialize.\nError: \(error.localizedDescription)")
      } else {
        resolve("success")
      }
    }
  }
  
  @objc
  func showMessaging() {
    DispatchQueue.main.async {
      guard let zendeskController = Zendesk.instance?.messaging?.messagingViewController() else {
        return }
      let viewController = RCTPresentedViewController();
      let navigationController = UINavigationController(rootViewController: zendeskController);
        zendeskController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.closeMessaging))
      viewController?.present(navigationController, animated: true) {
        print("Messaging have shown")
      }
    }
  }

  @objc
  func closeMessaging() {
    DispatchQueue.main.async {
      let viewController = RCTPresentedViewController();
      viewController?.dismiss(animated: true);
    }
  }

  @objc
  func loginUser(_ token:String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    Zendesk.instance?.loginUser(with: token) { result in
      switch result {
      case .success(let user):
          print(user)
          resolve(user)
      case .failure(let error):
          reject("error","\(error)",nil)
      }         
    }
  }

  @objc
  func logoutUser(_ resolve: @escaping RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock) {
    Zendesk.instance?.logoutUser { result in
      switch result {
      case .success:
          resolve("success")
      case .failure(let error):
          reject("error","\(error)",nil)
      }
    }
  }
}
