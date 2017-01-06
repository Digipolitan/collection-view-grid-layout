# DGCollectionViewGridLayout

Layout that allows you to display collection of data in grid without only **very few** lines of codes.
It can have the look of a `UITableView` or a `UICollectionView`.

![DGCollectionGridViewLayout Sample](https://github.com/Digipolitan/collection-view-grid-layout/blob/develop/Screenshots/grid-1.gif?raw=true "Example 1")
![DGCollectionGridViewLayout Sample](https://github.com/Digipolitan/collection-view-grid-layout/blob/develop/Screenshots/grid-2.gif?raw=true "Example 2")

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Works with iOS 8+, tested on Xcode 8.2

### Installing

To install the DGGridCollectionViewController using **cocoapods**

- Add an entry in your Podfile  

```
# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

target 'YourTarget' do
  frameworks
   use_frameworks!

  # Pods for YourTarget
  pod 'DGCollectionViewGridLayout'
end
```

- Then install the dependency with the `pod install` command.

## Usage

- Initialize your layout by instantiate a DGCollectionViewGridLayout.

```swift
	let layout =  DGCollectionViewGridLayout()
```



### Configuration

You can customize the component by enabling few options:

```swift
layout.lineSpacing = 10
layout.columnSpacing = 10
layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
```

### Interacting with the component

To Communicate with the layout, use the same way than `UICollectionViewFlowLayout`. Declare your component as `DGGridLayoutDelegate` and `DGGridLayoutDataSource`, those inheriting respectively from `UICollectionViewDelegate` and `UICollectionViewDataSource` you just have to assign it to your `collectionView`.

```swift
self.collectionView.delegate = self
self.collectionView.dataSource = self
```

- DGGridLayoutDelegate

```swift
/**
Gives the height of an item at an IndexPath. The highest item in the row will set the
height of the row. Default is 100.
**/
@objc optional func collectionView(_ collectionView: UICollectionView,
                                          layout collectionViewLayout: DGCollectionViewGridLayout,
                                          heightForItemAtIndexPath indexPath: IndexPath,
                                          columnWidth: CGFloat) -> CGFloat
/**
Gives the height of a ReusableView of Type Header. If no height is provided,
no header will be displayed.
**/
@objc optional func collectionView(_ collectionView: UICollectionView,
                                          layout collectionViewLayout: DGCollectionViewGridLayout,
                                          heightForHeaderInSection section: Int) -> CGFloat
/**
Gives the height of a ReusableView of Type Footer. If no height is provided,
no footer will be displayed.
**/
@objc optional func collectionView(_ collectionView: UICollectionView,
                                          layout collectionViewLayout: DGCollectionViewGridLayout,
                                          heightForFooterInSection section: Int) -> CGFloat
```

- DGGridLayoutDataSource

```swift
/**
Gives the same width for each items depending on the value returned. Default is 1.
**/
@objc optional func numberOfColumnsIn(_ collectionView: UICollectionView) -> Int
```

## Limitations

Current limitations are :
- Performances issues when more than 3k items. (WIP)
- Decoration View not handled
- Scroll direction only vertical


## Built With

[Fastlane](https://fastlane.tools/)
Fastlane is a tool for iOS, Mac, and Android developers to automate tedious tasks like generating screenshots, dealing with provisioning profiles, and releasing your application.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details!

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to [contact@digipolitan.com](mailto:contact@digipolitan.com).

## License

DGGridCollectionViewController is licensed under the [BSD 3-Clause license](LICENSE).
