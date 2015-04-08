
//  Created by paulo.develop@gmail.com on 22/01/15.
//  Copyright (c) 2015 xyz. All rights reserved.

class ByPassing: AKInstrument {
    
    private var microphone = AKAudioInput()
    private var audioOutput = AKAudioOutput()
    
    let auxilliaryOutput = AKAudio()
    
    override init() {
        super.init()
        
        microphone = AKAudioInput()
        connect(microphone)
        audioOutput = AKAudioOutput(audioSource:microphone)
        connect(audioOutput)
        
        auxilliaryOutput = AKAudio.globalParameter()
        self.assignOutput(auxilliaryOutput, to: microphone)
    }
}