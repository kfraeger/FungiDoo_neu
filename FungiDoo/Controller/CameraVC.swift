//
//  CameraVC.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 19.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol CameraInputChangeDelegate {
    
    func userTookANewPhoto(image : UIImage)
    
}

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    //MARK: - var & let
    /***************************************************************/
    
    var captureSession = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()
    var delegate : CameraInputChangeDelegate?
    var squareImage : UIImage?
    
    //MARK: IBOutlets
    /***************************************************************/

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var switchButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewImageView.layer.masksToBounds = true
        previewImageView.clipsToBounds = true
        setupCaptureSession()
        
    }
    
    //MARK: IBActions
    /***************************************************************/
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        savePhoto()
        
        guard let image = squareImage else { return }
        delegate?.userTookANewPhoto(image: image)
        self.dismiss(animated: true, completion: nil)
    
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        takePhoto()
    }
    
    @IBAction func cameraSwitchButtonPressed(_ sender: UIButton) {
        switchCamera()
    }
    
    //MARK: methods
    /***************************************************************/
    
    private func squareImageFromImage(inputImage: UIImage) -> UIImage? {
        
        var imageHeight = inputImage.size.height
        var imageWidth = inputImage.size.width
        
        if imageHeight > imageWidth {
            imageHeight = imageWidth
        }
        else {
            imageWidth = imageHeight
        }
        
        let size = CGSize(width: imageWidth, height: imageHeight)
        
        let refWidth : CGFloat = CGFloat(inputImage.cgImage!.width)
        let refHeight : CGFloat = CGFloat(inputImage.cgImage!.height)
        
        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2
        
        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        if let imageRef = inputImage.cgImage!.cropping(to: cropRect) {
            
            squareImage = UIImage(cgImage: imageRef, scale: 0, orientation: inputImage.imageOrientation)
            
            return squareImage
        }
        
        return nil
        
    }
    
    func setupCaptureSession (){
        
        //CaptureSessiont
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        //InputDevice
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        do {
            guard let device = captureDevice else { return }
            let input = try AVCaptureDeviceInput(device: device)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
        } catch {
            print(error)
        }
        
        //Output
        photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = .resizeAspectFill
        cameraPreviewLayer.connection?.videoOrientation = .portrait
        cameraPreviewLayer.frame = previewImageView.frame
        
        view.layer.insertSublayer(cameraPreviewLayer, at: 0)
        
        //session starten
        captureSession.startRunning()
        
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String : previewFormatType]
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            previewImageView.image = UIImage(data: imageData)
            doneButton.isEnabled = true
            switchButton.isEnabled = false
        }
    }
   
    
    func savePhoto(){
        let library = PHPhotoLibrary.shared()
        guard let image = previewImageView.image else { return }
        
        guard let squareImage = squareImageFromImage(inputImage: image) else { return }
        
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: squareImage)
        }) { (success, error) in
            if error != nil {
                print("Bild konnte NICHT gespeichert werden. --- savePhoto()")
                return
            } else {
                print("Bild konnte gespeichert werden. --- savePhoto()")
            }
        }
    }
    
    //Switching beetween front and back camera
    func switchCamera(){
        
        guard let input = captureSession.inputs[0] as? AVCaptureDeviceInput else { return }
        
        captureSession.beginConfiguration()
        defer {captureSession.commitConfiguration()}
        var newDevice : AVCaptureDevice?
        
        if input.device.position == .back {
            newDevice = captureDevice(with: .front)
        } else {
            newDevice = captureDevice(with: .back)
        }
        
        var deviceInput : AVCaptureDeviceInput!
        
        do {
            guard let device = newDevice else { return }
            deviceInput = try AVCaptureDeviceInput(device: device)
        } catch {
            print("error switchCamera")
        }
        
        captureSession.removeInput(input)
        captureSession.addInput(deviceInput)
        
    }
    
    //check which camera device is active
    func captureDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
        
        for device in devices {
            if device.position  == position {
                return device
            }
        }
        return nil
    }

}
