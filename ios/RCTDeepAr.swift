//
//  RCTDeepAr.swift
//  TestModule
//
//  Created by Phuoc tam on 10/16/21.
//

import Foundation
import UIKit
import DeepAR
import AgoraRtcKit

class RCTDeepAr: UIView {
  @IBOutlet weak var arViewContainer: UIView!
  @IBOutlet weak var remoteView: UIView!
  @IBOutlet weak var hangUpButton: UIButton!
  @IBOutlet weak var previousButton: UIButton!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var switchCameraButton: UIButton!
      
  @IBOutlet weak var masksButton: UIButton!
  @IBOutlet weak var effectsButton: UIButton!
  @IBOutlet weak var filtersButton: UIButton!
  
  
  private var deepAr: DeepAR!
  private var arView: ARView!
  private var cameraController: CameraController!
  
  private var maskIndex: Int = 0
  
  var agoraKit: AgoraRtcEngineKit!
  
  override init(frame: CGRect) {
    super.init(frame: frame);
    self.frame = frame;
    self.backgroundColor = UIColor.red.withAlphaComponent(0.4)
    
    initializeAgoraEngine()
    setupVideo()
    setupDeepAR()
    
    setupARCamera()
    joinChannel()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func initializeAgoraEngine() {
    print("initial agora app ID!!!!!!!!!!!!!!!!")
    // init AgoraRtcEngineKit
    agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AgoraAppID, delegate: self)
    //agoraKit.setChannelProfile(.liveBroadcasting)
  }
  
  func setupVideo() {
        // In simple use cases, we only need to enable video capturing
        // and rendering once at the initialization step.
        // Note: audio recording and playing is enabled by default.
        agoraKit.enableVideo()
        agoraKit.setExternalVideoSource(true, useTexture: true, pushMode: true)
        
       
        agoraKit.disableAudio()
        
        // Set video configuration
        // Please go to this page for detailed explanation
        // https://docs.agora.io/cn/Voice/API%20Reference/java/classio_1_1agora_1_1rtc_1_1_rtc_engine.html#af5f4de754e2c1f493096641c5c5c1d8f
        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension1280x720,
                                                                             frameRate: .fps30,
                                                                             bitrate: AgoraVideoBitrateStandard,
                                                                             orientationMode: .adaptative))
    
  }

  func joinChannel() {
        print("join demoChannel1!!!!!!!!!!!!!")
        // 1. Users can only see each other after they join the
        // same channel successfully using the same app id.
        // 2. One token is only valid for the channel name that
        // you use to generate this token.
        
        agoraKit.joinChannel(byToken: nil, channelId: "demoChannel1", info: nil, uid: 0) { [unowned self] (channel, uid, elapsed) -> Void in
            // Did join channel "demoChannel1"
            UIApplication.shared.isIdleTimerDisabled = true
            //self.arView.startFrameOutput(withXmin: 0, xmax: 1, ymin: 0, ymax: 1, scale: 1)
            self.deepAr.startCapture(withOutputWidth: 720, outputHeight: 1280, subframe: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
            
            self.remoteView.isHidden = false
            self.isHidden = false
        }
  }

  func leaveChannel() {
      // leave channel and end chat
      arView.stopFrameOutput()
      agoraKit.leaveChannel(nil)
      
      UIApplication.shared.isIdleTimerDisabled = false
      remoteView.isHidden = true
      self.isHidden = true
      print("***INFO*** did leave channel")
      
      agoraKit = nil
  }
    
  private func setupDeepAR() {
      self.deepAr = DeepAR()
      self.deepAr.setLicenseKey("d4a455b3068cc8814d41316003b9fdcbed42e141ffe3601c0da754b1d7f2cf7a1b2ff4e17d4dc94e")
      self.deepAr.delegate = self
  }
    
  
  private func setupARCamera() {
      //let rect = CGRect(x: 0, y: 0, width: 720, height: 1280)
      self.arView = self.deepAr.createARView(withFrame: self.frame) as! ARView
      self.arView.translatesAutoresizingMaskIntoConstraints = false
      self.addSubview(self.arView)
      self.arView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
      self.arView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
      self.arView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
      self.arView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
     
      self.isHidden = true
     
      self.cameraController = CameraController()
      self.cameraController.deepAR = self.deepAr
      self.cameraController.startCamera()
  }

//    private func setupHangUpButton() {
//        hangUpButton.imageView?.contentMode = .scaleAspectFit
//        hangUpButton.setImage(#imageLiteral(resourceName: "call"), for: .selected)
//        hangUpButton.setImage(#imageLiteral(resourceName: "end"), for: .normal)
//        hangUpButton.isSelected = true
//    }
  
    
    private func updateModeAppearance() {
    }
    
    private func switchMode(_ path: String?) {
    }
    
    @objc
    private func didTapSwitchCameraButton() {
        let position: AVCaptureDevice.Position = cameraController.position == .back ? .front : .back
        cameraController.position = position
    }
    
    @objc
    private func didClickHangUpButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            leaveChannel()
        } else {
            setupARCamera()
            initializeAgoraEngine()
            joinChannel()
        }
    }
}

extension RCTDeepAr: DeepARDelegate {
    func didFinishPreparingForVideoRecording() {}
    
    func didStartVideoRecording() {}
    
    func frameAvailable(_ sampleBuffer: CMSampleBuffer!) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("*** NO BUFFER ERROR")
            return
        }

        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

        let videoFrame = AgoraVideoFrame()
        videoFrame.format = 12
        videoFrame.time = time
        videoFrame.textureBuf = pixelBuffer
        videoFrame.rotation = 0
        
        agoraKit?.pushExternalVideoFrame(videoFrame)
    }
    
    func didFinishVideoRecording(_ videoFilePath: String!) {}
    
    func recordingFailedWithError(_ error: Error!) {}
    
    func didTakeScreenshot(_ screenshot: UIImage!) {}
    
    func didInitialize() {}
    
    func faceVisiblityDidChange(_ faceVisible: Bool) {
    }
}

extension RCTDeepAr: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = remoteView
        // Sets the remote video view
        agoraKit?.setupRemoteVideo(videoCanvas)
    }
    
    
    // first remote video frame
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid:UInt, size:CGSize, elapsed:Int) {
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        remoteView.isHidden = true
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted:Bool, byUid:UInt) {
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("did occur ***WARNING***, code: \(warningCode.rawValue)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("did occur ***ERROR***, code: \(errorCode.rawValue)")
    }
}
