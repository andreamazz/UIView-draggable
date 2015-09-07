<p align="center">
  <img src="assets/logo.png"/>
</p>

[![Build Status](https://travis-ci.org/cevitcejbo/UIView-draggable.svg)](https://travis-ci.org/cevitcejbo/UIView-draggable)
[![Coverage Status](https://coveralls.io/repos/cevitcejbo/UIView-draggable/badge.svg)](https://coveralls.io/r/cevitcejbo/UIView-draggable)
[![Cocoapods](https://cocoapod-badges.herokuapp.com/v/UIView+draggable/badge.png)](http://cocoapods.org/?q=summary%3Auiview%20name%3Adraggable%2A)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

UIView category that adds dragging capabilities.

##Screenshot
![UIView+draggable](https://raw.githubusercontent.com/andreamazz/UIView-draggable/master/assets/screenshot.gif)

##Setup with Cocoapods
* Add ```pod 'UIView+draggable'``` to your Podfile
* Run ```pod install```
* Run ```open App.xcworkspace```

##Setup with Carthage
```
github "andreamazz/UIView-draggable"
```

####Objective-C

Import ```UIView+draggable.h``` in your controller's header file

####Swift

If you are using `use_frameworks!` in your Podfile, use this import:
```swift
import UIView_draggable
```

##Usage
Call `enableDragging` on a UIView instance

####Objective-C

```objc
// Enable dragging
[self.view enableDragging];
```

####Swift

```swift
view.enableDragging()
```

##Options
The movement area can be restricted to a given rect:

```swift
view.cagingArea = CGRectMake(0, 0, 200, 200)
```

The movement can be restricted over one coordinate:

```swift
view.shouldMoveAlongX = true
view.shouldMoveAlongY = true
```

The area where the dragging action starts can be configured:

```swift
view.handle = CGRectMake(0, 0, 20, 20)
```

#MIT License
	The MIT License (MIT)

	Copyright (c) 2015 Andrea Mazzini

	Permission is hereby granted, free of charge, to any person obtaining a copy of
	this software and associated documentation files (the "Software"), to deal in
	the Software without restriction, including without limitation the rights to
	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
	the Software, and to permit persons to whom the Software is furnished to do so,
	subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
