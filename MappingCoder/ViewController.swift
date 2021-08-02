//
//  ViewController.swift
//  MappingCoder
//
//  Created by Wang Guanyu on 2021/7/18.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var modelTypeStructButton: NSButton!
    @IBOutlet weak var modelTypeClassButton: NSButton!
    @IBOutlet weak var optionalButton: NSButton!

    private var settings = Settings()

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: - Private Method

    private func updateUI() {
        let isStruct = settings.modelType == .struct
        modelTypeStructButton.state = isStruct ? .on : .off
        modelTypeClassButton.state = isStruct ? .off : .on
        optionalButton.state = settings.optional ? .on : .off
    }

    @IBAction func didChangeModeType(_ sender: NSButton) {
        switch sender.tag {
        case 0:
            settings.modelType = .struct
        case 1:
            settings.modelType = .class
        default: break
        }
    }

    @IBAction func didSelectOptionalType(_ sender: NSButton) {
        settings.optional = sender.state == .on
    }

}

