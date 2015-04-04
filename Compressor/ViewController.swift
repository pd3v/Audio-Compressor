
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

    private let LEVELMETER_REFRESHING_RATE: Float = 0.01
    private let PEAKLEVEL_OFF_RATE: Double = 1.5
    
    var compressor: CompressorInstrument
    var analyzer: AKAudioAnalyzer
    var analysisSequence: AKSequence
    var updateAnalysis: AKEvent
    
    private var timerPeakLevelOff: NSTimer?
    
    required init(coder aDecoder: NSCoder) {
        compressor = CompressorInstrument()
        analyzer = AKAudioAnalyzer()
        analysisSequence = AKSequence()
        updateAnalysis = AKEvent()
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateSliders()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AKOrchestra.addInstrument(compressor)
        analyzer = AKAudioAnalyzer(audioSource: compressor.auxilliaryOutput)
        AKOrchestra.addInstrument(analyzer)
        AKOrchestra.start()
        analyzer.play()
        
        analysisSequence = AKSequence()
        updateAnalysis = AKEvent(block: {
            self.updateLevelMeterUI()
            self.analysisSequence.addEvent(self.updateAnalysis, afterDuration: self.LEVELMETER_REFRESHING_RATE)
        })
        
        analysisSequence.addEvent(updateAnalysis)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        AKOrchestra.reset()
    }

    @IBAction func onOffCompressing(sender: UIButton) {
        if (sender.currentTitle == "Off") {
            analysisSequence.play()
            compressor.play()
            
            sender.setTitle("On", forState: .Normal)
            toggleSliders(on: true)
            
        } else {
            compressor.stop()
            
            // FIXME: To turn off all LevelMeter's leds after audio input is off. Haved tried to empty .events and .times removing entries in both NSMutabelArrays and crashes. Try AKSequence.reset() on AudioKit 2.0.
            analysisSequence.stop() // Eases CPU usage
            
            sender.setTitle("Off", forState: .Normal)
            toggleSliders(on: false)
        }
    }
    
    //MARK: Sliders Data
    
    //TODO: Gain values should be in dB. Find the formula to convert amp(?) into dB
    @IBAction func gainChanged(sender: UISlider) {
        AKTools.setProperty(compressor.gain, withSlider: sender)
        lblGain.text = String(format:"%.1f X", sender.value)
        //println(scaleTodB(compressor))
    }
    
    @IBAction func thresholdChanged(sender: UISlider) {
        AKTools.setProperty(compressor.threshold, withSlider: sender)
        lblThreshold.text = String(format:"%d dB", Int(sender.value))
    }

    @IBAction func compressionRatioChanged(sender: UISlider) {
        AKTools.setProperty(compressor.compRatio, withSlider: sender)
        lblCompRatio.text = String(format:"%.f:1", sender.value)
    }
    
    @IBAction func attackTimeChanged(sender: UISlider) {
        AKTools.setProperty(compressor.attackTime, withSlider: sender)
        lblAttackTime.text = String(format:"%.3f sec", sender.value)
    }
    
    @IBAction func releaseTimeChanged(sender: UISlider) {
        AKTools.setProperty(compressor.releaseTime, withSlider: sender)
        lblReleaseTime.text = String(format:"%.3f sec", sender.value)
    }
    
    //MARK: Update UI
    
    func toggleSliders(#on: Bool) {
        self.view.subviews.filter{ $0 is UISlider }.map{ $0 as UISlider }.map{ $0.enabled = on }
    }
    
    func updateSliders() {
        AKTools.setSlider(sldGain, withProperty: compressor.gain)
        AKTools.setSlider(sldThreshold, withProperty: compressor.threshold)
        AKTools.setSlider(sldCompressionRatio, withProperty: compressor.compRatio)
        AKTools.setSlider(sldAttackTime, withProperty: compressor.attackTime)
        AKTools.setSlider(sldReleaseTime, withProperty: compressor.releaseTime)
        
        lblGain.text = String(format:"%.1f X", compressor.gain.value)
        lblThreshold.text = String(format:"%.f dB", compressor.threshold.value)
        lblCompRatio.text = String(format:"%.f:1", compressor.compRatio.value)
        lblAttackTime.text = String(format:"%.3f sec", compressor.attackTime.value)
        lblReleaseTime.text = String(format:"%.3f sec", compressor.releaseTime.value)
    }
    
    func updateLevelMeterUI() {
        if (analyzer.trackedAmplitude.value > 0.0) {
            levelMeter.level = CGFloat(analyzer.trackedAmplitude.value)
            levelMeter.setNeedsDisplay()
        }
        
        if (Float(levelMeter.peakLevel) < analyzer.trackedAmplitude.value) {
            levelMeter.peakLevel = CGFloat(analyzer.trackedAmplitude.value)
            
            //To turn off the peakLevel led, only the most recent timer prevails
            if ((timerPeakLevelOff?.valid) != nil) { timerPeakLevelOff?.invalidate() }
            timerPeakLevelOff = NSTimer.scheduledTimerWithTimeInterval(PEAKLEVEL_OFF_RATE, target:self, selector: Selector("turnOffPeakLevelLed"), userInfo: nil, repeats: false)
        }
    }
    
    func turnOffPeakLevelLed() {
        levelMeter.peakLevel = 0.0
        levelMeter.setNeedsDisplay()
    }
    
    //TODO: Test if double/float has impact on CPU. See Apple example - "SpeakHere"
    func amplitudeTodB(amplitude: Double) -> Double {
        return 20 * log10(amplitude)
    }
}
