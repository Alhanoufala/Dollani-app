//
//  NFCHelper.swift
//  Dollani
//
//  Created by Raseel AlRowais on 27/12/2022.
//



import Foundation
import CoreNFC

class NFCHelper: NSObject, NFCNDEFReaderSessionDelegate {
  var onNFCResult: ((Bool, String) -> ())?
  func restartSession() {
    let session = NFCNDEFReaderSession(delegate: self,
                                       queue: nil,
                                       invalidateAfterFirstRead: true)
    session.begin()
  }
  
  // MARK: NFCNDEFReaderSessionDelegate
  func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
    guard let onNFCResult = onNFCResult else { return }
    onNFCResult(false, error.localizedDescription)
  }
  
  func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    guard let onNFCResult = onNFCResult else { return }
    for message in messages {
      for record in message.records {
        if let resultString = String(data: record.payload, encoding: .utf8) {
          onNFCResult(true, resultString)
        }
      }
    }
  }
}
