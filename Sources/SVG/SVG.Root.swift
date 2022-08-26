import DOM

extension SVG 
{
    /// A complete SVG document.
    @frozen public 
    struct Root<Anchor>
    {
        public 
        var attributes:[DOM.Value<Anchor>]
        public 
        var nodes:[DOM.Node<Container, Leaf, Anchor>]

        @inlinable public 
        var element:Element<Anchor> 
        {
            .init(node: .container(.svg, attributes: self.attributes, content: self.nodes))
        }

        @inlinable public 
        init(_ wrapped:Element<Anchor>, attributes:[Element<Anchor>.Attribute] = [])
        {
            self.init(CollectionOfOne<Element<Anchor>>.init(wrapped), attributes: attributes)
        }
        @inlinable public 
        init<Content>(_ content:Content, attributes:[Element<Anchor>.Attribute] = []) 
            where Content:Sequence, Content.Element == Element<Anchor>
        {
            self.attributes = attributes.map(\.value)
            self.nodes = content.map(\.node)
        }
    }
}

extension SVG.Root
{
    /// Renders this SVG document with the `<?xml?>` heading prepended to it.
    @inlinable public 
    func rendered<UTF8>(into output:inout UTF8, anchors:inout [(key:Anchor, index:UTF8.Index)]) 
        where UTF8:RangeReplaceableCollection, UTF8.Element == UInt8
    {
        output.append(contentsOf: "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>".utf8)
        self.element.node.rendered(into: &output, anchors: &anchors)
    }
}
extension SVG.Root where Anchor == Never
{
    @inlinable public 
    func rendered<UTF8>(as type:UTF8.Type) -> UTF8
        where UTF8:RangeReplaceableCollection, UTF8.Element == UInt8
    {
        var output:UTF8 = .init()
        var anchors:[(key:Anchor, index:UTF8.Index)] = []
        self.rendered(into: &output, anchors: &anchors)
        return output 
    }
}

extension DOM.Flattened 
{
    @inlinable public 
    init(freezing svg:SVG.Root<Key>) 
    {
        self.init()
        svg.rendered(into: &self.literals, anchors: &self.anchors)
    }
}
