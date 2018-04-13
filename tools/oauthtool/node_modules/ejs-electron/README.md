# ejs-electron

[![npm](https://img.shields.io/npm/v/ejs-electron.svg)](https://www.npmjs.com/package/ejs-electron)
[![npm](https://img.shields.io/npm/dt/ejs-electron.svg)](https://www.npmjs.com/package/ejs-electron)

A mega lightweight, completely flexible module that allows ejs templating in an Electron app.

Makes use of the Electron `protocol` module to supply a custom handler for the `file:` protocol.  This handler intercepts all file requests, compiles any requested `.ejs` files, and serves the result.

---

## Installation

Install using [npm](https://www.npmjs.com/package/ejs-electron):

```
$ npm install ejs-electron
```

---

## Usage

```javascript
const ejse = require('ejs-electron')
```

---

### Method API

> Note: All methods, unless otherwise specified, return the `ejs-electron` api for chaining.

#### ejse.data()

Get/set the data (context) that will be passed to `ejs.render()`.

Overloads:
- `ejse.data('key')` -- Retrieve the value of `'key'` in the current data set.
- `ejse.data('key', 'val')` -- Set `'key'` to `'val' `in the current data set.
- `ejse.data({key: 'val'})` -- Replace the current data set with a new one containing `{key: 'val'}`

> Note: The `ejs-electron` api is injected into the scope of all rendered ejs templates. Access it via the variable `ejse`, e.g. `<% ejse.stopListening() %>`.

#### ejse.options()

Get/set the options that will be passed to `ejs.render()`. These configure the behavior of ejs itself. See the [ejs docs](http://ejs.co/#docs) for a list of possible options.

Overloads:
- `ejse.options('key')` -- Retrieve the value of `'key'` in the current options set.
- `ejse.options('key', 'val')` -- Set `'key'` to `'val' `in the current options set.
- `ejse.options({key: 'val'})` -- Replace the current options set with a new one containing `{key: 'val'}`

> Note: `ejs-electron` sets the ejs `filename` option automatically every time it renders a file. This means you can go ahead and use ejs `include` right out of the box. One less thing you need to worry about :)

#### ejse.listen()

Start intercepting requests on the 'file:' protocol, looking for '.ejs' files.

> Note: It is not necessary to call this function up-front, as `ejs-electron` starts listening as soon as it's loaded.
Use this only to start listening again after calling `ejse.stopListening()`.

#### ejse.listening()

Returns true if `ejs-electron` is currently intercepting requests on the `file:` protocol.

#### ejse.stopListening()

Stop intercepting file requests, restoring the original `file:` protocol handler.

___

## Examples

A simple Electron app with `ejs-electron` could look like this:

##### main.js

```javascript
const {app, BrowserWindow} = require('electron')
const ejse = require('ejs-electron')

let mainWindow

ejse.data('username', 'Some Guy')

app.on('ready', () => {
    mainWindow = new BrowserWindow()
    mainWindow.loadURL('file://' + __dirname + '/index.ejs')
})
```

You can, of course, chain `data()`, `options()`, and whatnot to the `require()` call:

```javascript
const ejse = require('ejs-electron')
	.data('username', 'Some Guy')
	.options('debug', true)
```

##### index.ejs

```html
<h1>Hello, <%= username %></h1> <!-- Outputs: '<h1>Hello, Some Guy</h1>' -->
<% ejse.stopListening() %>
```

Since you have access to the `ejs-electron` api in your templates, you can also use the getter overload of `ejse.data()` to access the root-level scope of your templates. This can be useful for providing constancy in nested ejs includes:

##### main.js
```javascript
ejse.data('name', 'Holmes')
```

##### profile.ejs
```html
<p>Your name: <%= name %></p>
<%- include('./dog', {name: 'Sparky'}) %>
```

##### dog.ejs
```html
<p>The dog's name: <%= name %></p>
<p>This dog belongs to: <%= ejse.data('name')</p>
```

A heavily contrived example, sure, but here's its output:

```html
<p>Your name: Holmes</p>
<p>The dog's name: Sparky</p>
<p>This dog belongs to: Holmes</p>
```

This also means that stuff like the following is also a possibility, though I've never yet found a use for it:

```html
<p>The current file is: <%= ejse.options('filename') %></p>
```

---

## Issues

Issues may be submitted at https://github.com/bowheart/ejs-electron/issues

Thanks to all who have submitted issues.  The feedback has been extremely helpful (no, seriously, you guys rock).

Also, of course, feel free to fork and pull request.  Happy coding!

---

## License

The [MIT License](LICENSE)
