//
//  SubtleVolume.swift
//  SubtleVolume
//
//  Created by Andrea Mazzini on 05/03/16.
//  Copyright © 2016 Fancy Pixel. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

/**
  The style of the volume indicator

 - Plain: A plain bar
 - RoundedLine: A plain bar with rounded corners
 - Dashes: A bar divided in dashes
 - Dots: A bar composed by a line of dots
 */
public enum SubtleVolumeStyle {
  case Plain
  case RoundedLine
  case Dashes
  case Dots
}

/**
 The entry and exit animation of the volume indicator

 - None: The indicator is always visible
 - SlideDown: The indicator fades in/out and slides from/to the top into position
 - FadeIn: The indicator fades in and out
 */
public enum SubtleVolumeAnimation {
  case None
  case SlideDown
  case FadeIn
}

/**
 Delegate protocol fo `SubtleVolume`. 
 Notifies the delegate when a change is about to happen (before the entry animation)
 and when a change occurred (and the exit animation is complete)
 */
public protocol SubtleVolumeDelegate {
  /**
   The volume is about to change. This is fired before performing any entry animation

   - parameter subtleVolume: The current instance of `SubtleVolume`
   - parameter value: The value of the volume (between 0 an 1.0)
   */
  func subtleVolume(subtleVolume: SubtleVolume, willChange value: Float)

  /**
   The volume did change. This is fired after the exit animation is done

   - parameter subtleVolume: The current instance of `SubtleVolume`
   - parameter value: The value of the volume (between 0 an 1.0)
   */
  func subtleVolume(subtleVolume: SubtleVolume, didChange value: Float)
}

/**
 Replace the system volume popup with a more subtle way to display the volume 
 when the user changes it with the volume rocker.
*/
public class SubtleVolume: UIView {

  /**
   The style of the volume indicator
   */
  public var style = SubtleVolumeStyle.Plain

  /**
   The entry and exit animation of the indicator. The animation is triggered by the volume
   If the animation is set to `.None`, the volume indicator is always visible
   */
  public var animation = SubtleVolumeAnimation.None {
    didSet {
      updateVolume(volumeLevel, animated: false)
    }
  }

  public var barBackgroundColor = UIColor.clearColor() {
    didSet {
      backgroundColor = barBackgroundColor
    }
  }

  public var barTintColor = UIColor.whiteColor() {
    didSet {
      overlay.backgroundColor = barTintColor
    }
  }

  public var delegate: SubtleVolumeDelegate?

  private let volume = MPVolumeView(frame: CGRect.zero)
  private let overlay = UIView()
  private var volumeLevel = Float(0)

  convenience public init(style: SubtleVolumeStyle, frame: CGRect) {
    self.init(frame: frame)
    self.style = style
    setup()
  }

  convenience public init(style: SubtleVolumeStyle) {
    self.init(style: style, frame: CGRect.zero)
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  required public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required public init() {
    fatalError("Please use the convenience initializers instead")
  }

  private func setup() {
    do {
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Unable to initialize AVAudioSession")
    }
    updateVolume(AVAudioSession.sharedInstance().outputVolume, animated: false)
    AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: .New, context: nil)

    backgroundColor = .clearColor()

    volume.setVolumeThumbImage(UIImage(), forState: .Normal)
    volume.userInteractionEnabled = false
    volume.alpha = 0.0001
    volume.showsRouteButton = false

    addSubview(volume)

    overlay.backgroundColor = .blackColor()
    addSubview(overlay)
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    overlay.frame = frame
    overlay.frame = CGRect(x: 0, y: 0, width: frame.size.width * CGFloat(volumeLevel), height: frame.size.height)
  }

  private func updateVolume(value: Float, animated: Bool) {
    delegate?.subtleVolume(self, willChange: value)
    volumeLevel = value

    UIView.animateWithDuration(animated ? 0.1 : 0) { () -> Void in
      self.overlay.frame.size.width = self.frame.size.width * CGFloat(self.volumeLevel)
    }

    UIView.animateKeyframesWithDuration(animated ? 2 : 0, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
      UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.2, animations: {
        switch self.animation {
        case .None: break
        case .FadeIn:
          self.alpha = 1
        case .SlideDown:
          self.alpha = 1
          //self.transform = CGAffineTransformIdentity
        }
      })

      UIView.addKeyframeWithRelativeStartTime(0.8, relativeDuration: 0.2, animations: { () -> Void in
        switch self.animation {
        case .None: break
        case .FadeIn:
          self.alpha = 0.0001
        case .SlideDown:
          self.alpha = 0.0001
          //self.transform = CGAffineTransformMakeTranslation(0, -self.frame.height)
        }
      })

      }) { _ in
        self.delegate?.subtleVolume(self, didChange: value)
    }
  }

  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    guard let change = change, value = change["new"] as? Float where keyPath == "outputVolume" else { return }

    updateVolume(value, animated: true)
  }

  deinit {
    AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume", context: nil)
  }

}
