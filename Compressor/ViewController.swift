
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bttOnOff: UIButton!
    
    let compressor = CompressorInstrument()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AKOrchestra.addInstrument(compressor)
        AKOrchestra.start()
        
        //println(aA.trackedAmplitude)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleCompressing(sender: UIButton) {
        if (sender.currentTitle == "Off") {
            compressor.play()
            //compressor.buildUp()
            sender.setTitle("On", forState: .Normal)
        } else {
            compressor.stop()
            //println(compressor.audioAmplitude!.trackedAmplitude)
            sender.setTitle("Off", forState: .Normal)
        }
    }
    
}