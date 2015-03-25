
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bttOnOff: UIButton!
    @IBOutlet weak var sldThreshold: UISlider!
    @IBOutlet weak var sldCompressionRatio: UISlider!
    @IBOutlet weak var sldAttackTime: UISlider!
    @IBOutlet weak var sldReleaseTime: UISlider!
    
    @IBOutlet weak var lblThreshold: UILabel!
    @IBOutlet weak var lblCompRatio: UILabel!
    @IBOutlet weak var lblAttackTime: UILabel!
    @IBOutlet weak var lblReleaseTime: UILabel!
    
    let compressor = CompressorInstrument()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AKOrchestra.addInstrument(compressor)
        AKOrchestra.start()
    }
    
    override func viewDidAppear(animated: Bool) {
        lblThreshold.text = String(format:"%.f dB", compressor.threshold.value)
        lblCompRatio.text = String(format:"%.f:1", compressor.compRatio.value)
        lblAttackTime.text = String(format:"%.3f sec", compressor.attackTime.value)
        lblReleaseTime.text = String(format:"%.3f sec", compressor.releaseTime.value)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        AKOrchestra.reset()
    }

    @IBAction func toggleCompressing(sender: UIButton) {
        if (sender.currentTitle == "Off") {
            compressor.play()
            sender.setTitle("On", forState: .Normal)
            
            //! Instead of enabling each one, could do loop through all sliders!
            sldCompressionRatio.enabled = true
            sldThreshold.enabled = true
            sldAttackTime.enabled = true
            sldReleaseTime.enabled = true
            
        } else {
            compressor.stop()
            sender.setTitle("Off", forState: .Normal)
            
            //! Instead of desabling each one, could do loop through all sliders!
            sldCompressionRatio.enabled = false
            sldThreshold.enabled = false
            sldAttackTime.enabled = false
            sldReleaseTime.enabled = false
        }
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
}