//
//  SubjectOtherViewController.swift
//  ProjectSwiftDemo
//
//  Created by 张书孟 on 2018/9/7.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit
import MJRefresh

class SubjectOtherViewController: BaseViewController {

    private lazy var collectionView: UICollectionView = {
        
        let itemWidth = (UIScreen.width - 40.wpx) / (isPad() ? 2 : 1)
        
        let flowLayout = UICollectionViewFlowLayout().chain
            .itemSize(width: itemWidth - 10, height: 182.hpx)
            .sectionInset(top: 12.hpx, left: 0, bottom: 12.hpx, right: 0)
            .build
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout).chain
            .backgroundColor(UIColor.white)
            .contentInset(top: 0, left: 20.wpx, bottom: 0, right: 20.wpx)
            .delegate(self)
            .dataSource(self)
            .register(SubjectOtherCell.self, forCellWithReuseIdentifier: "SubjectOtherCell")
            .build
    }()
    
    private var dataSource: [SubjectListModel] = [SubjectListModel]()
    private var page: Int = 0
    
    let sourceCode: String
    
    init(sourceCode: String = "") {
        
        self.sourceCode = sourceCode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

}

extension SubjectOtherViewController {
    private func setupUI() {
        disablesAdjustScrollViewInsets(collectionView)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuideBottom)
            make.left.bottom.right.equalToSuperview()
        }
        
        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.page = 0
            self?.requestData()
        })
        
        collectionView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: { [weak self] in
            self?.page += 1
            self?.requestData()
        })
        
        collectionView.mj_header.beginRefreshing()
    }
}

extension SubjectOtherViewController {
    private func requestData() {
        Toast.loading()
        requestSubjectList(page: page, sourceCode: sourceCode, cacheCompletion: { (cacheModel) in
            if self.collectionView.mj_header.isRefreshing {
                self.dataSource = cacheModel
                self.collectionView.reloadData()
            }
        }, successCompletion: { (models) in
            Toast.hide()
            if self.collectionView.mj_header.isRefreshing {
                self.collectionView.mj_header.endRefreshing()
                self.dataSource.removeAll()
            }
            if self.collectionView.mj_footer.isRefreshing {
                self.collectionView.mj_footer.endRefreshing()
            }
            self.dataSource += models
            self.collectionView.reloadData()
        }) { (error) in
            if self.collectionView.mj_header.isRefreshing {
                self.collectionView.mj_header.endRefreshing()
            }
            if self.collectionView.mj_footer.isRefreshing {
                self.collectionView.mj_footer.endRefreshing()
            }
            Toast.show(info: error)
        }
    }
}

extension SubjectOtherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SubjectOtherCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubjectOtherCell", for: indexPath) as! SubjectOtherCell
        cell.update(model: dataSource[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}


