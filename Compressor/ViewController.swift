//
//  ViewController.swift
//  SwiftHarmonizer
//
//  Created by Nicholas Arner on 10/7/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let compressor = CompressorInstrument();
    let sampler = AKSampler();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AKOrchestra.addInstrument(compressor)
        AKOrchestra.start()
        
        compressor.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startRecording(sender: AnyObject) {
        compressor.play()
        sampler.startRecordingToTrack("harmonizer")
    }
    
    @IBAction func stopRecording(sender: AnyObject) {
        compressor.stop()
        sampler.stopRecordingToTrack("harmonizer")
    }
    
    @IBAction func startPlaying(sender: AnyObject) {
        sampler.startPlayingTrack("harmonizer")
    }

    @IBAction func stopPlaying(sender: AnyObject) {
        sampler.stopPlayingTrack("harmonizer")
    }
}