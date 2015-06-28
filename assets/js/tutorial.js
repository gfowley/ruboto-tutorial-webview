
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

function load_image_jsi_size() {
  var image = document.createElement('img')
  var images = document.getElementById( 'tutorial-images' )
  images.appendChild(image)
  image.src = 'file:///android_res/drawable/get_ruboto_core.png'
  image.onload = function() {
    jsi.image_loaded( image.width, image.height )
  }
}

