//
//  AttributedStringBuilder.swift
//  StoryCLM_dev
//
//  Created by Sergey Ryazanov on 16.10.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit

final class NSAttributedStringBuilder {

    fileprivate var attributedString = NSMutableAttributedString()

    fileprivate var paragraphStyle: NSMutableParagraphStyle = {
        let v = NSMutableParagraphStyle()
        v.lineBreakMode = NSLineBreakMode.byWordWrapping
        v.alignment = NSTextAlignment.center
        return v
    }()

    fileprivate var font: UIFont = UIFont.boldSystemFont(ofSize: 14)
    fileprivate var color: UIColor = UIColor.black
    fileprivate var kern: CGFloat = 0

    init(font: UIFont? = nil, color: UIColor? = nil, alignment: NSTextAlignment = NSTextAlignment.left, kern: CGFloat = 0) {
        self.paragraphStyle.alignment = alignment
        if let x = color {self.color = x}
        if let x = font {self.font = x}
        self.kern = kern
    }

    func result() -> NSMutableAttributedString {
        return attributedString
    }

    @discardableResult
    func changeParagraphStyle(_ alignment: NSTextAlignment? = nil, lineSpacing: CGFloat? = nil, lineHeightMultiple: CGFloat? = nil, firstLineHeadIndent: CGFloat? = nil, headIndent: CGFloat? = nil, tailIndent: CGFloat? = nil, paragraphSpacing: CGFloat? = nil, paragraphSpacingBefore: CGFloat? = nil, lineBreakMode: NSLineBreakMode? = nil, minimumLineHeight: CGFloat? = nil ) -> NSAttributedStringBuilder {
        self.paragraphStyle = self.paragraphStyle.mutableCopy() as! NSMutableParagraphStyle
        if let x = alignment {self.paragraphStyle.alignment = x}
        if let x = lineSpacing {self.paragraphStyle.lineSpacing = x}
        if let x = lineHeightMultiple {self.paragraphStyle.lineHeightMultiple = x}
        if let x = firstLineHeadIndent {self.paragraphStyle.firstLineHeadIndent = x}
        if let x = headIndent {self.paragraphStyle.headIndent = x}
        if let x = tailIndent {self.paragraphStyle.tailIndent = x}
        if let x = paragraphSpacing {self.paragraphStyle.paragraphSpacing = x}
        if let x = paragraphSpacingBefore {self.paragraphStyle.paragraphSpacingBefore = x}
        if let x = lineBreakMode {self.paragraphStyle.lineBreakMode = x}
        if let x = minimumLineHeight {self.paragraphStyle.minimumLineHeight = x}
        return self
    }

    @discardableResult
    func add(_ text: String?, color: UIColor? = nil, font: UIFont? = nil, kern: CGFloat? = nil, isUnderline: Bool = false ) -> NSAttributedStringBuilder {
        if let x = color {self.color = x}
        if let x = font {self.font = x}
        if let x = kern {self.kern = x}

        if text != nil {
            attributedString.append(NSAttributedString(string: text!,
                attributes: [
                    NSAttributedString.Key.font: self.font,
                    NSAttributedString.Key.foregroundColor: self.color,
                    NSAttributedString.Key.paragraphStyle: self.paragraphStyle,
                    NSAttributedString.Key.kern: self.kern
                ]))
            if isUnderline {
                let string = attributedString.string as NSString
                let underlineRange = string.range(of: text! as String)
                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single, range: underlineRange)
            }
        }

        return self
    }

    @discardableResult
    func add(imageNamed imageName: String, fixPosition: Bool = true, additionalOffset: CGFloat = 0) -> NSAttributedStringBuilder {
        return self.add(UIImage(named: imageName)!, fixPosition: fixPosition, additionalOffset: additionalOffset)
    }

    @discardableResult
    func add(_ image: UIImage, fixPosition: Bool = true, additionalOffset: CGFloat = 0) -> NSAttributedStringBuilder {
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = image
        if fixPosition {
            let offsetToCenter: CGFloat = font.descender - attachment.image!.size.height * 0.5 + (font.descender + font.capHeight) + 2 + additionalOffset
            attachment.bounds = CGRect(x: 0, y: offsetToCenter, width: attachment.image!.size.width, height: attachment.image!.size.height)
        }
        attributedString.append(NSAttributedString(attachment: attachment))
        return self
    }

    @discardableResult
    func underlinedString(_ string: NSString, term: NSString) -> NSAttributedString {
        let output = NSMutableAttributedString(string: string as String)
        let underlineRange = string.range(of: term as String)
        output.addAttribute(NSAttributedString.Key.underlineStyle, value: [], range: NSRange(location: 0, length: string.length))
        output.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single, range: underlineRange)

        return output
    }
}
