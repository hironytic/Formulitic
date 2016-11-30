# Formulitic

Formulitic is a formula evaluating library written in Swift.

## Usage

### Basic

The formula is a string which describes a calculation and is similar to that in speradsheet apps.

```swift
let formulaString = "1 + 2 * 3"
```

You can parse and evaluate it by `Formulitic` object.

```swift
let formulitic = Formulitic()
let formula = formulitic.parse(formulaString)
let result = formula.evaluate()
```

The evaluated result has one of the following types: number, string, boolean or error.

```swift
switch result {
case let numerableResult as NumerableValue:
    print(numerableResult.number)    // prints "7.0" in this example
case let stringableResult as StringableValue:
    print(stringableResult.string)
case let booleanableResult as BooleanableValue:
    print(booleanableResult.bool)
case let errorableResult as ErrorableValue:
    print(errorableResult)
default:
    break
}
```

### References

A formula can contain references with curly brackets.

```swift
let formulaString = "2 * {pi} * {radius}"
```

To resolve these references a "reference producer", an object which conforms to `ReferenceProducer`, is needed.
It provides a `ReferableValue` for each  reference name.

For simple case, you can use `BasicReferenceProducer`.

```swift
let refProducer = BasicReferenceProducer()
refProducer.dereferencer = { (name, _) -> Value in
    switch name {
    case "pi":
        return DoubleValue(number: Double.pi)
    case "radius":
        return DoubleValue(number: 5)
    default:
        return ErrorValue.invalidReference
    }
}
```

Then create `Formulitic` object with this reference producer.

```swift
let formulitic = Formulitic(referenceProducer: refProducer)
let formula = formulitic.parse(formulaString)
let result = formula.evaluate()
// the result is a NumerableValue whose number is 31.41592...
```



### Functions








## Requirements

- iOS 8.0+
- Swift 3.0+

## Installation

*TBD*

<!--
### CocoaPods

Formulitic is available through [CocoaPods](http://cocoapods.org).
To install it, simply add the following lines to your Podfile:

```ruby
use_frameworks!
pod "Formulitic"
```

### Carthage

Formulitic is available through [Carthage](https://github.com/Carthage/Carthage).
To install it, simply add the following line to your Cartfile:

```
github "hironytic/Formulitic"
```
-->

## Author

Hironori Ichimiya, hiron@hironytic.com

## License

Formulitic is available under the MIT license. See the LICENSE file for more info.
