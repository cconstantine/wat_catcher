#Send the error to the same host that served this file (I think)
class @WatCatcher
  appEnv: undefined
  appEnvsToWorryAbout: []

  constructor: (target=window) ->
    @oldErrorHandler = target.onerror
    target.onerror = @watHandler

  watHandler: (msg, url, line) =>
    if @appEnvsToWorryAbout.indexOf(@appEnv) >= 0
      xmlhttp = if window.XMLHttpRequest
          new XMLHttpRequest()
      else
          new ActiveXObject("Microsoft.XMLHTTP")

      params =  "wat[page_url]=#{escape(window.location.toString())}"
      params += "&wat[message]=#{escape(msg)}"
      params += "&wat[backtrace][]=#{escape(url+":"+line)}"
      params += "&wat[app_env]=#{escape(@appEnv)}"

      xmlhttp.open("POST", "/wats", true);
      xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      xmlhttp.setRequestHeader("X-Requested-With", "XMLHttpRequest");
      xmlhttp.send(params);

    if typeof @oldErrorHandler == 'function'
      @oldErrorHandler(msg, url, line)

window.watCatcher = new WatCatcher()