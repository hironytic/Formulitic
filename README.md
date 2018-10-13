# Formulitic

[![CI Status](http://img.shields.io/travis/hironytic/Formulitic.svg?style=flat)](https://travis-ci.org/hironytic/Formulitic)
[![Version](https://img.shields.io/cocoapods/v/Formulitic.svg?style=flat)](http://cocoapods.org/pods/Formulitic)
[![License](https://img.shields.io/cocoapods/l/Formulitic.svg?style=flat)](http://cocoapods.org/pods/Formulitic)
[![Platform](https://img.shields.io/cocoapods/p/Formulitic.svg?style=flat)](http://cocoapods.org/pods/Formulitic)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

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

To resolve these references, an object called "reference producer" is used.
It conforms to `ReferenceProducer` protocol and produce a `ReferableValue` for each  reference name.

For simple case, you can use `BasicReferenceProducer` class.

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

A formula can contain function calls.

```swift
let formulaString = "HELLO(\"world\")"
```

In evaluating a function, the actual implementation is provided by an object called "function provider", which conforms to `FunctionProvider` protocol.

You can use `BasicFunctionProvider` class. 

```swift
let funcProvider = BasicFunctionProvider()
funcProvider.installFunctions([
    "HELLO": { (parameters, context) in
        guard parameters.count == 1 else { return ErrorValue.invalidArgumentCount }
        
        let param = parameters[0]
            .evaluate(with: context)
            .dereference(with: context)
            .cast(to: .stringable, context: context)
        if param is ErrorableValue {
            return param
        }
        guard let textParam = param as? StringableValue else { return ErrorValue.generic }
        let text = textParam.string

        return StringValue(string: "Hello, \(text)")
    }
])
```

Then create `Formulitic` object with this function provider.

```swift
let formulitic = Formulitic(functionProvider: funcProvider)
let formula = formulitic.parse(formulaString)
let result = formula.evaluate()
// the result is a StringValue whose string is "Hello, world".
```

Additionally there are built-in functions, which are not installed by default.
You can install them to `BasicFunctionProvider` as your needs.

```swift
let formulaString = "LEN(\"foobar\")"
let funcProvider = BasicFunctionProvider()
funcProvider.installFunctions(BuiltInFunction.string)
let formulitic = Formulitic(functionProvider: funcProvider)
let formula = formulitic.parse(formulaString)
let result = formula.evaluate()
// the result is a NumerableValue whose number is 6".
```

<!-- For more informations, please see ... -->


## Requirements

- iOS 8.0+
- Swift 4.2+

## Installation

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

## Author

Hironori Ichimiya, hiron@hironytic.com

## License

Formulitic is available under the MIT license. See the LICENSE file for more info.
