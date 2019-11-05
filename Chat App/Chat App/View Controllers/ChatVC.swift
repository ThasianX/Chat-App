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
    }
    
    //MARK: Helper methods
    
    private func save(_ message: Message) {
      reference?.addDocument(data: message.representation) { error in
        if let e = error {
          print("Error sending message: \(e.localizedDescription)")
          return
        }
        print("save called")
        self.messagesCollectionView.scrollToBottom()
      }
    }
    
    private func insertNewMessage(_ message: Message) {
      guard !messages.contains(message) else {
        return
      }
      print("insert new message called")
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
      guard let message = Message(document: change.document) else {
        return
      }
      
      switch change.type {
      case .added:
        insertNewMessage(message)
      default:
        break
      }
    }
}

// MARK: - MessagesDataSource

extension ChatVC: MessagesDataSource {
    
    // 1
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        print("Number of sections called - \(messages.count)")
        return messages.count
    }
    
    // 2
    func currentSender() -> SenderType {
        print("Current sender called")
        return Sender(id: user.uid, displayName: AppSettings.displayName)
    }
    
    // 3
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        print("Message for item called")
        return messages[indexPath.section]
    }
    
    // 4
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        print("Message top label called")
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor(white: 0.3, alpha: 1)])
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatVC: MessagesLayoutDelegate {
    
    // 1
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        print("Height for location called")
        return 0
    }
    
    // 2
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        print("Avatar size called")
        return .zero
    }
    
    // 3
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        print("Footer view size called")
        return CGSize(width: 0, height: 0)
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatVC: MessagesDisplayDelegate {
    
    // 1
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        print("Background color called")
        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
    }
    
    // 2
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        print("Message style called")
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessageInputBarDelegate

extension ChatVC: MessageInputBarDelegate {
    
    // 1
    func inputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        print("Message input bar called")
        print("Text - \(text). User id - \(user.uid)")
        if let name = AppSettings.displayName{
            print(name)
        } else {
            print("Name is nil")
        }
        let message = Message(user: user, content: text)
        
        save(message)
        inputBar.inputTextView.text = ""
    }
}
