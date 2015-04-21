
//  Created by paulo.develop@gmail.com

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var bttOnOff: UIButton!
    @IBOutlet weak var sldGain: UISlider!
    @IBOutlet weak var sldThreshold: UISlider!
    @IBOutlet weak var sldCompressionRatio: UISlider!
    @IBOutlet weak var sldAttackTime: UISlider!
    @IBOutlet weak var sldReleaseTime: UISlider!
    
    @IBOutlet weak var lblGain: UILabel!
    @IBOutlet weak var lblThreshold: UILabel!
    @IBOutlet weak var lblCompRatio: UILabel!
    @IBOutlet weak var lblAttackTime: UILabel!
    @IBOutlet weak var lblReleaseTime: UILabel!
    
    @IBOutlet weak var levelMeter: LevelMeter!

    private let LEVELMETER_REFRESHING_SEC: Float = 0.01
    private let PEAKLEVEL_OFF_SEC: Double = 1.5

    var byPassing: ByPassing
    var compressor: Compressor
    var outputAnalyzer: AKAudioAnalyzer
    var notScaledOutputAnalyzer: AKAudioAnalyzer
    var analysisSequence: AKSequence
    var updateAnalysis: AKEvent
    
    private var timerPeakLevelOff: NSTimer?
    
    required init(coder aDecoder: NSCoder) {
        byPassing = ByPassing()
        compressor = Compressor()
        outputAnalyzer = AKAudioAnalyzer()
        notScaledOutputAnalyzer = AKAudioAnalyzer()
        analysisSequence = AKSequence()
        updateAnalysis = AKEvent()
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateSliders()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AKOrchestra.addInstrument(byPassing)
        AKOrchestra.addInstrument(compressor)
        outputAnalyzer = AKAudioAnalyzer(audioSource: compressor.auxilliaryOutput)
        notScaledOutputAnalyzer = AKAudioAnalyzer(audioSource: compressor.auxilliaryNotScaledOutput)
        AKOrchestra.addInstrument(outputAnalyzer)
        AKOrchestra.addInstrument(notScaledOutputAnalyzer)
        AKOrchestra.start()
        byPassing.play()
        outputAnalyzer.play()
        notScaledOutputAnalyzer.play()
    
        analysisSequence = AKSequence()
        updateAnalysis = AKEvent(block: {
            self.updateLevelMeterUI()
            self.analysisSequence.addEvent(self.updateAnalysis, afterDuration: self.LEVELMETER_REFRESHING_SEC)
        })
        
        analysisSequence.addEvent(updateAnalysis)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        AKOrchestra.reset()
        AKManager.sharedManager().stop()
    }

    @IBAction func onOffCompressing(sender: UIButton) {
        toggleSliders()
        
        if sender.currentTitle == "Off" {
            analysisSequence.play()
            compressor.play()
            byPassing.stop()
            
            sender.setTitle("On", forState: .Normal)
            
        } else {
            byPassing.play()
            compressor.stop()
            // FIXME: To turn off all LevelMeter's leds after audio input is off. Haved tried to empty .events and .times removing entries in both NSMutabelArrays and crashes. Will try AKSequence.reset() on AudioKit 2.0.
            analysisSequence.stop() // Eases CPU usage
            
            sender.setTitle("Off", forState: .Normal)
        }
    }
    
    //MARK: Sliders Data
    
    @IBAction func thresholdChanged(sender: UISlider) {
        AKTools.setProperty(compressor.threshold, withSlider: sender)
        lblThreshold.text = String(format:"%d dB", Int(sender.value))
    }

    @IBAction func compressionRatioChanged(sender: UISlider) {
        AKTools.setProperty(compressor.compRatio, withSlider: sender)
        lblCompRatio.text = String(format:"%.2f:1", sender.value)
    }
    
    @IBAction func attackTimeChanged(sender: UISlider) {
        AKTools.setProperty(compressor.attackTime, withSlider: sender)
        lblAttackTime.text = String(format:"%.3f sec", sender.value)
    }
    
    @IBAction func releaseTimeChanged(sender: UISlider) {
        AKTools.setProperty(compressor.releaseTime, withSlider: sender)
        lblReleaseTime.text = String(format:"%.3f sec", sender.value)
    }
    
    @IBAction func gainChanged(sender: UISlider) {
        AKTools.setProperty(compressor.gain, withSlider: sender)
        lblGain.text = String(format:"%.1f dB", amplitudeTodB(amp1: notScaledOutputAnalyzer.trackedAmplitude.value, amp2: outputAnalyzer.trackedAmplitude.value))
    }
    
    //MARK: Update UI
    
    func toggleSliders() {
        var sliders = self.view.subviews.filter(){ $0 is UISlider } as! [UISlider]
        let isSliderEnabled = sliders.first?.enabled
        sliders.map{ $0.enabled = !isSliderEnabled! }
    }
    
    func updateSliders() {
        AKTools.setSlider(sldThreshold, withProperty: compressor.threshold)
        AKTools.setSlider(sldCompressionRatio, withProperty: compressor.compRatio)
        AKTools.setSlider(sldAttackTime, withProperty: compressor.attackTime)
        AKTools.setSlider(sldReleaseTime, withProperty: compressor.releaseTime)
        AKTools.setSlider(sldGain, withProperty: compressor.gain)
        
        lblThreshold.text = String(format:"%.f dB", compressor.threshold.value)
        lblCompRatio.text = String(format:"%.2f:1", compressor.compRatio.value)
        lblAttackTime.text = String(format:"%.3f sec", compressor.attackTime.value)
        lblReleaseTime.text = String(format:"%.3f sec", compressor.releaseTime.value)
        lblGain.text = String(format:"%.1f dB", amplitudeTodB(amp1: 1, amp2: compressor.gain.value))
    }
    
    func updateLevelMeterUI() {
        if outputAnalyzer.trackedAmplitude.value > 0.0 {
            levelMeter.level = CGFloat(outputAnalyzer.trackedAmplitude.value)
            levelMeter.setNeedsDisplay()
        }
        
        if Float(levelMeter.peakLevel) < outputAnalyzer.trackedAmplitude.value {
            levelMeter.peakLevel = CGFloat(outputAnalyzer.trackedAmplitude.value)
            
            //To turn off the peakLevel led, only the most recent timer prevails
            if (timerPeakLevelOff?.valid) != nil { timerPeakLevelOff?.invalidate() }
            timerPeakLevelOff = NSTimer.scheduledTimerWithTimeInterval(PEAKLEVEL_OFF_SEC, target:self, selector: Selector("turnOffPeakLevelLed"), userInfo: nil, repeats: false)
        }
    }
    
    func turnOffPeakLevelLed() {
        levelMeter.peakLevel = 0.0
        levelMeter.setNeedsDisplay()
    }
    
    //MARK: Conversion formula from amplitude to dB
    
    func amplitudeTodB(#amp1: Float, amp2: Float) -> Float {
        return 20 * log10(amp2/amp1)
    }
}