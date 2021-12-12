//
//  CarouseProgressView.swift
//  App1
//
//  Created by 李林峰 on 2021/12/1.
//

import UIKit

//MARK: -自定义Progress样式
public enum CarouseProgressStyle{
    case `default`
    case trackFillet
    case allFillet
}

class CarouseProgressView: UIView {
    
    let progressView = UIView()

    public init(frame:CGRect, _ progressViewStyle:CarouseProgressStyle = .default){
        super.init(frame: frame)
        if progressViewStyle == .trackFillet{
            self.layer.masksToBounds = true
            self.layer.cornerRadius = frame.size.height / 2
        }else if progressViewStyle == .allFillet{
            self.layer.masksToBounds = true
            self.layer.cornerRadius = frame.size.height / 2
            progressView.layer.cornerRadius = frame.size.height / 2
        }
        progressView.frame = CGRect(x: 0, y: 0, width: 0, height: self.frame.size.height)
        self.addSubview(self.progressView)
        
    }
    public var progress: CGFloat = 0{
        didSet{
            progress = min(progress,1.0)
            progressView.frame.size = CGSize(width: frame.size.width * progress, height: frame.size.height)
        }
    }
    
    public var progressTintColor: UIColor = .blue {
        didSet{
            progressView.backgroundColor = progressTintColor
        }
    }
    
    public var trackTintColor: UIColor = .white{
        didSet{
            self.backgroundColor  = trackTintColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
