//
//  ChatVC.swift
//  Chat App
//
//  Created by Kevin Li on 10/22/19.
//  Copyright © 2019 Kevin Li. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import FirebaseFirestore
import Photos
import InputBarAccessoryView

final class ChatVC: MessagesViewController {
    
    private let user: User
    private let channel: Channel
    
    private var messages = [Message]()
    private var messageListener: ListenerRegistration?
    
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    
    private var isSendingPhoto = false {
      didSet {
        DispatchQueue.main.async {
//          self.messageInputBar.leftStackViewItems.forEach { item in
//            item.isEnabled = !self.isSendingPhoto
//          }
            self.messageInputBar.leftStackViewItems.forEach { item in
                let item = item as? InputBarButtonItem
                item!.isEnabled = !self.isSendingPhoto
            }
        }
      }
    }
    
    deinit {
        messageListener?.remove()
    }
    
    init(user: User, channel: Channel) {
        self.user = user
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
        
        title = channel.name
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      guard let id = channel.id else {
        navigationController?.popViewController(animated: true)
        return
      }

      reference = db.collection(["channels", id, "thread"].joined(separator: "/"))
      
      messageListener = reference?.addSnapshotListener { querySnapshot, error in
        guard let snapshot = querySnapshot else {
          print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
          return
        }
        
        snapshot.documentChanges.forEach { change in
          self.handleDocumentChange(change)
        }
      }
      
      navigationItem.largeTitleDisplayMode = .never
      
      maintainPositionOnKeyboardFrameChanged = true
      messageInputBar.inputTextView.tintColor = .primary
      messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
      
      messageInputBar.delegate = self
      messagesCollectionView.messagesDataSource = self
      messagesCollectionView.messagesLayoutDelegate = self
      messagesCollectionView.messagesDisplayDelegate = self
      
      let cameraItem = InputBarButtonItem(type: .system) // 1
      cameraItem.tintColor = .primary
      cameraItem.image = #imageLiteral(resourceName: "camera")
      cameraItem.addTarget(
        self,
        action: #selector(cameraButtonPressed), // 2
        for: .primaryActionTriggered
      )
      cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
      
      messageInputBar.leftStackView.alignment = .center
      messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
      messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false) // 3
    }
    
    //MARK: Actions

    @objc private func cameraButtonPressed() {
      let picker = UIImagePickerController()
      picker.delegate = self

      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        picker.sourceType = .camera
      } else {
        picker.sourceType = .photoLibrary
      }

      present(picker, animated: true, completion: nil)
    }
    
    //MARK: Helper methods
    
    private func save(_ message: Message) {
      reference?.addDocument(data: message.representation) { error in
        if let e = error {
          print("Error sending message: \(e.localizedDescription)")
          return
        }
        
        self.messagesCollectionView.scrollToBottom()
      }
    }
    
    private func insertNewMessage(_ message: Message) {
      guard !messages.contains(message) else {
        return
      }
      
      messages.append(message)
      messages.sort()
      
      let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
      let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
      
      messagesCollectionView.reloadData()
      
      if shouldScrollToBottom {
        DispatchQueue.main.async {
          self.messagesCollectionView.scrollToBottom(animated: true)
        }
      }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
      guard var message = Message(document: change.document) else {
        return
      }
      
      switch change.type {
      case .added:
        if let url = message.downloadURL {
          downloadImage(at: url) { [weak self] image in
            guard let `self` = self else {
              return
            }
            guard let image = image else {
              return
            }
            
            message.image = image
            self.insertNewMessage(message)
          }
        } else {
          insertNewMessage(message)
        }
        
      default:
        break
      }
    }
    
    private func uploadImage(_ image: UIImage, to channel: Channel, completion: @escaping (URL?) -> Void) {
      guard let channelID = channel.id else {
        completion(nil)
        return
      }
      
      guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
        completion(nil)
        return
      }
      
      let metadata = StorageMetadata()
      metadata.contentType = "image/jpeg"

      let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
//      storage.child(channelID).child(imageName).putData(data, metadata: metadata) { meta, error in
//        completion(meta?.downloadURL())
//      }
        
        let storageRef = storage.child(channelID).child("\(imageName).jpg")
        storageRef.putData(data, metadata: metadata, completion: { (metadata, error) in
            if error != nil, metadata != nil {
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    return
                }
                if let imageUrl = url?.absoluteURL {
                    completion(imageUrl)
                }
            })
        })
        
    }

    private func sendPhoto(_ image: UIImage) {
      isSendingPhoto = true
      
      uploadImage(image, to: channel) { [weak self] url in
        guard let `self` = self else {
          return
        }
        self.isSendingPhoto = false
        
        guard let url = url else {
          return
        }
        
        var message = Message(user: self.user, image: image)
        message.downloadURL = url
        
        self.save(message)
        self.messagesCollectionView.scrollToBottom()
      }
    }
    
    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
      let ref = Storage.storage().reference(forURL: url.absoluteString)
      let megaByte = Int64(1 * 1024 * 1024)
      
      ref.getData(maxSize: megaByte) { data, error in
        guard let imageData = data else {
          completion(nil)
          return
        }
        
        completion(UIImage(data: imageData))
      }
    }
}

// MARK: - MessagesDataSource

extension ChatVC: MessagesDataSource {
    
    // 1
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    // 2
    func currentSender() -> SenderType {
        return Sender(id: user.uid, displayName: AppSettings.displayName)
    }
    
    // 3
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    // 4
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor(white: 0.3, alpha: 1)])
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatVC: MessagesLayoutDelegate {
    
    // 1
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    // 2
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    // 3
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatVC: MessagesDisplayDelegate {
    
    // 1
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
    }
    
    // 2
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessageInputBarDelegate

extension ChatVC: MessageInputBarDelegate {
    
    // 1
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = Message(user: user, content: text)
        
        save(message)
        inputBar.inputTextView.text = ""
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)

    if let asset = info[.phAsset] as? PHAsset { // 1
      let size = CGSize(width: 500, height: 500)
      PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
        guard let image = result else {
          return
        }

        self.sendPhoto(image)
      }
    } else if let image = info[.originalImage] as? UIImage { // 2
      sendPhoto(image)
    }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }

}
