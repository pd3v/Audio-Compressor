
//  Created by paulo.develop@gmail.com

class Compressor: AKInstrument {
    
    private var microphone = AKAudioInput()
    
    var threshold = AKInstrumentProperty(value: -20, minimum: -60, maximum: 6) // dB
    var compRatio = AKInstrumentProperty(value: 2, minimum: 1, maximum: 60)
    var attackTime = AKInstrumentProperty(value: 0.010, minimum: 0.001, maximum: 1.0)
    var releaseTime = AKInstrumentProperty(value: 0.100, minimum: 0.010, maximum: 3.0)
    var gain = AKInstrumentProperty(value: 2, minimum: 1, maximum: 40)

    var auxilliaryOutput = AKAudio()
    var auxilliaryNotScaledOutput = AKAudio()
    
    override init() {
        super.init()
        
        microphone = AKAudioInput()
        connect(microphone)
        
        addProperty(self.gain)
        addProperty(self.threshold)
        addProperty(self.compRatio)
        addProperty(self.attackTime)
        addProperty(self.releaseTime)
        
        let compressedAudio = AKCompressor(
            input: microphone,
            controllingInput: microphone,
            threshold: self.threshold,
            lowKnee: 48.ak,
            highKnee: 60.ak,
            compressionRatio: self.compRatio,
            attackTime: self.attackTime,
            releaseTime: self.releaseTime,
            lookAheadTime: 0.05.ak
        )
        connect(compressedAudio)
        
        let scaledCompressedAudio = AKAssignment(input: compressedAudio.scaledBy(self.gain))
        self.connect(scaledCompressedAudio)
        
        let audioOutput = AKAudioOutput(audioSource: scaledCompressedAudio)
        self.connect(audioOutput)
        
        self.auxilliaryOutput = AKAudio.globalParameter()
        self.assignOutput(auxilliaryOutput, to: scaledCompressedAudio)
        
        self.auxilliaryNotScaledOutput = AKAudio.globalParameter()
        self.assignOutput(auxilliaryNotScaledOutput, to: compressedAudio)
    }
 }