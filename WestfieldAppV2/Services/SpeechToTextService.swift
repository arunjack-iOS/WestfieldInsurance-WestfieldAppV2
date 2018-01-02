
//
//  SpeechToTextService.swift
//  WatsonDemo
//
//  Created by RAHUL on 11/15/16.
//  Copyright © 2016 RAHUL. All rights reserved.
//

import Foundation

import AVFoundation
import SpeechToTextV1

protocol SpeechToTextServiceDelegate: class {
    func didFinishTranscribingSpeech(withText text: String)
}

class SpeechToTextService {
    //var speechToText: SpeechToText!

    // MARK: - Properties
    weak var delegate: SpeechToTextServiceDelegate?
   // var speechToTextSession = SpeechToTextSession(username: GlobalConstants.dennisNotoBluemixUsernameSTT,
                                                 // password: GlobalConstants.dennisNotoBluemixPasswordSTT)
    
   var speechToText = SpeechToText(
    username: GlobalConstants.dennisNotoBluemixUsernameSTT,
    password: GlobalConstants.dennisNotoBluemixPasswordSTT
    )

    var textTranscription: String?


    // MARK: - Init
    init(delegate: SpeechToTextServiceDelegate) {
        self.delegate = delegate
    }

    func startRecording() {
        
//        speechToTextSession.connect()
//        var settings = RecognitionSettings(contentType: .opus)
//        settings.interimResults = false
//        //settings.continuous = true
//        //settings.inactivityTimeout = -1
//        settings.smartFormatting = true
//
//        speechToTextSession.onConnect = { print("connected") }
//
//        speechToTextSession.startRequest(settings: settings)
//        speechToTextSession.startMicrophone()
        
        
        var settings = RecognitionSettings(contentType: .opus)
        settings.interimResults = true
        speechToText.recognizeMicrophone(settings: settings, failure: failure) { results in
        
            print(results.bestTranscript)
            let trimmedString = results.bestTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
            
            print(trimmedString)

                            self.delegate?.didFinishTranscribingSpeech(withText: results.bestTranscript)
        }

    }

    func failure(error: Error) {
        let alert = UIAlertController(
            title: "Watson Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        DispatchQueue.main.async {
            //self.present(alert, animated: true)
        }
    }

    func finishRecording() {
        
//        speechToTextSession.onResults = { results in print(results.bestTranscript)
//            if let bestTranscript = results.bestTranscript as String? {
//                print("my textttt>>>>>>>\(bestTranscript)")
//
//                let trimmedString = bestTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
//                self.delegate?.didFinishTranscribingSpeech(withText: trimmedString)
//            }
//        }
//
//        speechToTextSession.stopMicrophone()
//        speechToTextSession.stopRequest()
//        speechToTextSession.disconnect()
        
    }
    
     func stopTranscribing() {
        speechToText.stopRecognizeMicrophone()
    }


}
