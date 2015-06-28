
## Contents
0. [Goal](#goal)
0. [Requirements](#requirements)
0. [Android WebView](#android-webview)
0. [Create Ruboto App](#create-ruboto-app)
0. [WebView code](#webview-code)
  * [Layout](#layout)
  * [Assets](#assets)
  * [Activity](#activity)
0. [Evaluate Javascript](#evaluate-javascript)
  * [Simple evaluation](#simple-evaluation)
  * [Evaluation of synchronous Javascript with return value](#evaluation-of-synchronous-javascript-with-return-value)
  * [Evaluation of asynchronous Javascript to obtain a value (problem)](#evaluation-of-asynchronous-javascript-to-obtain-a-value-problem)
0. [Interface between WebView Javascript and application ](#interface-between-webview-javascript-and-application)
  * [Execute Ruby from WebView Javascript](#execute-ruby-from-webview-javascript)
  * [Passing parameters from Javascript to Ruby](#passing-parameters-from-javascript-to-ruby)
  * [Return values from Ruby methods to WebView Javascript](#return-values-from-ruby-methods-to-webview-javascript)
  * [Returning values from Ruby to Javascript](#returning-values-from-ruby-to-javascript)
0. [Evaluation of asynchronous Javascript to obtain a value (solution)](#evaluation-of-asynchronous-javascript-to-obtain-a-value-solution)
  * [Bidirectional approach](#bidirectional-approach)
0. [Tips](#tips)
  * [URLs for assets and resources](#urls-for-assets-and-resources)
  * [Relative URLs](#relative-urls)
  * [Debugging with Chrome](#debugging-with-chrome)
  * [Scaling](#scaling)
  * [Life-cycle](#life-cycle)

##  Goal
This tutorial demonstrates how to use the Android WebView component to display and interact with local content.  Communication between the activity (Ruby) and webview (Javascript) code.  Topics covered include:
* Content assets and resources
* Execution of webview Javascript from activity Ruby
* Execution of synchronous and asynchronous Javascript
* Execution of activity Ruby from webview Javascript
* Passing and conversion of arguments between Ruby/Java/Javascript
* Returning and conversion of values between Ruby/Java/Javascript
* Tips: URLs, debugging, scaling content, life-cycle

## Requirements
You should have completed the [[Setting Up a Ruboto Development Environment]] tutorial.

#### Ruboto version
This tutorial requires Ruboto version 1.3.0 or greater. Verify version:
```shell
$ ruboto --version
1.3.0
```
If necessary, download and install an up to date version of Ruboto.

#### Android 4.4 KitKat (API 19) 
Since Android 4.4 KitKat (API 19), the WebView component has been based on the Chromium browser.

http://developer.android.com/guide/webapps/migrating.html

> This change upgrades WebView performance and standards support for HTML5, CSS3, and JavaScript to match the latest web browsers.

This tutorial is based upon API 19. Use the Android SDK manager to install API 19:
```shell
$ android sdk
```
Select `SDK Platform` under the `Android 4.4.2 (API 19)` branch and a system image if an emulator is needed. Install the packages.

## Android WebView
The WebView is a view component that can load and display a web page. HTML, CSS, and Javascript are supported.

The Android developer documentation includes a useful guide to web apps and using WebView: 

http://developer.android.com/guide/webapps/index.html

WebView API reference:

http://developer.android.com/reference/android/webkit/WebView.html

The documentation describes support classes that provide functionality for the WebView class:
* [WebChromeClient](http://developer.android.com/reference/android/webkit/WebChromeClient.html)
> This class is called when something that might impact a browser UI happens, for instance, progress updates and JavaScript alerts are sent here (see Debugging Tasks).
 
* [WebViewClient](http://developer.android.com/reference/android/webkit/WebViewClient.html)
> It will be called when things happen that impact the rendering of the content, eg, errors or form submissions. You can also intercept URL loading here (via shouldOverrideUrlLoading()).

* [WebSettings](http://developer.android.com/reference/android/webkit/WebSettings.html)
> Modifying the WebSettings, such as enabling JavaScript with setJavaScriptEnabled().

The WebChromeClient and WebViewClient classes are useful for implementing browser-like functionality. This tutorial uses the WebView to display and interact with local content, it does not cover their usage. This tutorial does utilize the WebSettings class to configure the WebView.

## Create Ruboto App

Create a Ruboto project targeting API 19, including JRuby jars: 
```
$ ruboto gen app --package=org.ruboto.webviewtutorial --target=19
$ cd webviewtutorial
$ ruboto gen jruby 1.7.19
```
Compile and install this default app, verify it runs. 

## WebView code
Create or replace these files with contents... 

### Layout
For this tutorial the WebView is in the main activity layout.

#### Activity view layout file ./res/layout/webviewtutorial.xml
Simple Android UI layout file for webview component to fill the activity view.

```xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical" >
    <WebView
      android:layout_width="match_parent"
      android:layout_height="match_parent"
      android:id="@+id/webview" />
</RelativeLayout>
```
### Assets
Assets for use by webview are placed in an `assets` directory in the project root. These files may be referenced from the activity with a URL beginning with: `file:///android_asset/...`.

#### HTML file ./assets/html/tutorial.html
HTML file to be initially loaded by webview. Note the source URL for Javascript file specified with a relative path. This works to access other files in the `assets` directories.
```html
<html>
  <head>
    <script src="../js/tutorial.js"></script>
  </head>
  <body>
    <h1>Webview Tutorial</h1>
    <div id="tutorial-images" ></div>
    <ul id='tutorial-list'> </ul>
  </body>
</html>
```
#### Javascript file ./assets/js/tutorial.js
Javascript file containing functions that will be called from the activity.
```javascript
function add_item(text) {
  var content = document.createTextNode(text); 
  var item = document.createElement('li')
  var list = document.getElementById('tutorial-list')
  item.appendChild(content)
  list.appendChild(item)
  return list.childElementCount
}

function load_image_return_size() {
  var image = document.createElement('img')
  var images = document.getElementById( 'tutorial-images' )
  images.appendChild(image)
  image.src = 'file:///android_res/drawable/get_ruboto_core.png'
  return { 'width': image.width, 'height': image.height }
}

function remove_image() {
  var images = document.getElementById( 'tutorial-images' )
  images.removeChild(images.lastChild)
}
```

### Activity

#### Ruby file ./src/webviewtutorial_activity.rb:
Ruboto app activity. Initializes webview and menu of actions that illustrate interaction between the activity and webview.
```ruby
require 'ruboto/widget'
require 'ruboto/util/toast'

require_relative 'jscallback.rb'

class WebviewtutorialActivity

  def onCreate(bundle)
    super
    set_title 'Webview Tutorial'
    setup_webview
  end

  def on_create_options_menu menu
    super
    setup_menu menu
    true
  end

  private
  
  def setup_webview
    android::webkit::WebView.web_contents_debugging_enabled = true
    self.content_view = Ruboto::R::layout::webviewtutorial
    @webview = self.find_view_by_id Ruboto::R::id::webview
    set = @webview.settings
    set.use_wide_view_port = true
    set.load_with_overview_mode = true
    set.java_script_enabled = true
    set.loads_images_automatically = true
    set.support_zoom = true            # enable zoom
    set.built_in_zoom_controls = true  # includes pinch gesture
    set.display_zoom_controls = false  # do not display +/- zoom controls
    @webview.load_url "file:///android_asset/html/tutorial.html"
  end
  
  def setup_menu menu
    menu.add( 'Add item'               ).set_on_menu_item_click_listener proc { eval_js_add_item               ; true } 
    menu.add( 'Add item return count'  ).set_on_menu_item_click_listener proc { eval_js_add_item_return_count  ; true } 
    menu.add( 'Load image return size' ).set_on_menu_item_click_listener proc { eval_js_load_image_return_size ; true } 
    menu.add( 'Remove image'           ).set_on_menu_item_click_listener proc { eval_js_remove_image           ; true } 
  end

  def eval_js_add_item
    @webview.evaluate_javascript "add_item('#{Time.now}')", nil
  end

  def eval_js_add_item_return_count
    @webview.evaluate_javascript "add_item('#{Time.now}')", Jscallback.new( self )
  end

  def eval_js_load_image_return_size
    # ensure a cached image does not ruin this example
    @webview.clear_cache true
    @webview.evaluate_javascript "load_image_return_size()", Jscallback.new( self ) 
  end

  def eval_js_remove_image
    @webview.evaluate_javascript "remove_image()", nil
  end

end
```
#### Ruby file ./src/jscallback.rb
Ruby class implementing Java interface `ValueCallback`. Required to obtain a return value when evaluating Javascript in the webview from the activity.
```ruby
require 'json'

class Jscallback

  def initialize context
    @context = context
  end

  def onReceiveValue json
    android::util::Log.i "Webviewtutorial", "Jscallback#onReceiveValue: #{json}"
    value = JSON.load( json, nil, symbolize_names: true )
    @context.toast "Received value: #{value.inspect}"
  end

end
```
#### Build & run
To ensure changes to assets are included in package, clean old files before each build:
```shell
$ rake clean debug reinstall log
``` 
When run the app should display a simple white page with the title "Webview Tutorial" and a menu.

## Evaluate Javascript
The actions on the activity menu illustrate how to evaluate Javascript in the webview using the WebView method `evaluateJavascript` documented [here](http://developer.android.com/reference/android/webkit/WebView.html#evaluateJavascript%28java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.String%3E%29).

### Simple evaluation
Method `WebviewtutorialActivity#eval_js_add_item()` in file `./src/webviewtutorial_activity.rb` passes an interpolated string of Javascript code to call function `add_item(text)`. There is no intention to handle the return value so no callback object is provided (nil).
```ruby
def eval_js_add_item
  @webview.evaluate_javascript "add_item('#{Time.now}')", nil
end
```
The Javascript function `add_item(text)` adds an item to a list in the HTML page.
```javascript
function add_item(text) {
  var content = document.createTextNode(text); 
  var item = document.createElement('li')
  var list = document.getElementById('tutorial-list')
  item.appendChild(content)
  list.appendChild(item)
  return list.childElementCount
}
```

### Evaluation of synchronous Javascript with return value
Method `WebviewtutorialActivity#eval_js_add_item_return_count` in file `./src/webviewtutorial_activity.rb` passes an interpolated string of Javascript code to call function `add_item(text)`. The return value will be used so a callback object `Jscallback.new( self )` is provided as required by `evaluateJavascript`. 
```ruby
def eval_js_add_item_return_count
  @webview.evaluate_javascript "add_item('#{Time.now}')", Jscallback.new( self )
end
```
The Javascript function `add_item(text)` returns the size of the list after adding the item. 
```javascript
function add_item(text) {
  var content = document.createTextNode(text); 
  var item = document.createElement('li')
  var list = document.getElementById('tutorial-list')
  item.appendChild(content)
  list.appendChild(item)
  return list.childElementCount
}
```
The callback object (see file `./src/jscallback.rb`) implements Android Java interface `ValueCallback` documented [here](http://developer.android.com/reference/android/webkit/ValueCallback.html). 

Method `Jscallback.onReceiveValue(json)` in file `./src/jscallback.rb` accepts a json string provided by the webview containing the return value of the evaluated Javascript function. It is parsed and converted to a Ruby object and displayed in a toast. 
```ruby
def onReceiveValue json
  android::util::Log.i "Webviewtutorial", "Jscallback#onReceiveValue: #{json}"
  value = JSON.load( json, nil, symbolize_names: true )
  @context.toast "Received value: #{value.inspect}"
end
```

### Evaluation of asynchronous Javascript to obtain a value (problem)
Method `WebviewtutorialActivity#eval_js_load_image_return_size` in file `./src/webviewtutorial_activity.rb` passes a string of Javascript code to call function `load_image_return_size()`. A callback object is provided as required by `evaluateJavascript` because the return value will be used. 
```ruby
def eval_js_load_image_return_size
  # ensure a cached image does not ruin this example
  @webview.clear_cache true
  @webview.evaluate_javascript "load_image_return_size()", Jscallback.new( self ) 
end
```
Javascript function `load_image_return_size()` in file `./assets/js/tutorial.js` loads an image, adds it to a div, and returns an object (hash) containing the image width and height.

Note the image URL begins with the special absolute path `file://android_res/...` because the image is a resource file from the `./res` directory not the `./assets` directory. Despite their relative location in the soure project directory, these locations are handled separately by Android. In this case a relative path `../../res/drawable/get_ruboto_core.png` does not work.
```javascript
function load_image_return_size() {
  var image = document.createElement('img')
  var images = document.getElementById( 'tutorial-images' )
  images.appendChild(image)
  image.src = 'file:///android_res/drawable/get_ruboto_core.png'
  return { 'width': image.width, 'height': image.height }
}
```
When chosen, menu action 'Load image return size' adds an image to the page and displays a toast containing the dimensions of the image. The image loads but the returned dimensions are zero (0). This happens because images are loaded asynchronously and the Javascript function returns before the image has finished loading.

This kind of problem can be difficult to detect. In this case it occurs every time the action is excecuted because the cache is purposefully cleared each time:
```ruby
# ensure a cached image does not ruin this example
@webview.clear_cache true
```
If that line is removed, the incorrect return value is only evident for the first image loaded. Subsequent return values are for the cached image. The asynchronous nature of many Javascript operations in webview makes race conditions like this a common problem.

It is tempting to try the quick fix of a short delay before returning, but this approach is detrimental to Javascript application and browser performance and degrades the user's experience. A better solution more in keeping with Javascript's asynchronous nature will be presented later.

## Interface between WebView Javascript and application 
WebView supports execution of application code from Javascript via an interface object. The interface object is registered with WebView method `addJavascriptInterface` documented [here](http://developer.android.com/reference/android/webkit/WebView.html#addJavascriptInterface%28java.lang.Object,%20java.lang.String%29).

For Android API > 16 methods of the interface object must be annotated with Java annotation `@JavascriptInterface` to be available for use by Javascript.

Unlike the Ruby callback object provided to the `evaluateJavascript` method, the reflection process used by WebView to find these methods when called from Javascript requires that there be an actual Java object instance of a Java class.

We can create a such a Java class to back a Ruby class in Ruboto as follows for a class `Jsi`:
```shell
$ ruboto gen subclass java.lang.Object --name=Jsi --method_base=none

Added file /home/gerard/dev/webviewtutorial/src/org/ruboto/webviewtutorial/Jsi.java.
Added file /home/gerard/dev/webviewtutorial/src/jsi.rb.
Added file /home/gerard/dev/webviewtutorial/test/src/jsi_test.rb.
Loading Android API...Done.
Generating methods for Jsi...Done. Methods created: 0
```  
This creates the Java file `Jsi.java` and Ruby file `jsi.rb`.

### Execute Ruby from WebView Javascript
Make these changes to files...

#### Java file ./src/org/ruboto/webviewtutorial/Jsi.java
Replace with:
```java
// Generated Ruboto subclass with method base "none"

package org.ruboto.webviewtutorial;

import org.ruboto.JRubyAdapter;
import org.ruboto.Log;
import org.ruboto.Script;
import org.ruboto.ScriptInfo;
import org.ruboto.ScriptLoader;

import android.webkit.JavascriptInterface;

public class Jsi extends java.lang.Object implements org.ruboto.RubotoComponent {
  public Jsi() {
    super();
  }

  private final ScriptInfo scriptInfo = new ScriptInfo();
  public ScriptInfo getScriptInfo() {
      return scriptInfo;
  }

  @JavascriptInterface
  public void no_arg() {
    JRubyAdapter.runRubyMethod( scriptInfo.getRubyInstance(), "no_arg" );
  }

  @JavascriptInterface
  public void boolean_arg( boolean b ) {
    JRubyAdapter.runRubyMethod( scriptInfo.getRubyInstance(), "boolean_arg", b );
  }

  @JavascriptInterface
  public void int_arg( int i ) {
    JRubyAdapter.runRubyMethod( scriptInfo.getRubyInstance(), "int_arg", i );
  }

  @JavascriptInterface
  public void string_arg( String s ) {
    JRubyAdapter.runRubyMethod( scriptInfo.getRubyInstance(), "string_arg", s );
  }

  @JavascriptInterface
  public void json_arg( String j ) {
    JRubyAdapter.runRubyMethod( scriptInfo.getRubyInstance(), "json_arg", j );
  }

  @JavascriptInterface
  public void multiple_arg( String j, String s, int i, boolean b ) {
    JRubyAdapter.runRubyMethod( scriptInfo.getRubyInstance(), "multiple_arg", new Object[]{ j, s, i, b } );
  }

  {
    scriptInfo.setRubyClassName(getClass().getSimpleName());
    ScriptLoader.loadScript(this);
  }

}
```
 
#### Ruby file ./src/jsi.rb
Replace with:
```ruby
require 'json'

class Jsi

  attr_accessor :context

  def no_arg
    @context.toast "no_arg: nil"
    "null" # == nil.to_json
  end

  def boolean_arg b
    @context.toast "boolean_arg: #{b}"
    "#{b}" # == b.to_json
  end

  def int_arg i
    @context.toast "int_arg: #{i}"
    "#{i}" # == i.to_json
  end

  def string_arg s
    @context.toast "string_arg: #{s}"
    s      # != s.to_json ( s.to_json == "\"#{s}\"" )
  end

  def json_arg j
    obj = JSON.load(j)
    @context.toast "json_arg: #{obj.inspect}"
    obj.to_json
  end

  def multiple_arg j, s, i, b
    obj = JSON.load(j)
    @context.toast "multiple_arg: #{obj.inspect}, #{s}, #{i}, #{b}"
    [ obj, s, i, b ].to_json
  end

end
```

#### File ./assets/js/tutorial.js
Add functions:
```javascript
function no_arg() {
  jsi.no_arg()
}

function boolean_arg(b) {
  jsi.boolean_arg(b)
}

function int_arg(i) {
  jsi.int_arg(i)
}

function string_arg(s) {
  jsi.string_arg(s)
}

function json_arg(j) {
  jsi.json_arg(JSON.stringify(j))
}

function multiple_arg(j,s,i,b) {
  jsi.multiple_arg(JSON.stringify(j),s,i,b)
}
```

#### HTML file ./assets/html/tutorial.html
Add this in the `<body>` tag: 
```html
<h2>Using addJavascriptInterface</h2>

<div>
<table>
<tr><td><button onClick="no_arg()">no_arg()</button></td></tr>
<tr><td><button onClick="boolean_arg(true)">boolean_arg(true)</button></td></tr>
<tr><td><button onClick="int_arg(123)">int_arg(123)</button></td></tr>
<tr><td><button onClick="string_arg('abc')">string_arg("abc")</button></td></tr>
<tr><td><button onClick="json_arg({'a':1,'b':2})">json_arg({'a':1,'b':2})</button></td></tr>
<tr><td>
<button onClick="multiple_arg({'a':1,'b':2},'abc',123,true)">multiple_arg({'a':1,'b':2},true,123,'abc'</button>
</td></tr>
</table>
</div>
```

### Passing parameters from Javascript to Ruby
The annotated methods in `Jsi.java` illustrate accepting parameters of supported types and passing them to corresponding methods in the Ruby instance of class `Jsi`. The creation of a Java object array `Object[]{...}` to pass multiple parameters in method `multiple_arg` is notable. For more information: JRuby document ['Calling Java from Ruby'](https://github.com/jruby/jruby/wiki/CallingJavaFromJRuby) explains automatic bi-directional conversion of types between Ruby and Java. 

There is little documention of the types supported by WebView for calls from Javascript, those listed above were determined by trial and error. If a complex object must be passed, it may be encoded as JSON and passed as a string. JSON encoding and decoding is illustrated in Javascript functions `json_arg` and `multiple_arg` and in corresponding Ruby methods `Jsi#json_arg` and `Jsi#multiple_arg`.

The additional HTML is a table of buttons to call each Javascript function.

#### Build & run
To ensure changes to assets are included in package, clean old files before each build:
```shell
$ rake clean debug reinstall log
``` 
Run the app, click each button in the webview to call a Ruby method. Each method displays a toast indicating the method called and the parameters passed.

### Return values from Ruby methods to WebView Javascript
Make these changes to files...

#### Java file ./src/org/ruboto/webviewtutorial/Jsi.java
Add methods:
```java
@JavascriptInterface
public java.lang.String no_arg_return() {
  return (java.lang.String) JRubyAdapter.runRubyMethod( java.lang.String.class, scriptInfo.getRubyInstance(), "no_arg" );
}

@JavascriptInterface
public java.lang.String boolean_arg_return( boolean b ) {
  return (java.lang.String) JRubyAdapter.runRubyMethod( java.lang.String.class, scriptInfo.getRubyInstance(), "boolean_arg", b );
}

@JavascriptInterface
public java.lang.String int_arg_return( int i ) {
  return (java.lang.String) JRubyAdapter.runRubyMethod( java.lang.String.class, scriptInfo.getRubyInstance(), "int_arg", i );
}

@JavascriptInterface
public java.lang.String string_arg_return( String s ) {
  return (java.lang.String) JRubyAdapter.runRubyMethod( java.lang.String.class, scriptInfo.getRubyInstance(), "string_arg", s );
}

@JavascriptInterface
public java.lang.String json_arg_return( String j ) {
  return (java.lang.String) JRubyAdapter.runRubyMethod( java.lang.String.class, scriptInfo.getRubyInstance(), "json_arg", j );
}

@JavascriptInterface
public java.lang.String multiple_arg_return( String j, String s, int i, boolean b ) {
  return (java.lang.String) JRubyAdapter.runRubyMethod( java.lang.String.class, scriptInfo.getRubyInstance(), "multiple_arg", new Object[]{ j, s, i, b } );
}
```

#### Javascript file ./assets/js/tutorial.js
Add functions:
```javascript
function no_arg_return() {
  return jsi.no_arg_return()
}

function boolean_arg_return(b) {
  return jsi.boolean_arg_return(b)
}

function int_arg_return(i) {
  return jsi.int_arg_return(i)
}

function string_arg_return(s) {
  return jsi.string_arg_return(s)
}

function json_arg_return(j) {
  return jsi.json_arg_return(JSON.stringify(j))
}

function multiple_arg_return(j,s,i,b) {
  return jsi.multiple_arg_return(JSON.stringify(j),s,i,b)
}
```

#### HTML file ./assets/html/tutorial.html
Replace the `<table>` element with: 
```html
<table>
<tr>
<td><button onClick="no_arg()">no_arg()</button></td>
<td><button onClick="this.parentElement.nextElementSibling.textContent=no_arg_return()">no_arg_return()</button></td>
<td style="width:8em;border-style:solid;border-width:thin;"></td>
<td><button onClick="this.parentElement.previousElementSibling.textContent=''">Clear</button></td>
</tr>
<tr>
<td><button onClick="boolean_arg(true)">boolean_arg(true)</button></td>
<td><button onClick="this.parentElement.nextElementSibling.textContent=boolean_arg_return(true)">boolean_arg_return(true)</button></td>
<td style="width:8em;border-style:solid;border-width:thin;"></td>
<td><button onClick="this.parentElement.previousElementSibling.textContent=''">Clear</button></td>
</tr>
<tr>
<td><button onClick="int_arg(123)">int_arg(123)</button></td>
<td><button onClick="this.parentElement.nextElementSibling.textContent=int_arg_return(123)">int_arg_return(123)</button></td>
<td style="width:8em;border-style:solid;border-width:thin;"></td>
<td><button onClick="this.parentElement.previousElementSibling.textContent=''">Clear</button></td>
</tr>
<tr>
<td><button onClick="string_arg('abc')">string_arg("abc")</button></td>
<td><button onClick="this.parentElement.nextElementSibling.textContent=string_arg_return('abc')">string_arg_return("abc")</button></td>
<td style="width:8em;border-style:solid;border-width:thin;"></td>
<td><button onClick="this.parentElement.previousElementSibling.textContent=''">Clear</button></td>
</tr>
<tr>
<td><button onClick="json_arg({'a':1,'b':2})">json_arg({'a':1,'b':2})</button></td>
<td><button onClick="this.parentElement.nextElementSibling.textContent=json_arg_return({'a':1,'b':2})">json_arg_return({'a':1,'b':2})</button></td>
<td style="width:8em;border-style:solid;border-width:thin;"></td>
<td><button onClick="this.parentElement.previousElementSibling.textContent=''">Clear</button></td>
</tr>
<tr>
<td><button onClick="multiple_arg({'a':1,'b':2},'abc',123,true)">multiple_arg({'a':1,'b':2},true,123,'abc')</button></td>
<td><button onClick="this.parentElement.nextElementSibling.textContent=multiple_arg_return({'a':1,'b':2},'abc',123,true)">multiple_arg_return({'a':1,'b':2},true,123,'abc')</button></td>
<td style="width:8em;border-style:solid;border-width:thin;"></td>
<td><button onClick="this.parentElement.previousElementSibling.textContent=''">Clear</button></td>
</tr>
</table>
```

### Returning values from Ruby to Javascript
The additional methods in `Jsi.java` illustrate calling corresponding Ruby methods to get a return value and returning the value to the Javascript caller. WebView only supports return values of type `java.lang.String`. The Javascript caller may need to extract a value from the returned string, JSON parsing is the usual approach.

The Ruby methods in `jsi.rb` demonstrate returning non-string value as strings that will be interpreted as JSON expected. Again, Ruby methods `Jsi#json_arg` and `Jsi#multiple_arg` are the most interesting in this regard.

Note that Ruby method `Jsi#string_arg` simply returns a string value, this is handled as a native string by the Javascript caller. JSON parsing will not parse it as a string, it will result in an error. A string is represented in JSON with embedded quotes, eg; `"\"abc\""`.

The additional functions in `tutorial.js` call corresponding methods in `Jsi.java` and expect return value.

The additional HTML in `tutorial.html` provides buttons to call the additional Javascript functions and display the returned values in the page.
   
There are no changes for file `jsi.rb` because we are reusing the same methods.

#### Build & run
To ensure changes to assets are included in package, clean old files before each build:
```shell
$ rake clean debug reinstall log
``` 
Run the app. Click the new buttons in the webview to call Ruby methods, display a toast, and display the returned values in the page.

## Evaluation of asynchronous Javascript to obtain a value (solution)
We can now solve the earlier problem of evaluating asynchronous WebView Javascript from Ruby to obtain a value. Make the following changes to files... 

#### Ruby file ./src/webviewtutorial_activity.rb
Add menu action in method `setup_menu`:
```ruby
menu.add( 'Load image jsi size' ).set_on_menu_item_click_listener proc { eval_js_load_image_jsi_size ; true }
```
Add method: 
```ruby
def eval_js_load_image_jsi_size
  @webview.clear_cache true
  @webview.evaluate_javascript "load_image_jsi_size()", nil
end
```

#### Javascript file ./assets/js/tutorial.js
Add function:
```javascript
function load_image_jsi_size() {
  var image = document.createElement('img')
  var images = document.getElementById( 'tutorial-images' )
  images.appendChild(image)
  image.src = 'file:///android_res/drawable/get_ruboto_core.png'
  image.onload = function() {
    jsi.image_loaded( image.width, image.height )
  }
}
```

#### Java file ./src/org/ruboto/webviewtutorial/Jsi.java
Add method:
```java
@JavascriptInterface
public void image_loaded( int w, int h ) {
  JRubyAdapter.runRubyMethod( scriptInfo.getRubyInstance(), "image_loaded", new Object[]{ w, h } );
}
```

#### Ruby file ./src/jsi.rb
Add method:
```ruby
def image_loaded w, h
  @context.toast "Image size: #{w}x#{h}"
end
```

### Bidirectional approach

The approach here is that the activity uses the WebView `evaluateJavascript` method to call WebView Javascript which in turn calls a method of the Javascript interface object registered with `addJavascriptInterface` to send a value back to the activity.

The menu action handler `eval_js_load_image_jsi_size` calls `evaluateJavascript` without a callback object as the return value will not be used. 
```ruby
@webview.evaluate_javascript "load_image_jsi_size()", nil
```

Javascript function `load_image_jsi_size()` adds an image to the page. The Javascript interface object (`jsi`) method `image_loaded` is called from the `onload` event handler which will be executed after the image has loaded and properties are updated.

```javascript
image.onload = function() {
  jsi.image_loaded( image.width, image.height )
}
```

Finally the javascript interface Java method `image_loaded` and corresponding Ruby method `Jsi#image_loaded` display a toast containg the image dimensions.

#### Build & run
To ensure changes to assets are included in package, clean old files before each build:
```shell
$ rake clean debug reinstall log
``` 
Run the app. When selected, the new menu action 'Load image jsi size' adds an image to the page and displays a toast containing the correct dimensions for the image.

## Tips

### URLs for assets and resources

Project assets `assets/...` and resources `res/...` may be referred to via `file:///android_asset/...` and `file:///android_res/...` URLs respectively.
This is not well documented, but is mentioned in the Android source for [URLUtil.java](https://android.googlesource.com/platform/frameworks/base.git/+/android-4.2.2_r1/core/java/android/webkit/URLUtil.java):

```Java
// to refer to bar.png under your package's asset/foo/ directory, use
// "file:///android_asset/foo/bar.png".
static final String ASSET_BASE = "file:///android_asset/";
// to refer to bar.png under your package's res/drawable/ directory, use
// "file:///android_res/drawable/bar.png". Use "drawable" to refer to
// "drawable-hdpi" directory as well.
static final String RESOURCE_BASE = "file:///android_res/";
```

### Relative URLs

After initially loading a local page with a `file:///android_asset/` URL. Content URLs within the page can use relative paths `../...` to access other local assets.
This is useful for testing HTML and Javascript code in the source project with a browser and tools on a developer system. Webview user interaction and network access may be efficiently developed and tested this way independent of the application compile/install/debug cycle.

### Debugging with Chrome

Chrome developer tools can be used to debug a WebView on a device running Android 4.4 or later.
Chrome developer docs at [https://developer.chrome.com/devtools/docs/remote-debugging](https://developer.chrome.com/devtools/docs/remote-debugging) describe how to configure remote debugging of a webview from a USB connected developer system. The Chrome developer tools can be used to inspect the page and debug Javascript. In addition the page can be displayed and interacted with on the developer system.

### Scaling

Many of the methods to get or set scale for webview are deprecated. The API documentation for [getScale()](http://developer.android.com/reference/android/webkit/WebView.html#getScale%28%29) recommends an [onScaleChanged()](http://developer.android.com/reference/android/webkit/WebViewClient.html#onScaleChanged%28android.webkit.WebView,%20float,%20float%29) listener in a [WebViewClient](http://developer.android.com/reference/android/webkit/WebViewClient.html) to track interactive scale changes. Determining the initial scale for a page per the API documentation for [setInitialScale()](http://developer.android.com/reference/android/webkit/WebView.html#setInitialScale%28int%29) can be challenging. The effects of different device screen densities complicate matters even more.

A simple approach applicable when using a webview to interact with local content is to open the webview initially scaled to display the entire content. This is achieved in this tutorial with the local HTML page _**not**_ having a viewport tag, and these WebView settings:

```ruby
def setup_webview
  ...
  @webview = self.find_view_by_id Ruboto::R::id::webview
  set = @webview.settings
  set.use_wide_view_port = true
  set.load_with_overview_mode = true
  ...
end
```

A close read of the Android docs for methods [setInitialScale()](http://developer.android.com/reference/android/webkit/WebView.html#setInitialScale%28int%29), [useWideViewPort()](http://developer.android.com/reference/android/webkit/WebSettings.html#setUseWideViewPort%28boolean%29), and [setLoadWithOverviewMode()](http://developer.android.com/reference/android/webkit/WebSettings.html#setLoadWithOverviewMode%28boolean%29) indicates that the WebView should scale to display the entire content in the absence of a viewport tag. This seems to work in practice.

### Life-cycle

The difficulties of programmatic scaling described above are felt particularly keenly when saving and restoring webview position and scale for device screen orientation changes. Luckily, experimentation indicates that the webview component can handle orientation changes well itself. The position and scale of the content is preserved well enough that a user will not lose their place on the page.
These `android:configChanges` activity parameter in file `AndroidManifest.xml` configures the application to handle screen orientation changes instead of restarting:

```xml
<activity
  ...
  android:name='WebviewtutorialActivity'
  android:configChanges='orientation|screenSize'>
  ...
</activity>
```
Handling the orientation/screen-size configuration change is described at: 

http://developer.android.com/guide/topics/resources/runtime-changes.html

[Back to contents](#contents)

