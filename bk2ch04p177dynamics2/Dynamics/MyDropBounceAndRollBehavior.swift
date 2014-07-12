
import UIKit

class MyDropBounceAndRollBehavior : UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    let v : UIView
    
    init(view v:UIView) {
        self.v = v
        super.init()
    }
    
    override func willMoveToAnimator(anim: UIDynamicAnimator!) {
        if (!anim) { return }
        
        let sup = self.v.superview
        
        let grav = UIGravityBehavior()
        grav.action = {
            // self will retain grav so do not let grav retain self!
            [weak self] in
            if let sself = self {
                let items = anim.itemsInRect(sup.bounds) as [UIView]
                if !find(items, sself.v) {
                    anim.removeBehavior(sself)
                    sself.v.removeFromSuperview()
                    println("done")
                }
            }
        }
        self.addChildBehavior(grav)
        grav.addItem(self.v)

        let push = UIPushBehavior(items:[self.v], mode:.Instantaneous)
        push.pushDirection = CGVectorMake(2, 0)
        // [push setTargetOffsetFromCenter:UIOffsetMake(0, -200) forItem:self.iv];
        self.addChildBehavior(push)

        let coll = UICollisionBehavior()
        coll.collisionMode = .Boundaries
        coll.collisionDelegate = self
        coll.addBoundaryWithIdentifier("floor",
            fromPoint:CGPointMake(0, sup.bounds.size.height),
            toPoint:CGPointMake(sup.bounds.size.width,
                sup.bounds.size.height))
        self.addChildBehavior(coll)
        coll.addItem(self.v)
        
        let bounce = UIDynamicItemBehavior()
        bounce.elasticity = 0.4
        self.addChildBehavior(bounce)
        bounce.addItem(self.v)

    }
    
    func collisionBehavior(behavior: UICollisionBehavior!,
        beganContactForItem item: UIDynamicItem!,
        withBoundaryIdentifier identifier: NSCopying!,
        atPoint p: CGPoint) {
            println(p)
            // look for the dynamic item behavior
            for b in self.childBehaviors as [UIDynamicBehavior] {
                if let bounce = b as? UIDynamicItemBehavior {
                    let v = bounce.angularVelocityForItem(item)
                    println(v)
                    if v <= 0.1 {
                        println("adding angular velocity")
                        bounce.addAngularVelocity(30, forItem:item)
                    }
                    break;
                }
            }
    }
    
    deinit {
        println("farewell") // prove we are being deallocated in good order
    }
    
}
