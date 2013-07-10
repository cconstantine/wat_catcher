describe "WatCatcher", ->
  beforeEach ->
    @errorTarget = {}
    @errorTarget.onerror = -> "Howdy"
    @watCatcher = new WatCatcher @errorTarget
    @watCatcher.appEnv = 'production'

    @msg = 'sadly, there was a terrible mistake'
    @line = '42'

  it "attaches watHandler to onerror argument", ->
    @watCatcher.watHandler(@msg, document.URL, @line)
    expect(@errorTarget.onerror).toEqual @watCatcher.watHandler

  it "preserves previous onerror handler", ->
    @watCatcher.watHandler(@msg, document.URL, @line)
    expect(@watCatcher.watHandler()).toEqual "Howdy"

