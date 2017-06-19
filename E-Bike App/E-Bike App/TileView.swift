
import UIKit
import QuartzCore
//import Commons

class TileView: UIView {
  
  static var chimesSplashImage: UIImage!
  static let rippleAnimationKeyTimes = [0, 0.61, 0.7, 0.887, 1]
  var shouldEnableRipple = false
  
  convenience init(TileFileName: String) {
    TileView.chimesSplashImage = UIImage(named: TileFileName, in: Bundle(identifier: "com.dtiholdings.e-bike"), compatibleWith: nil)!
    self.init(frame: CGRect.zero)
    frame = CGRect(x: 0, y: 0, width: TileView.chimesSplashImage.size.width, height: TileView.chimesSplashImage.size.height)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
//    layer.contents = TileView.chimesSplashImage.CGImage
    layer.shouldRasterize = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func startAnimatingWithDuration(_ duration: TimeInterval, beginTime: TimeInterval,    rippleDelay: TimeInterval, rippleOffset: CGPoint) {
  }
  
  func stopAnimating() {
    layer.removeAllAnimations()
  }
}
