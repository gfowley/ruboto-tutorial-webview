require 'ruboto/widget'
require 'ruboto/util/toast'

require_relative 'jscallback.rb'
require_relative 'jsi.rb'

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
    @jsi = Java::OrgRubotoWebviewtutorial::Jsi.new
    @jsi.context = self    # fix: make Jsi.java constructor accept self to set context in initialize
    @webview.add_javascript_interface @jsi, 'jsi'
    @webview.load_url "file:///android_asset/html/tutorial.html"
  end

    # wvc = Webviewclient.new(wv)
    # wv.web_view_client = wvc
    # set.allow_file_access = true
    # set.java_script_can_open_windows_automatically = true
    # wv.clear_cache true
    # wv.clear_history
    # wv.background_color = android::graphics::Color::GRAY
    # wv.horizontal_scrollbar_overlay = true
    # wv.vertical_scrollbar_overlay = true
  
  def setup_menu menu
    menu.add( 'Add item'               ).set_on_menu_item_click_listener proc { eval_js_add_item               ; true } 
    menu.add( 'Add item return count'  ).set_on_menu_item_click_listener proc { eval_js_add_item_return_count  ; true } 
    menu.add( 'Load image return size' ).set_on_menu_item_click_listener proc { eval_js_load_image_return_size ; true } 
    menu.add( 'Remove image'           ).set_on_menu_item_click_listener proc { eval_js_remove_image           ; true } 
    menu.add( 'Load image jsi size'    ).set_on_menu_item_click_listener proc { eval_js_load_image_jsi_size    ; true } 
  end

  def eval_js_add_item
    @webview.evaluate_javascript "add_item('#{Time.now}')", nil
  end

  def eval_js_add_item_return_count
    @webview.evaluate_javascript "add_item('#{Time.now}')", Jscallback.new( self )
  end

  def eval_js_load_image_return_size
    @webview.clear_cache true
    @webview.evaluate_javascript "load_image_return_size()", Jscallback.new( self ) 
  end

  def eval_js_remove_image
    @webview.evaluate_javascript "remove_image()", nil
  end

  def eval_js_load_image_jsi_size
    @webview.clear_cache true
    @webview.evaluate_javascript "load_image_jsi_size()", nil
  end

end

