# General Use

Whenever control would be given to a user interface, you can set up the screenreader by calling the following:

```
# root_node = The root node of your user interface
AXController.set_dom_root(root_node)
```

This will update how the screenreader organizes the Controls internally. For every time you need to update what buttons are able to be input by a user, you should call this.

If you want to clear the screenreader, you can call it with ``null``:

```
# root_node is set to null
AXController.set_dom_root(null)
```

[<- Previous (Installation)](installation.md)
 | [Next (STUB) ->](stub.md)

[Back to README](../../README.md)
