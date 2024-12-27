# Screenreader
Inherits:   Object

This is the class responsible for managing the screenreader.

## Description

This class manages the screenreader. You can set some options here if you would like to configure the screenreader's functionality.

## Properties

| Return Type | Name | Default |
|:-------------:|:-------------:|:-------------:|
| ``bool`` | audio_description_enabled | ``true``

Whether or not audio description is enabled on VideoStreamPlayer Controls.

| Return Type | Name | Default |
|:-------------:|:-------------:|:-------------:|
| ``bool`` | debug | ``false`` |

When enabled, displays debug information in the console.

| Return Type | Name | Default |
|:-------------:|:-------------:|:-------------:|
| ``bool`` | dom_nav_enabled | ``false`` |

Whether or not DOM navigation is enabled.

| Return Type | Name | Default |
|:-------------:|:-------------:|:-------------:|
| ``Node`` | dom_root | null |

The object that is referred to as the root of the DOM.

| Return Type | Name | Default |
|:-------------:|:-------------:|:-------------:|
| ``Node`` | focused | null |

This is the current Control in focus.

| Return Type | Name | Default |
|:-------------:|:-------------:|:-------------:|
| ``bool`` | navigation_wrap | true |

Whether or not navigation wraps around.

| Return Type | Name | Default |
|:-------------:|:-------------:|:-------------:|
| ``bool`` | sfx_enabled | true |

Whether or not sound effects are enabled.

| Return Type | Name | Default |
|:-------------:|:-------------:|:-------------:|
| ``bool`` | subtitles_enabled | true |

Whether or not subtitles are enabled on VideoStreamPlayer Controls.

| Return Type | Name | Default |
|:-------------:|:-------------:|:-------------:|
| ``bool`` | verbose | true |

If this is set to true, the screenreader reads more information about each Control.


