
//  Created by paulo.develop@gmail.com

class ByPassing: AKInstrument {
    
    private var microphone = AKAudioInput()
    private var audioOutput = AKAudioOutput()
    
    var auxilliaryOutput = AKAudio()
    
    override init() {
        super.init()
        
        microphone = AKAudioInput()
        connect(microphone)
        audioOutput = AKAudioOutput(audioSource:microphone)
        connect(audioOutput)
        
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to: microphone)
    }
}