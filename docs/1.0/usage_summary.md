# Usage Summary

## General Use

All of the accessibility features provided in godot-screenreader either happen automatically, or can be controlled through the ``AXController`` global node. 

> [!WARNING]  
> There are other classes and nodes used to manage the functionality in godot-screenreader. Don't mess with these, unless you really know what you're doing, since they can disrupt the internal expectations of the screenreader.

### Screenreader

To load a new UI into the screenreader, call ``AXController.set_dom_root(root_node)``, where ``root_node`` is the top node of your UI, that contains all and only elements that you want to be interacted with. It is important that ``root_node`` contains all of the Controls you want to navigate through the screenreader, since ``AXController.set_dom_root()`` recursively searches the node's children to construct its navigation data.

#### Custom TTS

### High Contrast Theme


## Using Scripts

[<- Previous (Features)](functionality.md)
 | [Next (Using Scripts) ->](stub.md)

[Back to README](../../README.md)
