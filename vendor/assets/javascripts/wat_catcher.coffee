#Send the error to the same host that served this file (I think)
class @WatCatcher


  constructor: (target=window) ->
    scripts = document.getElementsByTagName("script");
    node = scripts[scripts.length - 1];
    for attr in node.attributes
      if attr.nodeName == 'data-host'
        @host = attr.nodeValue
      if attr.nodeName == 'data-app_env'
        @appEnv = attr.nodeValue
      if @appEnv? && @host?
        break

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
          app_env:   @appEnv
        }
      }

      img = new Image()
      img.src = "#{@host}/create/wat?#{@toQuery(params)}"
    catch error

    if typeof @oldErrorHandler == 'function'
      @oldErrorHandler(arguments...)


window.watCatcher = new WatCatcher()