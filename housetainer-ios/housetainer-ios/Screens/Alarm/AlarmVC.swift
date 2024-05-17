//
//  AlarmVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/9/24.
//

import UIKit
import SnapKit
import Combine

final class AlarmVC: UIViewController {
    
    private let viewModel = AlarmVM()
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var alarmTable: UITableView = {
        let tableView = UITableView()
        tableView.register(AlarmCell.self, forCellReuseIdentifier: AlarmCell.id)
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.tableFooterView = loadingIndicator
        tableView.tableFooterView?.isHidden = true
        return tableView
    }()
    
    private lazy var emptyView: UIStackView = {
        let image = UIImageView(image: Icon.bigAlarm)
        image.contentMode = .scaleAspectFit
        let titleLabel = LabelFactory.build(text: "아직은 알림이 없어요!", font: Typo.Heading2(), textColor: Color.gray800)
        let subtitleLabel = LabelFactory.build(text: "새로운 소식이 도착하면 바로 알려드릴게요 :)", font: Typo.Body2(), textColor: Color.gray600)
        let stackView = UIStackView(arrangedSubviews: [image, titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.setCustomSpacing(20, after: image)
        stackView.setCustomSpacing(4, after: titleLabel)
        return stackView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = Color.purple400
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        setupNavigationBar()
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.fetchAlarms()
        }
    }
}

extension AlarmVC {
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: Icon.arrowLeft, style: .plain, target: self, action: #selector(didTapBackButton))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        let titleView = LabelFactory.build(text: "알림", font: Typo.Heading2())
        navigationItem.titleView = titleView
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        [alarmTable, emptyView].forEach {
            view.addSubview($0)
        }

        alarmTable.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bind() {
        viewModel.alarms
            .receive(on: RunLoop.main)
            .sink { [weak self] alarms in
                guard let self, let alarms else { return }
                if alarms.isEmpty  {
                    emptyView.isHidden = false
                    alarmTable.isHidden = true
                } else {
                    emptyView.isHidden = true
                    alarmTable.isHidden = false
                    alarmTable.reloadData()
                }
            }
            .store(in: &subscriptions)
    }
}

extension AlarmVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

extension AlarmVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.alarms.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmCell.id, for: indexPath) as? AlarmCell else { return UITableViewCell() }
        if let alarm = viewModel.alarms.value?[indexPath.item] {
            cell.configure(with: alarm)
        }
        cell.selectionStyle = .none
        return cell
    }
}

extension AlarmVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        // 스크롤이 가능하고 (contentHeight > height),
        // 테이블 끝에 도달했고 (offsetY > contentHeight - height),
        // 네트워킹 중이 아니면서 (viewModel.isFetching == false),
        // fetch할 데이터가 남았을 때 (viewModel.hasMoreData == true)
        if contentHeight > height && offsetY > (contentHeight - height - alarmTable.contentInset.bottom) && !viewModel.isFetching && viewModel.hasMoreData {
            viewModel.isFetching = true
            loadingIndicator.startAnimating()
            alarmTable.tableFooterView?.isHidden = false

            Task {
                await viewModel.fetchMoreAlarms()
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.alarmTable.tableFooterView?.isHidden = true
                    self.viewModel.isFetching = false
                }
            }
        }
    }
}
