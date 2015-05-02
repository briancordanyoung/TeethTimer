
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
    containerView.imageWheel?.rotationAngle = CGFloat(sender.value)
  }
  

}

