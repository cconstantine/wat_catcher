describe "WatCatcher", ->
  beforeEach ->
    @errorTarget = {}
    @errorTarget.onerror = -> "Howdy"
    @watCatcher = new WatCatcher @errorTarget
    @watCatcher.appEnvsToWorryAbout = ['production', 'staging', 'demo']
    @watCatcher.appEnv = 'production'

    @xmlhttp = jasmine.createSpyObj('XMLHttpRequest', ['send', 'setRequestHeader', 'open'])
    spyOn(window, 'XMLHttpRequest').andReturn(@xmlhttp)

    @msg = 'sadly, there was a terrible mistake'
    @line = '42'

  it "attaches watHandler to onerror argument", ->
    @watCatcher.watHandler(@msg, document.URL, @line)
    expect(@errorTarget.onerror).toEqual @watCatcher.watHandler

  it "preserves previous onerror handler", ->
    @watCatcher.watHandler(@msg, document.URL, @line)
    expect(@watCatcher.watHandler()).toEqual "Howdy"

  it "sends xhr on error", ->
    try
      window.goobilygoo()
    catch error
      @watCatcher.watHandler(error.message, document.URL, error.lineNumber)

    expect(@xmlhttp.send).toHaveBeenCalled()

  it "doesn't send wats in irrelevant appEnv", ->
    @watCatcher.appEnv = 'development'
    @watCatcher.watHandler(@msg, document.URL, @line)
    expect(@xmlhttp.send).not.toHaveBeenCalled()
