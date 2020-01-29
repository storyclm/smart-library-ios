//
//  BatchLoadingView.swift
//  StoryCLM
//
//  Created by Sergey Ryazanov on 26.11.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import StoryContent

public class BatchLoadingView: UIView {

    private class ProgressModel {
        var progressText: String?
        var currentLoadText: String?
    }

    // MARK: - Private
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let progressLabel = UILabel()
    private let currentLoadingLabel = UILabel()

    private var currentCount: Int = 0 {
        didSet {
            self.updateProgressText()
        }
    }

    private var totalCount: Int? {
        didSet {
            self.updateProgressText()
        }
    }

    private var progressModel = ProgressModel()

    // MARK: - Public
    let loader = BatchLoaderView()
    public let closeButton = UIButton()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    // MARK: - Setup

    func setup() {
        self.addSubview(self.loader)
        self.addLabels()
        self.addCancelButton()

        self.updateAppearance()
    }

    private func addLabels() {
        [titleLabel, subtitleLabel, progressLabel, currentLoadingLabel].forEach { (label) in
            label.backgroundColor = UIColor.clear
            label.textAlignment = NSTextAlignment.center
            label.numberOfLines = 2
            self.addSubview(label)
        }
    }

    private func addCancelButton() {
        let cancelTextColor = UIColor(named: "BatchLoaderCancelText")

        self.closeButton.setTitle("Отмена", for: UIControl.State.normal)
        self.closeButton.setTitleColor(cancelTextColor, for: UIControl.State.normal)
        self.closeButton.setTitleColor(cancelTextColor?.withAlphaComponent(0.75), for: UIControl.State.highlighted)
//        self.addSubview(closeButton)
    }

    // MARK: - Layout

    override public func layoutSubviews() {
        super.layoutSubviews()

        self.closeButton.sizeToFit()
        self.closeButton.frame = {
            var rect = self.closeButton.bounds
            rect.origin.x = (self.frame.width - rect.width) * 0.5
            rect.origin.y = self.frame.height - rect.height - 50.0
            return rect
        }()

        var sideOffset: CGFloat = 10.0
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            sideOffset = 50.0
        }
        let maxWidth: CGFloat = self.frame.width - sideOffset * 2.0
        let fitSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)

        self.titleLabel.frame = {
            var rect = CGRect.zero
            rect.size.width = maxWidth
            rect.size.height = self.titleLabel.sizeThatFits(fitSize).height
            rect.origin.x = (self.frame.width - rect.width) * 0.5
            rect.origin.y = (self.frame.height - rect.height) * 0.5
            return rect.integral
        }()

        self.subtitleLabel.frame = {
            var rect = CGRect.zero
            rect.size.width = maxWidth
            rect.size.height = self.subtitleLabel.sizeThatFits(fitSize).height
            rect.origin.x = (self.frame.width - rect.width) * 0.5
            rect.origin.y = self.titleLabel.frame.maxY + 16.0
            return rect
        }()

        self.progressLabel.frame = {
            var rect = CGRect.zero
            rect.size.width = maxWidth
            rect.size.height = self.progressLabel.sizeThatFits(fitSize).height
            rect.origin.x = (self.frame.width - rect.width) * 0.5
            rect.origin.y = self.subtitleLabel.frame.maxY + 32.0
            return rect
        }()

        self.currentLoadingLabel.frame = {
            var rect = CGRect.zero
            rect.size.width = maxWidth
            rect.size.height = self.currentLoadingLabel.sizeThatFits(fitSize).height
            rect.origin.x = (self.frame.width - rect.width) * 0.5
            rect.origin.y = self.progressLabel.frame.maxY + 32.0
            return rect
        }()

        self.loader.frame = {
            var rect = CGRect.zero
            rect.size = self.loader.preferredSize
            rect.origin.x = (self.frame.width - rect.width) * 0.5
            rect.origin.y = (self.titleLabel.frame.minY - rect.size.height) * 0.5
            return rect
        }()
    }

    // MARK: - Progress

    public func increaseProgressText() {
        self.currentCount += 1
    }
    
    public func setProgress(current: Int, total: Int?) {
        self.totalCount = total
        self.currentCount = current
    }

    public func updateProgressText() {
        var text = "\(currentCount)"
        if let total = totalCount {
            text += "/\(total)"
        }

        self.setProgressText(text)
    }

    private func setProgressText(_ text: String?) {
        DispatchQueue.main.async {[weak self] in
            self?.progressModel.progressText = text
            self?.updateLabelAppearance()
        }
    }

    public func setLoadingText(_ text: String?) {
        DispatchQueue.main.async {[weak self] in
            self?.progressModel.currentLoadText = text
            self?.updateLabelAppearance()
        }
    }

    // MARK: - Appearance

    func updateAppearance() {
        self.backgroundColor = UIColor.white
        self.updateLabelAppearance()
    }

    func updateLabelAppearance() {
        let textColor = UIColor.darkGray

        self.titleLabel.numberOfLines = 2
        let titleBuilder = NSAttributedStringBuilder(font: UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.bold),
                                                     color: textColor,
                                                     alignment: NSTextAlignment.center,
                                                     kern: 0.36)
            .changeParagraphStyle(minimumLineHeight: 33.0)
            .add("Обновление презентации")
        self.titleLabel.attributedText = titleBuilder.result()

        self.subtitleLabel.numberOfLines = 3
        let subtitleBuilder = NSAttributedStringBuilder(font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.regular),
                                                        color: textColor,
                                                        alignment: NSTextAlignment.center,
                                                        kern: -0.41)
            .changeParagraphStyle(minimumLineHeight: 20.0)
            .add("В настоящее время выполняется системное обновление для корректной работы презентации!")
        self.subtitleLabel.attributedText = subtitleBuilder.result()

        self.progressLabel.numberOfLines = 2
        let progressBuilder = NSAttributedStringBuilder(font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.regular),
                                                        color: textColor,
                                                        alignment: NSTextAlignment.center,
                                                        kern: -0.41)
            .changeParagraphStyle(minimumLineHeight: 20.0)
            .add(self.progressModel.progressText)
        self.progressLabel.attributedText = progressBuilder.result()

        self.currentLoadingLabel.numberOfLines = 2
        let currentLoadingBuilder = NSAttributedStringBuilder(font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.regular),
                                                              color: textColor,
                                                              alignment: NSTextAlignment.center,
                                                              kern: -0.41)
            .changeParagraphStyle(minimumLineHeight: 20.0)
            .add(progressModel.currentLoadText)
        self.currentLoadingLabel.attributedText = currentLoadingBuilder.result()

        self.setNeedsLayout()
    }
}
