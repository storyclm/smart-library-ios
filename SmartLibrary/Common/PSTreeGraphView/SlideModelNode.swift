//
//  SlideModelNode.swift
//  StoryCLM
//
//  Created by Oleksandr Yolkin on 4/4/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import UIKit
import StoryContent

class SlideModelNode: NSObject, PSTreeGraphModelNode, NSCopying {

    override init() {
        print("SlideModelNode init")
    }
    
    deinit {
        print("SlideModelNode deinit")
    }
    
    var name: String? {
        return wrappedSlide?.name
    }
    var imagePath: String? {
        return wrappedSlide?.getThumbImageUrl()?.path
    }
    var previewImagePath: String? {
        return wrappedSlide?.getPreviewImageUrl()?.path
    }
    var slide: Slide? {
        return wrappedSlide
    }
    var parentSlide: SlideModelNode? {
        if let slide = SlideModelNode.getSlideForFile(name: wrappedSlide?.swipeNext, inPres: wrappedSlide?.presentation) {
             return SlideModelNode.wrapperForSlide(slide)
        }
       return nil
    }
    private var wrappedSlide: Slide?
    private var childrenSlides = [SlideModelNode]()
    
    var subSlides: [SlideModelNode]? {
        guard let wrappedSlide = wrappedSlide, let linkedSlides = wrappedSlide.linkedSlides else {
            return nil
        }
        
        // If we haven't built our array of subclasses yet, do so.
        if (childrenSlides.count == 0)
        {
            var children = NSMutableArray(array: linkedSlides.components(separatedBy: ","))
            children = trimmedStringArray(children);
            
            if let swipePrevious = wrappedSlide.swipePrevious, swipePrevious.count > 0 {
                children.remove(swipePrevious)
            }
            
            if let swipeNext = wrappedSlide.swipeNext, children.contains(swipeNext) == false {
                children.add(swipeNext)
            }

            if let swipeNext = wrappedSlide.swipeNext, wrappedSlide.swipeNext == wrappedSlide.name {
                children.remove(swipeNext)
                wrappedSlide.swipeNext = nil
            }
            
            if let swipePrevious = wrappedSlide.swipePrevious, wrappedSlide.swipePrevious == wrappedSlide.name {
                children.remove(swipePrevious)
                wrappedSlide.swipePrevious = nil
            }
            
            if let swipeNext = wrappedSlide.swipeNext, let swipePrevious = wrappedSlide.swipePrevious, swipePrevious == swipeNext {
                children.remove(swipeNext)
                children.remove(swipePrevious)
                wrappedSlide.swipeNext = nil
                wrappedSlide.swipePrevious = nil
            }
        
            
            for childSlideName in children {
                if let childSlide = SlideModelNode.getSlideForFile(name: childSlideName as? String, inPres: wrappedSlide.presentation) {
                    if let childNode = SlideModelNode.wrapperForSlide(childSlide, parentId: wrappedSlide.slideId) {
                        childrenSlides.append(childNode)
                    }
                }
            }
            childrenSlides.sort{ $0.name ?? "" < $1.name ?? "" }
        
        }
        return childrenSlides
    }
    
    static var classToWrapperMapTable: NSMutableDictionary? = nil
    
    // MARK: - Init
    
    convenience init(slide: Slide) {
        self.init()
        wrappedSlide = slide
        
        if SlideModelNode.classToWrapperMapTable == nil {
            SlideModelNode.classToWrapperMapTable = NSMutableDictionary()
        }
        if let slideId = wrappedSlide?.slideId?.intValue {
            SlideModelNode.classToWrapperMapTable?[String(slideId)] = self
        }
    }
    
    convenience init(slide: Slide, parentId: NSNumber) {
        self.init()
        wrappedSlide = slide
        
        if SlideModelNode.classToWrapperMapTable == nil {
            SlideModelNode.classToWrapperMapTable = NSMutableDictionary(capacity: 16)
        }
        if let slideId = wrappedSlide?.slideId?.intValue {
            let key = "\(slideId)_\(parentId.intValue)"
            SlideModelNode.classToWrapperMapTable?[key] = self
        }
    }
    
    
    // MARK: - Public
    
    class func wrapperForSlide(_ slide: Slide) -> SlideModelNode? {
        if let slideId = slide.slideId?.intValue {
            if let wrapper = SlideModelNode.classToWrapperMapTable?[String(slideId)] as? SlideModelNode {
                return wrapper
            } else {
                let wrapper = SlideModelNode(slide: slide)
                return wrapper
            }
        }
        return nil
    }
    
    class func wrapperForSlide(_ slide: Slide, parentId: NSNumber?) -> SlideModelNode? {
        if let slideId = slide.slideId?.intValue, let parentId = parentId {
            if let wrapper = SlideModelNode.classToWrapperMapTable?[String(slideId)] as? SlideModelNode {
                return wrapper
            } else {
                let wrapper = SlideModelNode(slide: slide, parentId: parentId)
                return wrapper
            }
        }
        return nil
    }
    
    class func getSlideForFile(name: String?, inPres pres: Presentation?) -> Slide? {
        let slide = pres?.slides?.filter{$0.name == name}.first
        return slide
    }

    class func refresh() {
        SlideModelNode.classToWrapperMapTable = nil
    }
    
    // MARK: - Private
    
    
    
    // MARK: - PSTreeGraphModelNode
    
    func parent() -> PSTreeGraphModelNode? {
        return parentSlide
    }
    
    func childModelNodes() -> [Any]? {
        return subSlides
    }
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
    // MARK: - Helper
    
    func trimmedStringArray(_ array: NSMutableArray) -> NSMutableArray {
        let tmp = NSMutableArray(capacity: array.count)
        array.enumerateObjects( { (obj, idx, stop) in
            let str = obj as! NSString
            tmp.add(str.trimmingCharacters(in: .whitespaces))
        })
        
        return tmp
        
    }
    
}
