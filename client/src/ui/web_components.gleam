import lustre/element.{type Element, element}
import lustre/attribute.{type Attribute}

/// This module demonstrates how to wrap a complex JavaScript Web Component
/// (e.g., a data grid) so it can be used natively within Lustre.

pub fn data_grid(
  props: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  // We use `element` to create a custom HTML tag for the web component.
  // The actual implementation of `<complex-data-grid>` would be provided by
  // a JavaScript file loaded in the browser.
  element("complex-data-grid", props, children)
}

pub fn custom_calendar(
  props: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  element("custom-calendar", props, children)
}
