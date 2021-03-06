//
//  WaveView.swift
//  Sin-CABasicAnimation
//
//  Created by 大西玲音 on 2021/08/18.
//

import UIKit

final class WaveView: UIView {
    
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var middleView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    
    private func loadNib() {
        guard let view = UINib(
            nibName: String(describing: type(of: self)),
            bundle: nil
        ).instantiate(
            withOwner: self,
            options: nil
        ).first as? UIView else {
            return
        }
        view.frame = self.bounds
        self.addSubview(view)
        
        view.backgroundColor = .clear
        topView.backgroundColor = .clear
        middleView.backgroundColor = .clear
        bottomView.backgroundColor = .clear
        
    }
    
    func create() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.cutToWaveView()
        }
    }
    
    private func cutToWaveView() {
        let marginY: CGFloat = 50
        let topInfo = WaveViewInfo(waveCount: 1,
                                   amplitude: 1,
                                   color: .systemPurple.withAlphaComponent(0.3),
                                   math: .plusSin,
                                   marginY: marginY)
        topView.cutView(info: topInfo)
        let middleInfo = WaveViewInfo(waveCount: 1.5,
                                      amplitude: 1.3,
                                      color: .systemPurple.withAlphaComponent(0.5),
                                      math: .plusCos,
                                      marginY: marginY + 10)
        middleView.cutView(info: middleInfo)
        let bottomInfo = WaveViewInfo(waveCount: 1,
                                      amplitude: 1.5,
                                      color: .systemPurple.withAlphaComponent(0.8),
                                      math: .minusCos,
                                      marginY: marginY + 10)
        bottomView.cutView(info: bottomInfo)
    }
    
}

struct WaveViewInfo {
    let waveCount: Double
    let amplitude: Double
    let color: UIColor
    let math: Math
    let marginY: CGFloat
}

enum Math {
    case minusSin
    case minusCos
    case plusSin
    case plusCos
    
    func trigonometricFunc(_ x: Double) -> Double {
        switch self {
            case .minusSin: return -sin(x)
            case .minusCos: return -cos(x)
            case .plusSin: return sin(x)
            case .plusCos: return cos(x)
        }
    }
}

private extension UIView {
    
    func cutView(info: WaveViewInfo) {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 0,
                             y: 0,
                             width: self.frame.width,
                             height: self.frame.height)
        layer.fillColor = info.color.cgColor
        layer.strokeColor = info.color.cgColor
        layer.lineWidth = 3
        layer.path = createSinPath(layer: layer, info: info)
        if let layer = self.layer.sublayers?.first {
            layer.removeFromSuperlayer()
        }
        self.layer.addSublayer(layer)
    }
    
    private func createSinPath(layer: CAShapeLayer, info: WaveViewInfo) -> CGPath {
        let div: Double = 1 / 100
        let sinPath = UIBezierPath()
        let originX: CGFloat = layer.lineWidth
        let origin = CGPoint(x: -originX,
                             y: layer.frame.height / 2 + info.marginY)
        let count = info.waveCount * 2
        let xRatioToFill = Double(layer.frame.width) / (Double.pi / div)
        sinPath.move(to: CGPoint(x: origin.x, y: 0))
        sinPath.addLine(to: CGPoint(x: origin.x, y: origin.y))
        for i in 0...Int(Double.pi / div * count) {
            let x = div * Double(i)
            let y = info.math.trigonometricFunc(x)
            sinPath.addLine(
                to: CGPoint(x: (x / div / count + Double(origin.x)) * xRatioToFill + Double(originX * 2),
                            y: Double(origin.y) * (1 - y * info.amplitude / 10))
            )
        }
        sinPath.addLine(to: CGPoint(x: layer.frame.width + originX, y: 0))
        return sinPath.cgPath
    }
    
}


