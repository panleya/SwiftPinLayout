//
//  PinLayout.swift
//  Kudos
//
//  Created by Jason Blood on 8/10/14.
//  Copyright (c) 2014 Jason Blood Inc. All rights reserved.
//

import UIKit

protocol PinLayoutDelegate: UICollectionViewDelegate
{
    func heightForItemAtIndexPath(indexPath: NSIndexPath) -> Double
    func layoutSizeChanged(size: CGSize)
}

class PinLayout: UICollectionViewLayout
{
    var columnCount: Int = 2
    var delegate: PinLayoutDelegate? = nil
    var itemCount: Int = 0
    var itemAttributes: NSMutableArray = NSMutableArray.array()
    var columnHeights: NSMutableArray = NSMutableArray.array()
    
    override func prepareLayout()
    {
        super.prepareLayout()
        
        itemCount = self.collectionView.numberOfItemsInSection(0)
        let itemWidth = self.collectionView.frame.size.width / CGFloat(columnCount)
        itemAttributes = NSMutableArray.arrayWithCapacity(itemCount)
        columnHeights = NSMutableArray.arrayWithCapacity(columnCount)
        
        //init the height at the very top
        for (var i = 0; i < columnCount; i++)
        {
            columnHeights[i] = 0;
        }
        
        //item is always placed into shortest column
        for (var i = 0; i < itemCount; i++)
        {
            let indexPath: NSIndexPath = NSIndexPath(forItem: i, inSection: 0)
            var itemHeight = delegate?.heightForItemAtIndexPath(indexPath)
            let columnIndex = self.shortestColumnIndex()
            let xOffset = itemWidth * CGFloat(columnIndex)
            var yOffset: CGFloat = 0
            
            if (itemHeight == nil)
            {
                itemHeight = 0
            }
            if (columnHeights.count > columnIndex)
            {
                yOffset = CGFloat(columnHeights[columnIndex] as NSNumber)
            }
            
            //println("position \(xOffset), \(yOffset), \(columnIndex), \(itemWidth)")
            
            var attributes : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = CGRectMake(xOffset, yOffset, CGFloat(itemWidth), CGFloat(itemHeight!))
            itemAttributes.addObject(attributes)
            if (columnHeights.count > columnIndex)
            {
                columnHeights[columnIndex] = yOffset + CGFloat(itemHeight!);
                //println("column: \(columnIndex) = \(columnHeights[columnIndex])")
            }
        }
    }
    
    override func collectionViewContentSize() -> CGSize
    {
        if (itemCount == 0)
        {
            return CGSizeZero;
        }
        
        var contentSize = self.collectionView.frame.size
        let columnIndex = self.longestColumnIndex();
        var height = CGFloat(0.0)
        if (columnHeights.count > columnIndex)
        {
            height = CGFloat(columnHeights[columnIndex] as NSNumber)
        }
        contentSize.height = height;
        
        self.delegate?.layoutSizeChanged(contentSize)
        
        return contentSize;
    }
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath!) -> UICollectionViewLayoutAttributes!
    {
        return itemAttributes[indexPath.item] as UICollectionViewLayoutAttributes
    }
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]!
    {
        let predicate = NSPredicate { (a : AnyObject!, b: [NSObject : AnyObject]!) -> Bool in
            return CGRectIntersectsRect(rect, a.frame)
        }
        return itemAttributes.filteredArrayUsingPredicate(predicate)
    }
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool
    {
        return false;
    }
    
    func shortestColumnIndex() -> Int
    {
        var i : Int = 0
        var shortestHeight : Double = Double.infinity
        
        columnHeights.enumerateObjectsUsingBlock({object, index, stop in
            let height : Double = object.doubleValue
            if (height < shortestHeight)
            {
                shortestHeight = height
                i = index
            }
        })
        
        return i
    }
    func longestColumnIndex() -> Int
    {
        var i : Int = 0
        var longestHeight : Double = 0
        
        columnHeights.enumerateObjectsUsingBlock({object, index, stop in
            let height : Double = object.doubleValue
            if (height > longestHeight)
            {
                longestHeight = height
                i = index
            }
        })
        
        return i
    }
}