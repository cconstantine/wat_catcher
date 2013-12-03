parseJson = JSON.parse || jQuery.parseJSON

#Send the error to the same host that served this file (I think)
class @WatCatcher
  constructor: (target=window) ->
    scripts = document.getElementsByTagName("script");
    node = scripts[scripts.length - 1];
    @attrs = {}
    for attr in node.attributes
      attrs = /data-(.*)/.exec(attr.nodeName)
      if attrs?
        @attrs[attrs[1]] = attr.nodeValue


    @app_user = parseJson(@attrs["app-user"]) if (parseJson? && @attrs["app-user"])

    @oldErrorHandler = target.onerror
    target.onerror = @watHandler

  toQuery: (params, prefix="") ->
    query = ""

    unless params instanceof Object
      return "#{prefix}=#{params}&"

    for k, v of params
      k = encodeURIComponent(k)
      k = if prefix == "" then k else "#{prefix}[#{k}]"
      if v instanceof Array
        for i in v
          query += @toQuery(i, "#{k}[]")
      else if v instanceof Object
        query += "#{@toQuery(v, k)}"
      else
        query += "#{k}=#{encodeURIComponent(v)}&"
    query

  watHandler: (msg, url, line) =>
    try
      params = {
        wat: {
          page_url:  window.location.toString()
          message:   msg
          backtrace: [url+":"+line]
          language: "javascript"
          app_user: @app_user
        }
      }

      xmlhttp = if window.XMLHttpRequest
          new XMLHttpRequest()
      else
          new ActiveXObject("Microsoft.XMLHTTP")

      xmlhttp.open("POST", @attrs.route, true);
      xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      xmlhttp.setRequestHeader("X-Requested-With", "XMLHttpRequest");
      xmlhttp.send(@toQuery(params));

    catch error
      if typeof @oldErrorHandler == 'function'
        @oldErrorHandler(arguments...)


window.watCatcher = new WatCatcher()