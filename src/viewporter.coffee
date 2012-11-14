class @Viewporter
  
  constructor: (@element_id, @params = {}) ->
    @element = null
    if @element_id? and document.getElementById(@element_id)?
      @element = document.getElementById(@element_id)
    
    @loggingLevel = 0
    
    @isAndroid = navigator.userAgent.match(/Android/i)
    @isIphone = navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPod/i)
    @isChrome = navigator.userAgent.match(/Chrome/i) || navigator.userAgent.match(/CriOS/i)
    
    @pixelRatio = 1
    if window.devicePixelRatio
      @pixelRatio = window.devicePixelRatio
    
    @previousScreenSize = width: 0, height: 0
    @viewportChanged = false
    @viewportWidth = 320
    @viewportHeight = 480
    
    @fullWidthLandscape = true
    @fullHeightLandscape = true
    @fullWidthPortrait = true
    @fullHeightPortrait = true
    
    if window.innerWidth < window.innerHeight
      @windowInnerWidth = window.innerWidth/@pixelRatio
      @windowInnerHeight = window.innerHeight/@pixelRatio
    else
      @windowInnerWidth = window.innerHeight/@pixelRatio
      @windowInnerHeight = window.innerWidth/@pixelRatio
    
    @resolutionsSeen = []
    
    window.addEventListener "ondeviceorientation", @orientationChanged
    window.addEventListener "orientationchange", @orientationChanged
    
    window.addEventListener "resize", (event) =>
      @trace "resize " + window.innerHeight, 2
      if @isIphone or @isAndroid
        @resetViewportIfChanged()
      else
        @calculateWindowSize()
        @setupViewport()
    
    @interval = 300
    
    if @params? and typeof @params == "object"
      for prop, val of @params
        @[prop] = val
    
    @hideAddressBar()
    if @isIphone
      setTimeout () =>
        @monitorSize()
      , @interval
    
    setTimeout () =>
      @calculateWindowSize()
      @setupViewport()
      setTimeout @hideAddressBar, 1
    
      addEventListener "load", () ->
        setTimeout @hideAddressBar, 0
        setTimeout @hideAddressBar, 10
    , 10
    
    @trace navigator.userAgent, 2
  
  monitorSize: (event) =>
    @resetViewportIfChanged()
    setTimeout () =>
      @monitorSize()
    , @interval
  
  orientationChanged: () =>
    if @element?.style?
      @element.style.display = "none"
    @trace "orientationchange", 2
    @calculateWindowSize()
    @setupViewport()
  
  resetViewportIfChanged: () =>
    #@trace "@resetViewportIfChanged()", 2
    if @isLandscape
      @calculateWindowSize()
      if @actualScreenWidth != @previousScreenSize.width || @actualScreenHeight != @previousScreenSize.height
        #@trace "RESIZE detected.. " + @previousScreenSize.height + " => " + @actualScreenHeight, 2
        @setupViewport()
        @previousScreenSize.width = @actualScreenWidth
        @previousScreenSize.height = @actualScreenHeight
        setTimeout () =>
          @setupViewport()
        , 300
  
  calculateWindowSize: () ->
    @viewportWidth = 320
    @viewportHeight = 480
    @viewportScale = 1
    
    @isLandscape = true
    if typeof window.orientation != "undefined"
      @isLandscape = if Math.abs(window.orientation) == 90 then true else false
    else
      @isLandscape = window.innerWidth > window.innerHeight
    
    @actualScreenWidth = @orientedWidth()
    @actualScreenHeight = @orientedHeight()
    
    window.innerHeight
    #@trace "@oriented : "+@orientedWidth()+"x"+@orientedHeight()+" @ "+@pixelRatio, 2
    #@trace "window.inner : "+window.innerWidth+"x"+window.innerHeight, 2
    
    sw = screen.width/@pixelRatio
    sh = screen.height/@pixelRatio
    if sw > sh
      sw = sh
      sh = screen.width/@pixelRatio
    
    statusBarHeight = 10
    navBarHeight = 44
    addressBarHeight = 60
    
    if @isIphone
      lowerHeight = if @isChrome then 256 else 268
      upperHeight = 320
      upperHeightWithBar = 260
      
      if @isLandscape
        if @actualScreenHeight <= lowerHeight && @actualScreenHeight != upperHeightWithBar
          #@trace "BUMP " + @actualScreenHeight + " -> 268", 2
          @actualScreenHeight = lowerHeight
      else
        if @actualScreenHeight == 444
          @actualScreenHeight += addressBarHeight
      
      if @actualScreenHeight >= upperHeightWithBar && @actualScreenHeight != lowerHeight && @actualScreenHeight < upperHeight
        #@trace "BUMP " + @actualScreenHeight + " -> 320", 2
        @actualScreenHeight = upperHeight
    
    found = false
    for i in [0..@resolutionsSeen.length]
      if i < @resolutionsSeen.length
        if @resolutionsSeen[i]?.width == @actualScreenWidth && @resolutionsSeen[i].height == @actualScreenHeight
          found = true
    
    if !@isLandscape
      #@viewportScale = 1
      if @isIphone
        @actualScreenHeight += 0 #statusBarHeight + navBarHeight
    
    if !found
      @resolutionsSeen.push {width: @actualScreenWidth, height: @actualScreenHeight}
    
    if typeof window.orientation == "undefined" and !@isIphone and !@isAndroid
      @actualScreenWidth = window.innerWidth
      @actualScreenHeight = window.innerHeight
    
    @viewportChanged = false
    if @viewportWidth != @actualScreenWidth or @viewportHeight != @actualScreenHeight
      @viewportChanged = true
    
    @viewportWidth = @actualScreenWidth
    @viewportHeight = @actualScreenHeight
    @viewportScale = @actualScreenWidth/@viewportWidth
    
    #@trace "Calculated: #{@actualScreenWidth} x #{@actualScreenHeight}", 2
  
  setupViewport: () =>
    viewport = document.querySelector "meta[name=viewport]"
    
    #@viewportHeight = 3000
    #@trace(@viewportWidth+"x"+@viewportHeight+" @ "+@viewportScale), 2
    @trace "#{screen.width}x#{screen.height} / #{@viewportWidth}x#{@viewportHeight}", 2
    h = (@viewportHeight + Math.random()*.1)
    w = @viewportWidth
    s = @viewportScale
    if @isAndroid and @isChrome
      h = @viewportHeight + 0
      w = @viewportWidth + 0
    
    viewportProperties = []
    viewportProperties.push "initial-scale=" + s
    viewportProperties.push "minimum-scale=" + s
    viewportProperties.push "maximum-scale=" + s
    viewportProperties.push "user-scalable=no"
    
    body = document.getElementsByTagName "body"
    
    setWidth = (@isLandscape and @fullWidthLandscape) or (!@isLandscape and @fullWidthPortrait)
    setHeight = (@isLandscape and @fullHeightLandscape) or (!@isLandscape and @fullHeightPortrait)
    
    if setWidth
      viewportProperties.push "width=" + w
      if @element?.style?
        @element.style.width = @viewportWidth + "px"
        @element.style["overflow-x"] = "hidden"
      if body?[0]?.style?
        body[0].style.width = @viewportWidth + "px"
    else
      if @element?.style?
        @element.style.width = "inherit"
        @element.style["overflow-x"] = "auto"
      if body?[0]?.style?
        body[0].style.width = ""
    
    if setHeight
      viewportProperties.push "height=" + h
      if @element?.style?
        @element.style.height = @viewportHeight + "px"
        @element.style["overflow-y"] = "hidden"
      if body?[0]?.style?
        body[0].style.height = @viewportHeight + "px"
    else
      if @element?.style?
        @element.style.height = "inherit"
        @element.style["overflow-y"] = "auto"
      if body?[0]?.style?
        body[0].style.height = ""
    
    viewportContent = viewportProperties.join ", "
    
    if @element?.style?
      setTimeout () =>
        @element.style.display = "block"
      , 100
    
    @trace viewportContent, 2
    
    if !@isAndroid or !@isChrome
      viewport.setAttribute "content", "width = device-width, height = device-height, initial-scale = 1, minimum-scale = 1, maximum-scale = 1, user-scalable = no"
    
    setTimeout () =>
      viewport.setAttribute "content", viewportContent
    , 30
    
    setTimeout @hideAddressBar, 1
    
    if @viewportChanged
      event = document.createEvent "Event"
      event.initEvent "viewportchanged", true, true
      event.width = @viewportWidth
      event.height = @viewportHeight
      event.isLandscape = @isLandscape
      window.dispatchEvent event
  
  orientedWidth: () ->
    w = if @isLandscape then @screenHeight() else @screenWidth()
  
  orientedHeight: () ->
    if @isIphone or @isChrome
      windowRatio = if window.innerWidth > window.innerHeight then window.innerWidth / window.innerHeight else window.innerHeight / window.innerWidth
      h = @orientedWidth() * (if @isLandscape then 1 / windowRatio else windowRatio)
    else
      h = if @isLandscape then @screenWidth() else @screenHeight()
    Math.round h
  
  screenWidth: () ->
    div = if @isAndroid then 1 / @pixelRatio else 1
    sw = if screen.width < screen.height then screen.width * div else screen.height * div
  
  screenHeight: () ->
    div = if @isAndroid then 1 / @pixelRatio else 1
    sh = if screen.width > screen.height then screen.width * div else screen.height * div
  
  hideAddressBar: () ->
    window.scrollTo 0, 0
    setTimeout () ->
      window.scrollTo 0, 1
    , 100
  
  trace: (str, level) ->
    if @loggingLevel > 0
      if console?.log?
        console.log str
      if level <= @loggingLevel
        log = document.getElementById "log"
        if log?
          log.innerHTML = str + "<br />\n" + log.innerHTML
          if log.innerHTML.length > 2000
            log.innerHTML = log.innerHTML.substring 0, 2000





