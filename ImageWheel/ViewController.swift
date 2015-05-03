
import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var containerView: ContainerView!
  
  @IBOutlet weak var slider: UISlider!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  @IBAction func sliderChanged(sender: UISlider) {
    let width = containerView.imageWheel!.wedgeWidthAngle
    containerView.imageWheel?.rotationAngle = Circle().DegreesToRadians(CGFloat(sender.value)) + (width / 2)
  }
  

}

