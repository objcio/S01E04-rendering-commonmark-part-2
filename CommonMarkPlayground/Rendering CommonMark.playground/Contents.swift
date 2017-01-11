//: # Swift Talk Episode 4: Rendering CommonMark (Part 2)
//:
//: Check out the full episode and the transcript [here](https://talk.objc.io/episodes/S01E04-rendering-commonmark-part-2)
//:
//: To make this playground work you have to run "Product > Build" once to compile the CommonMark module.

import CommonMark

let markdown = "# Heading **strong**\nHello **Markdown**!"

let tree = Node(markdown: markdown)!.elements


extension Array where Element: NSAttributedString {
    public func join(separator: String = "") -> NSAttributedString {
        guard !isEmpty else { return NSAttributedString() }
        let result = self[0].mutableCopy() as! NSMutableAttributedString
        for element in suffix(from: 1) {
            result.append(NSAttributedString(string: separator))
            result.append(element)
        }
        return result
    }
}

struct Attributes {
    var family: String
    var size: CGFloat
    var bold: Bool
    var color: UIColor
}

extension NSAttributedString {
    convenience init(string: String, attributes: Attributes) {
        let fontDescriptor = UIFontDescriptor(name: attributes.family, size: attributes.size)
        var traits = UIFontDescriptorSymbolicTraits()
        if attributes.bold {
            traits.formUnion(.traitBold)
        }
        let newFontDescriptor = fontDescriptor.withSymbolicTraits(traits)!
        let font = UIFont(descriptor: newFontDescriptor, size: 0)
        self.init(string: string, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: attributes.color])
    }
}

class Stylesheet {
    func strong( attributes: inout Attributes) {
        attributes.bold = true
        attributes.color = .red
    }
    
    func heading( attributes: inout Attributes) {
        attributes.size = 48
    }
}

extension Inline {
    func render(stylesheet: Stylesheet, attributes: Attributes) -> NSAttributedString {
        var newAttributes = attributes
        switch self {
        case .text(let text):
            return NSAttributedString(string: text, attributes: attributes)
        case .strong(let children):
            stylesheet.strong(attributes: &newAttributes)
            return children.map { $0.render(stylesheet: stylesheet, attributes: newAttributes) }.join()
        default:
            fatalError()
        }
    }
}

extension Block {
    func render(stylesheet: Stylesheet, attributes: Attributes) -> NSAttributedString {
        var newAttributes = attributes
        switch self {
        case .paragraph(let children):
            return children.map { $0.render(stylesheet: stylesheet, attributes: attributes) }.join()
        case .heading(let children, _):
            stylesheet.heading(attributes: &newAttributes)
            return children.map { $0.render(stylesheet: stylesheet, attributes: newAttributes) }.join()
        default:
            fatalError()
        }
    }
}

let baseAttributes = Attributes(family: "Helvetica", size: 24, bold: false, color: .black)
let stylesheet = Stylesheet()
let output = tree.map { $0.render(stylesheet: stylesheet, attributes: baseAttributes) }.join(separator: "\n")

output



