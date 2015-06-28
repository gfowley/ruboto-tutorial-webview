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

  @JavascriptInterface
  public void image_loaded( int w, int h ) {
    JRubyAdapter.runRubyMethod( scriptInfo.getRubyInstance(), "image_loaded", new Object[]{ w, h } );
  }

  {
    scriptInfo.setRubyClassName(getClass().getSimpleName());
    ScriptLoader.loadScript(this);
  }

}

