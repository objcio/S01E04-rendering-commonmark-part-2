//: # Swift Talk Episode 4: Rendering CommonMark (Part 2)
//:
//: Check out the full episode and the transcript [here](https://talk.objc.io/episodes/S01E04-rendering-commonmark-part-2)
//:
//: To make this playground work you have to run "Product > Build" once to compile the CommonMark module.

import CommonMark

let markdown = "# Heading **strong**\nHello **Markdown**!"

let tree = Node(markdown: markdown)!.elements


extension Array where Element: NSAttributedString {
    public func join(separator separator: String = "") -> NSAttributedString {
        guard !isEmpty else { return NSAttributedString() }
        let result = self[0].mutableCopy() as! NSMutableAttributedString
        for element in suffixFrom(1) {
            result.appendAttributedString(NSAttributedString(string: separator))
            result.appendAttributedString(element)
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
            traits.unionInPlace(.TraitBold)
        }
        let newFontDescriptor = fontDescriptor.fontDescriptorWithSymbolicTraits(traits)
        let font = UIFont(descriptor: newFontDescriptor, size: 0)
        self.init(string: string, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: attributes.color])
    }
}

class Stylesheet {
    func strong(inout attributes: Attributes) {
        attributes.bold = true
        attributes.color = .redColor()
    }
    
    func heading(inout attributes: Attributes) {
        attributes.size = 48
    }
}

extension InlineElement {
    func render(stylesheet: Stylesheet, attributes: Attributes) -> NSAttributedString {
        var newAttributes = attributes
        switch self {
        case .Text(let text):
            return NSAttributedString(string: text, attributes: attributes)
        case .Strong(let children):
            stylesheet.strong(&newAttributes)
            return children.map { $0.render(stylesheet, attributes: newAttributes) }.join()
        default:
            fatalError()
        }
    }
}

extension Block {
    func render(stylesheet: Stylesheet, attributes: Attributes) -> NSAttributedString {
        var newAttributes = attributes
        switch self {
        case .Paragraph(let children):
            return children.map { $0.render(stylesheet, attributes: attributes) }.join()
        case .Heading(let children, _):
            stylesheet.heading(&newAttributes)
            return children.map { $0.render(stylesheet, attributes: newAttributes) }.join()
        default:
            fatalError()
        }
    }
}

let baseAttributes = Attributes(family: "Helvetica", size: 24, bold: false, color: .blackColor())
let stylesheet = Stylesheet()
let output = tree.map { $0.render(stylesheet, attributes: baseAttributes) }.join(separator: "\n")

output



