## Viewporter.js

JS library for fullscreen mobile web apps. Detects orientation changes, switching between regular and fullscreen views in iOS6, hides the address bar, and fires an event containing a normalized viewport size.

### Usage

Set a default viewport meta tag. (TODO: automatically generate this element if it doesn't exist)

    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, minimum-scale=1, maximum-scale=1, user-scalable=no" />

Include JS

    <script type="text/javascript" src="js/viewporter.js"></script>

You'll need an element (<div>) to contain everything

    <body><div id="id_of_page_element">EVERYTHING</div></body>

Some CSS rules are necessary/encouraged

    body {
      margin: 0px;
      padding: 0px;
      max-width: 100%;
      width: 100%;
      height: 100%;
    }
    #id_of_page_element {
      position: absolute;
      width: 100%;
      max-width: 100%;
      overflow: hidden;
    }

Then, ideally after the DOM exists

    viewporter = new Viewporter("id_of_page_element"[, 0-2; logging level, default: 0]);

When the viewport changes size, you can reposition your junk using javascript

    window.addEventListener("viewportchanged", function (event) {
      // use event.width and event.height
    });

### Testing, bugs

Here's what seems to happen on various configurations:

  iPhone 5 + Safari: Works magically, switching between landscape and portrait. In landscape, can switch between fullscreen and non-fullscreen views
  iPhone ≤ 4 + Safari: Probably works, but I suspect there might be issues in portrait mode. TODO: Test this
  iPhone + Chrome: Seems to work. Address bar cannot be hidden.
  Android + HTC Browser: Seems to work and goes all fullscreen and stuff, hiding address bar
  Android + HTC Sense + Chrome: Chrome bugs the fuck out. May be Sense, may be ICS, may be the 1.5x pixel aspect ratio. Who knows.
  Desktop + Chrome: Essentially just fires the viewport event using the window's innerWidth and innerHeight. Works as expected.
