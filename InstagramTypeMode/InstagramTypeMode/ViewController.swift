//
//  ViewController.swift
//  testdddddd
//
//  Created by king on 2022/5/5.
//

import UIKit

// https://instagram-engineering.com/building-type-mode-for-stories-on-ios-and-android-8804e927feba

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    let minimumFontSize: CGFloat = 24
    let maximumFontSize: CGFloat = 200
    let pointSize: CGFloat = 24
    var font: UIFont = {
        UIFont.systemFont(ofSize: 24, weight: .semibold)
    }()

    let layout = IGSomeCustomLayoutManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        textView.delegate = self
        textView.textAlignment = .center
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.keyboardDismissMode = .onDrag

//        textView.textContainer.replaceLayoutManager(layout)
        object_setClass(textView.layoutManager, IGSomeCustomLayoutManager.classForCoder())

        let font = UIFont(descriptor: font.fontDescriptor, size: maximumFontSize)
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        textView.typingAttributes = [.font: font, .paragraphStyle: paraStyle]
        textViewHeightConstraint.constant = font.lineHeight
    }
}

func clamp<T>(x: T, min: T, max: T) -> T where T: Comparable {
    if x > max {
        return max
    }

    if x < min {
        return min
    }

    return x
}

// extension ViewController {
//    func calculatedFontSize() -> CGFloat {
//        let attributedString = NSAttributedString(string: self.textView.text, attributes: [.font: self.font])
//        let textWidth = attributedString.boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity), options: [], context: nil).size.width
//        let scaleFactor = self.textView.textContainer.size.width / textWidth
//        let preferredFontSize = self.pointSize * scaleFactor
//        let size = clamp(x: preferredFontSize, min: minimumFontSize, max: maximumFontSize)
//        return size
//    }
// }
//
// extension ViewController: UITextViewDelegate {
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let size = self.calculatedFontSize()
//        var typingAttributes = textView.typingAttributes
//
//        let font = UIFont(descriptor: font.fontDescriptor, size: size)
//        textViewHeightConstraint.constant = font.lineHeight
//
//        typingAttributes[.font] = font
//        let style = NSMutableParagraphStyle()
//        style.alignment = .center
//        style.lineBreakMode = .byCharWrapping
//        typingAttributes[.paragraphStyle] = style
//        textView.typingAttributes = typingAttributes
//        return true
//    }
//
//    func textViewDidChange(_ textView: UITextView) {
//        let textStorage = textView.textStorage
//        let layoutManager = textView.layoutManager
//        var lineRanges: [NSRange] = []
//        layoutManager.enumerateLineFragments(forGlyphRange: NSMakeRange(0, layoutManager.numberOfGlyphs)) { _, _, _, glyphRange, stop in
//            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
//            lineRanges.append(characterRange)
//        }
//
//        textStorage.beginEditing()
//        let size = self.calculatedFontSize()
//        print("calculatedFontSize", size)
//        let font = UIFont(descriptor: font.fontDescriptor, size: size)
//        let style = NSMutableParagraphStyle()
//        style.alignment = .center
//        style.lineBreakMode = .byCharWrapping
////        for range in lineRanges {
//        let range = layoutManager.glyphRange(for: textView.textContainer)
//            textStorage.setAttributes([.font : font, .paragraphStyle: style], range: range)
////        }
//        textStorage.endEditing()
//    }
// }

extension ViewController {
    func calculatedFontSize(for text: String) -> CGFloat {
        let attributedString = NSAttributedString(string: text, attributes: [.font: self.font])
        let textWidth = attributedString.boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity), options: [], context: nil).size.width
//        let scaleFactor = (self.textView.textContainer.size.width - self.textView.textContainerInset.left * 2 - 12) / textWidth
        let scaleFactor = self.textView.textContainer.size.width / textWidth
        let preferredFontSize = self.pointSize * scaleFactor
        let size = clamp(x: preferredFontSize, min: minimumFontSize, max: maximumFontSize)
        return size
    }
}

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let size = self.calculatedFontSize()
//        var typingAttributes = textView.typingAttributes
//        typingAttributes[.font] = UIFont(descriptor: font.fontDescriptor, size: size)
//        var paraStyle = NSMutableParagraphStyle()
//        paraStyle.alignment = .center
//        typingAttributes[.paragraphStyle] = paraStyle
//        textView.typingAttributes = typingAttributes
//        return true
        if textView.text.isEmpty, text == "\n" {
            return false
        }

        if textView.text.last == "\n", text == "\n" {
            return false
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
//        guard textView.markedTextRange == nil else {
//            return
//        }
        let textStorage = textView.textStorage
        let layoutManager = textView.layoutManager
        var lineInfoList: [(NSRange, CGFloat)] = []
        let text = textStorage.string as NSString
        text.enumerateSubstrings(in: .init(location: 0, length: text.length), options: .byLines) { substring, _, range, _ in
            let size = self.calculatedFontSize(for: substring!)
            lineInfoList.append((range, size))
        }

        textStorage.beginEditing()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        var totalLineHeight: CGFloat = 0
        for lineInfo in lineInfoList {
            let font = UIFont(descriptor: font.fontDescriptor, size: lineInfo.1)
            totalLineHeight += font.lineHeight
            textStorage.setAttributes([.paragraphStyle: paragraphStyle, .font: font], range: lineInfo.0)
        }
        textStorage.endEditing()

        var height: CGFloat = 0
        layoutManager.enumerateLineFragments(forGlyphRange: NSMakeRange(0, layoutManager.numberOfGlyphs)) { _, usedRect, _, _, _ in
            //            print(usedRect)
            height = max(usedRect.maxY, height)
        }

        //        let minSize = lineInfoList.map { $0.1 }.max() ?? maximumFontSize
        let font = UIFont(descriptor: font.fontDescriptor, size: maximumFontSize)
        //        textViewHeightConstraint.constant = font.lineHeight * CGFloat(lineInfoList.count)
        if !lineInfoList.isEmpty, text.components(separatedBy: "\n").count > lineInfoList.count {
            height += font.lineHeight
        }
        textViewHeightConstraint.constant = height <= 0 ? font.lineHeight : height

//        let glyphRange = layoutManager.glyphRange(for: textView.textContainer)
//        let rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textView.textContainer)
//        print(rect.maxY, height)
    }
}

class IGSomeCustomLayoutManager: NSLayoutManager {
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        let kSomePadding: CGFloat = 4
        let kSomeCornerRadius: CGFloat = 10
        self.enumerateLineFragments(forGlyphRange: NSMakeRange(0, self.numberOfGlyphs)) { _, usedRect, _, _, _ in
            let lineBoundingRect = usedRect // self.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            let adjustedLineRect = lineBoundingRect.insetBy(dx: -kSomePadding, dy: kSomePadding)
            let fillColorPath = UIBezierPath(roundedRect: adjustedLineRect, cornerRadius: kSomeCornerRadius)
            UIColor.systemPink.setFill()
            fillColorPath.fill()
        }

//        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
    }
}
