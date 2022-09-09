class YXModal: NSObject {

    /// 获取单例
    public static let `default` = YXModal.init()

    private lazy var alertWindow: UIWindow = {
        let newWindow = UIWindow.init()
        newWindow.frame = UIScreen.main.bounds
        newWindow.isHidden = true
        newWindow.alpha = 1
        newWindow.windowLevel = UIWindow.Level.alert - 10

        newWindow.backgroundColor = UIColor.clear
        return newWindow
    }()

    public override init() {
        super.init()
    }
    enum AlertShowStyle {
        case scale, top, bottom, none
    }

    private var showStyle = AlertShowStyle.scale
}

extension YXModal {

    /// 展示弹框
    ///
    /// - Parameters:
    ///   - alertView: 弹框
    ///   - maskViewColor: 遮罩颜色
    ///   - style: 弹出方式
    ///   - duration: 动画时常
    func showContentView(_ alertView: UIView,
                         maskViewColor: UIColor = UIColor.black.withAlphaComponent(0.7),
                         style: AlertShowStyle = AlertShowStyle.scale,
                         needTouchesClose: Bool = true,
                         duration: Double = 0.3) {
        showStyle = style
        for item in alertWindow.subviews {
            item.removeFromSuperview()
        }
        let root = PHModalViewController.init()
        root.needTouchesClose = needTouchesClose
        alertWindow.rootViewController =  root
        alertWindow.rootViewController?.view.backgroundColor = maskViewColor
        alertWindow.makeKeyAndVisible()
        alertWindow.addSubview(alertView)
        alertView.center = alertWindow.center

        let startTransform: CGAffineTransform
        let endTransform: CGAffineTransform
        var satrtAlpha: CGFloat = 1.0
        var endAlpha: CGFloat = 1.0


        if style == .top {
            startTransform = CGAffineTransform.init(translationX: 0, y: -(ScreenHeight))
            endTransform = CGAffineTransform.identity
        } else if style == .bottom {
            startTransform = CGAffineTransform.init(translationX: 0, y: ScreenHeight)
            endTransform = CGAffineTransform.identity
        } else  if style == .scale {
            startTransform = CGAffineTransform.init(scaleX: 0, y: 0)
            endTransform = CGAffineTransform.init(scaleX: 1, y: 1)
        } else {
            startTransform = CGAffineTransform.init(scaleX: 1, y: 1)
            endTransform = CGAffineTransform.init(scaleX: 1, y: 1)
            satrtAlpha = 0.0
            endAlpha = 1.0
        }

        alertView.transform = startTransform
        alertView.alpha = satrtAlpha
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {
                        alertView.transform = endTransform
                        alertView.alpha = endAlpha
                       }, completion: { (_) in

                       })

    }
    /// 关闭
    func hiden(_ result: (() -> Void)? = nil) {

        let duration: Double
        let endTransform: CGAffineTransform
        if showStyle == .top {
            duration = 0.5
            endTransform = CGAffineTransform.init(translationX: 0, y: -(ScreenHeight))
        } else if showStyle == .bottom {
            duration = 0.5
            endTransform = CGAffineTransform.init(translationX: 0, y: ScreenHeight)
        } else {
            duration = 0.2
            endTransform = CGAffineTransform.init(scaleX: 0, y: 0)
        }

        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {[weak self] in
                        self?.alertWindow.transform = endTransform
                       }, completion: { [weak self] (_) in

                        self?.cleanup()
                        result?()
                       })

    }

    private func cleanup() {
        for item in alertWindow.subviews {
            item.removeFromSuperview()
        }
        alertWindow.isHidden = true
        alertWindow.transform = CGAffineTransform.identity
    }

}

// MARK: - rootVC
fileprivate class PHModalViewController: UIViewController {
    var needTouchesClose: Bool = true
    override func loadView() {
        view = UIView.init(frame: UIScreen.main.bounds)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue |
                                                            UIView.AutoresizingMask.flexibleHeight.rawValue)
    }
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if needTouchesClose {
            YXModal.default.hiden()
        }
    }
    deinit {
        print("modal vc dealloc")
    }

}
