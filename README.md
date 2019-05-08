CollectionViewGridLayout
=================================

[![Swift Version](https://img.shields.io/badge/swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Build Status](https://travis-ci.org/Digipolitan/collection-view-grid-layout.svg?branch=master)](https://travis-ci.org/Digipolitan/collection-view-grid-layout)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CollectionViewGridLayout.svg)](https://img.shields.io/cocoapods/v/CollectionViewGridLayout.svg)
[![Carthage Compatible](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/CollectionViewGridLayout.svg?style=flat)](http://cocoadocs.org/docsets/CollectionViewGridLayout)
[![Twitter](https://img.shields.io/badge/twitter-@Digipolitan-blue.svg?style=flat)](http://twitter.com/Digipolitan)

Layout that allows you to display collection of data in grid without only **very few** lines of codes.
It can have the look of a `UITableView` or a `UICollectionView`.

![CollectionGridViewLayout Sample](https://github.com/Digipolitan/collection-view-grid-layout/blob/master/Screenshots/grid-1.gif?raw=true "Example 1")
![CollectionGridViewLayout Sample](https://github.com/Digipolitan/collection-view-grid-layout/blob/master/Screenshots/grid-2.gif?raw=true "Example 2")

## Installation

### CocoaPods

To install CollectionViewGridLayout with CocoaPods, add the following lines to your `Podfile`.

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'CollectionViewGridLayout'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate CollectionViewGridLayout into your Xcode project using Carthage, specify it in your `Cartfile`:

```
github 'Digipolitan/collection-view-grid-layout ~> 2.1
```

Run `carthage update` to build the framework and drag the built `CollectionViewGridLayout.framework` into your Xcode project.

## Usage

- Initialize your layout by instantiate a `CollectionViewVerticalGridLayout` or `CollectionViewHorizontalGridLayout`.

```swift
	let layout =  CollectionViewVerticalGridLayout()
```

### Interacting with the component

To Communicate with the layout, use the same way than `UICollectionViewFlowLayout`. Declare your component as `CollectionViewDelegateVerticalGridLayout` or `CollectionViewDelegateHorizontalGridLayout`, those inheriting respectively from `UICollectionViewDelegate` and `UICollectionViewDataSource` you just have to assign it to your `collectionView`.

```swift
self.collectionView.delegate = self
self.collectionView.dataSource = self
```

- Common protocol for all grid layout direction

```swift
  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       rowSpacingForSection section: Int) -> CGFloat

  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       columnSpacingForSection section: Int) -> CGFloat

  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       insetForSection section: Int) -> UIEdgeInsets
```

- CollectionViewDelegateVerticalGridLayout

```swift
  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       numberOfColumnsForSection section: Int) -> Int

  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       weightForColumn column: Int,
                                       inSection section: Int) -> CGFloat

  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       heightForItemAt indexPath: IndexPath,
                                       columnWidth: CGFloat) -> CGFloat

  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       heightForHeaderInSection section: Int) -> CGFloat

  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       heightForFooterInSection section: Int) -> CGFloat
```

- CollectionViewDelegateHorizontalGridLayout

```swift
  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       numberOfRowsForSection section: Int) -> Int

  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       weightForRow row: Int,
                                       inSection section: Int) -> CGFloat

  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       widthForItemAt indexPath: IndexPath,
                                       rowHeight: CGFloat) -> CGFloat

  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       widthForHeaderInSection section: Int) -> CGFloat

  @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       widthForFooterInSection section: Int) -> CGFloat
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details!

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to [contact@digipolitan.com](mailto:contact@digipolitan.com).

## License

CollectionViewGridLayout is licensed under the [BSD 3-Clause license](LICENSE).
