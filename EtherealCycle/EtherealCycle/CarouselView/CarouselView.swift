//
//  CarouselView.swift
//  App1
//
//  Created by 李林峰 on 2021/12/1.
//

import UIKit

private struct CarouselViewConst {
    static let cellIndentifier = "CarouselViewCellId"
    static let pageControlHeight: CGFloat = 6
    static let pageProcessWidth: CGFloat = 100
    static let pageControlSpacing: CGFloat = 6
}

public enum CarousePageControlLocation {
    case LeftBottom(leading: CGFloat, bottom: CGFloat)
    case CenterBottom(bottom: CGFloat)
    case RightBottom(trailing: CGFloat, bottom: CGFloat)
}

@objc public protocol CarouselViewDelegate: NSObjectProtocol {
    //图片点击
    @objc optional func carouselView(carouselView: CarouselView, didSelectItemAt index: Int)
    //自定义cell
    @objc optional func carouselView(carouselView: CarouselView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, picture: String) -> UICollectionViewCell?

}

public class CarouselView: UIView {
    //MARK: -私人属性
    private lazy var pageControlView: UIView = {
        let vi = UIView(frame: CGRect.zero)
        vi.backgroundColor = .clear

        return vi
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = bounds.size
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CarouselViewCell.self, forCellWithReuseIdentifier: CarouselViewConst.cellIndentifier)

        return collectionView
    }()
    private lazy var timer: CADisplayLink = {
        let timer = CADisplayLink(target: self, selector: #selector(updateAutoScrolling))
        timer.add(to: RunLoop.current, forMode: .common)
        return timer
    }()

    private var pageProcess: [CarouseProgressView] = []
    private var isCustomCell = false
    private var currentIndex = 0 //当前位置

    private let pageLocation: CarousePageControlLocation
    private let image:[String]
    private let placeHolderImage: UIImage
    private let autoScrollDelay: TimeInterval

    //MARK: -私有方法
    private func initCollectionView(){
        guard image.count > 0 else { return }
        collectionView.reloadData()
        collectionView.isScrollEnabled = image.count > 1
        let indexPath = IndexPath(item: 1, section: 0)  //初始item为1
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        if image.count > 1 {
            timer.isPaused = false
        }else {
            timer.isPaused = true
            timer.invalidate()
        }
    }

    private func initPageControlView() {
        let width = CGFloat(image.count - 1) * CarouselViewConst.pageControlHeight + CarouselViewConst.pageProcessWidth * 2
        pageControlView.frame = CGRect(x: 0, y: 0, width: width, height: CarouselViewConst.pageControlHeight)
        let screen = UIScreen.main.bounds
        switch pageLocation {
        case .LeftBottom(let leading, let bottom):
            pageControlView.center.x = width / 2 + leading
            pageControlView.center.y = bounds.height - CarouselViewConst.pageControlHeight / 2 - bottom
        case .CenterBottom(let bottom):
            pageControlView.center.x = screen.width / 2
            pageControlView.center.y = bounds.height - CarouselViewConst.pageControlHeight / 2 - bottom
        case .RightBottom(let trailing, let bottom):
            pageControlView.center.x = bounds.height - width / 2 - trailing
            pageControlView.center.y = bounds.height - CarouselViewConst.pageControlHeight / 2 - bottom
        }

        for i in 0..<image.count {
            let proFrame: CGRect
            if i == 0 {
                proFrame = CGRect(x: 0, y: 0, width: CarouselViewConst.pageProcessWidth, height: CarouselViewConst.pageControlHeight)
            }else {
                let x = CGFloat(i-1) * (CarouselViewConst.pageControlHeight + CarouselViewConst.pageControlSpacing) + CarouselViewConst.pageProcessWidth + CarouselViewConst.pageControlSpacing
                proFrame = CGRect(x: x, y: 0, width: CarouselViewConst.pageControlHeight, height: CarouselViewConst.pageControlHeight)
            }
            let pro = CarouseProgressView(frame: proFrame, .trackFillet)
            pro.trackTintColor = .white
            pro.progress = 0
            pageControlView.addSubview(pro)
            pageProcess.append(pro)
        }
    }

    //MARK: -公有属性
    public weak var delegate: CarouselViewDelegate?

    public var pageIndicatorTintColor: UIColor = UIColor.red {
        didSet{
            pageProcess.enumerated().forEach{ index,view in
                view.progressTintColor = pageIndicatorTintColor
            }
        }
    }

     public init(_ frame: CGRect,
                _ image:[String],
                placeHolderImage:UIImage,
                pageLocation: CarousePageControlLocation = .LeftBottom(leading: 15, bottom: 15),
                autoScrollDelay: TimeInterval = 3){
        self.image = image
        self.pageLocation = pageLocation
        self.placeHolderImage = placeHolderImage
        self.autoScrollDelay = autoScrollDelay

        super.init(frame: frame)

        initCollectionView()
        addSubview(collectionView)
        initPageControlView()
        addSubview(pageControlView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func removeFromSuperview() {
        super.removeFromSuperview()
        timer.isPaused = true
        timer.invalidate()
    }


}

//MARK: - 轮播核心
extension CarouselView {
    @objc private func updateAutoScrolling() {
        pageProcess[currentIndex].progress += CGFloat((1.0 / (autoScrollDelay * 60)))
        if pageProcess[currentIndex].progress >= 1.0 {
            pageProcess[currentIndex].progress = 0
            timer.isPaused = true
            if let indexPath = collectionView.indexPathsForVisibleItems.last {
                let nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
                collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
            }
            timer.isPaused = false
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer.isPaused = true
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        timer.isPaused = false
    }


    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //特殊情况
        let page = Int(scrollView.contentOffset.x / bounds.size.width)
        let itemCount = collectionView.numberOfItems(inSection: 0)
        if scrollView.contentOffset.x < 1 {
            let indexPath = IndexPath(item: itemCount - 2, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }else if page == itemCount - 1 {
            let indexPath = IndexPath(item: 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }

        let newPage = Int(scrollView.contentOffset.x / bounds.size.width) - 1
        if newPage < 0 {
            currentIndex = image.count - 1
        }else {
            currentIndex = newPage
        }
        pageProcess.enumerated().forEach{ index,view in
            view.progress = 0
            if index == newPage {
                view.frame.size = CGSize(width: CarouselViewConst.pageProcessWidth,
                                         height: CarouselViewConst.pageControlHeight)
            }else {
                view.frame.size = CGSize (width: CarouselViewConst.pageControlHeight,
                                          height: CarouselViewConst.pageControlHeight)
            }
            if index <= newPage {
                view.frame.origin = CGPoint(x: CGFloat(index) * (CarouselViewConst.pageControlHeight + CarouselViewConst.pageControlSpacing), y: 0.0)
            }else {
                let x = CGFloat(index-1) * (CarouselViewConst.pageControlHeight + CarouselViewConst.pageControlSpacing) + CarouselViewConst.pageProcessWidth + CarouselViewConst.pageControlSpacing
                view.frame.origin = CGPoint(x: x, y: 0.0)
            }

        }
    }


}

extension CarouselView: UICollectionViewDelegate,UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return image.count + 2
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let newIndexPath: IndexPath
        if indexPath.row == 0 {
            newIndexPath = IndexPath(item: image.count - 1, section: indexPath.section)
        }else if indexPath.row == image.count + 1 {
            newIndexPath = IndexPath(item: 0, section: indexPath.section)
        }else {
            newIndexPath = IndexPath(item: indexPath.row - 1, section: indexPath.section)
        }
        if isCustomCell {
            return delegate?.carouselView?(carouselView: self, collectionView: collectionView, cellForItemAt: newIndexPath, picture: image[newIndexPath.row]) ?? UICollectionViewCell()
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselViewConst.cellIndentifier, for: newIndexPath) as! CarouselViewCell
            cell.configureCell(picture: image[newIndexPath.row],placeholderImage: placeHolderImage, imgViewWidth: bounds.width)
            return cell
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.carouselView?(carouselView: self, didSelectItemAt: indexPath.row - 1)
    }
}

fileprivate class CarouselViewCell: UICollectionViewCell {
    private lazy var imgView: UIImageView = {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: imgViewWidth, height: bounds.height))
        return imgView
    }()

    private var imgViewWidth: CGFloat = UIScreen.main.bounds.width {
        didSet{
            if imgViewWidth != UIScreen.main.bounds.width {
                imgView.frame.size.width = imgViewWidth
                imgView.center.x = bounds.width/2
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imgView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func configureCell(picture: String, placeholderImage: UIImage? = nil, imgViewWidth: CGFloat = UIScreen.main.bounds.width) {

        imgView.image = UIImage(named: picture) ?? placeholderImage


        self.imgViewWidth = imgViewWidth
    }

}

extension UIImage {
    class func creatImageWithColor(color:UIColor)->UIImage{
           let rect = CGRect(x:0,y:0,width:1,height:1)
           UIGraphicsBeginImageContext(rect.size)
           let context = UIGraphicsGetCurrentContext()
           context?.setFillColor(color.cgColor)
           context!.fill(rect)
           let image = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           return image!
    }
}

