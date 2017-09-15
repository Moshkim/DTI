//
//  graph.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 9/8/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation

struct Graph {
    
    
    static func createDarkGraph(_ frame: CGRect) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame: frame)
        graphView.layer.cornerRadius = 5
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#333333")
        
        graphView.lineWidth = 2
        graphView.lineColor = UIColor.colorFromHex(hexString: "#777777")
        graphView.lineStyle = ScrollableGraphViewLineStyle.straight
        
        graphView.shouldFill = true
        graphView.fillType = ScrollableGraphViewFillType.gradient
        graphView.fillColor = UIColor(red:0.99, green:0.42, blue:0.80, alpha:1.0)
        
        //UIColor.colorFromHex(hexString: "#555555")
        graphView.fillGradientType = ScrollableGraphViewGradientType.radial
        graphView.fillGradientStartColor = UIColor(red:0.99, green:0.42, blue:0.80, alpha:1.0)
        //UIColor.colorFromHex(hexString: "#555555")
        graphView.fillGradientEndColor = UIColor(red:0.99, green:0.42, blue:0.80, alpha:1.0)
        //UIColor.colorFromHex(hexString: "#444444")
        
        graphView.dataPointSpacing = 25
        graphView.dataPointSize = 4
        graphView.dataPointFillColor = UIColor(red:0.99, green:0.10, blue:0.56, alpha:1.00)
        
        graphView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        graphView.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        graphView.referenceLineLabelColor = UIColor.white
        graphView.numberOfIntermediateReferenceLines = 5
        graphView.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = false
        graphView.adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
        graphView.animationDuration = 0.5
        graphView.rangeMax = 100
        graphView.shouldRangeAlwaysStartAtZero = true
        graphView.showsVerticalScrollIndicator = true
        graphView.showsHorizontalScrollIndicator = true
        //graphView.shouldAutomaticallyDetectRange = true
        
        graphView.shouldShowLabels = true
        
        return graphView
    }
}
