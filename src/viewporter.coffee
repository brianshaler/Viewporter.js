class @Viewporter
  
  constructor: (@element_id, @logging_level = 0) ->
    @element = null
    if @element_id? and document.getElementById(@element_id)?
      @element = document.getElementById(@element_id)
    
    @isAndroid = navigator.userAgent.match(/Android/i)
    @isIphone = navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPod/i)
    @isChrome = navigator.userAgent.match(/Chrome/i) || navigator.userAgent.match(/CriOS/i)
    
    if @isChrome
      @trace "I'm chrome!", 2
    else
      @trace "I'm not chrome.. ", 2
    #@isAndroid = !@isIphone
    
    @pixelRatio = 1
    if window.devicePixelRatio
      @pixelRatio = window.devicePixelRatio
    
    @previousScreenSize = width: 0, height: 0
    @viewportChanged = false
    @viewportWidth = 320
    @viewportHeight = 480
    
    if window.innerWidth < window.innerHeight
      @windowInnerWidth = window.innerWidth/@pixelRatio
      @windowInnerHeight = window.innerHeight/@pixelRatio
    else
      @windowInnerWidth = window.innerHeight/@pixelRatio
      @windowInnerHeight = window.innerWidth/@pixelRatio
    
    @resolutionsSeen = []
    @hideAddressBar()
    
    window.addEventListener "ondeviceorientation", (event) =>
      @trace "ondeviceorientation", 2
      @calculateWindowSize()
      @setupViewport()
    
    window.addEventListener "orientationchange", (event) =>
      @trace "orientationchange", 2
      @calculateWindowSize()
      @setupViewport()
    
    window.addEventListener "resize", (event) =>
      @trace "resize " + window.innerHeight, 2
      @resetViewportIfChanged()
    
    @interval = 300
    
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
  
  monitorSize: () =>
    @resetViewportIfChanged()
    setTimeout () =>
      @monitorSize()
    , @interval
  
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
    
    viewportContent = "width=" + w + ", height=" + h + ", initial-scale=" + s + ", minimum-scale=" + s + ", maximum-scale=" + s + ", user-scalable=no"
    
    body = document.getElementsByTagName "body"
    if body?[0]?.style?
      body[0].style.height = @viewportHeight + "px"
    
    if @isAndroid and @isChrome and @element?
      @element.style.display = "none"
      setTimeout () =>
        @element.style.display = "block"
      , (if @isAndroid and @isChrome then 500 else 10)
    
    if @element?
      @element.style.height = @viewportHeight + "px"
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
    if @logging_level > 0
      if console?.log?
        console.log str
      if level <= @logging_level
        log = document.getElementById "log"
        if log?
          log.innerHTML = str + "<br />\n" + log.innerHTML
          if log.innerHTML.length > 2000
            log.innerHTML = log.innerHTML.substring 0, 2000





