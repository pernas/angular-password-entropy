describe 'Password-Entropy Directive Rendering', ->
  
  beforeEach module('passwordEntropy')
  compile = undefined
  mockBackend = undefined
  rootScope = undefined

  beforeEach inject(($compile, $httpBackend, $rootScope) ->
      compile = $compile
      mockBackend = $httpBackend
      rootScope = $rootScope
  )
  
  it 'should render HTML correctly', ->
    scope = rootScope.$new()
    scope.pwd = ""
    directive = '<password-entropy password="pwd"></password-entropy>'
    element = compile(directive)(scope)
    scope.$digest()
    expect(element.html()).toContain 'progress-bar-'

  it 'should have data on scope correctly', ->
    scope = rootScope.$new()
    scope.pwd = "mypassword"
    scope.opt = 
      '0': ['progress-bar-success', 'Strong']   
    directive = '''<password-entropy password="pwd" options="opt">
                   </password-entropy>'''   
    element = compile(directive)(scope)
    scope.$digest()
    compiledElementScope = element.isolateScope()
    expect(compiledElementScope.password).toEqual(scope.pwd)
    expect(compiledElementScope.options).toEqual(scope.opt)

  it 'should score this password with 100', ->
    scope = rootScope.$new()
    scope.pwd = '''capable vague ancient frequent gossip mixture 
                   door common diamond catch ticket slot'''
    directive = '''<password-entropy password="pwd"></password-entropy>'''   
    element = compile(directive)(scope)
    scope.$digest()
    compiledElementScope = element.isolateScope()
    expect(compiledElementScope.score).toEqual(100)

  it 'should score this password under 20', ->
    scope = rootScope.$new()
    scope.pwd = '''helloworld'''
    directive = '''<password-entropy password="pwd"></password-entropy>'''   
    element = compile(directive)(scope)
    scope.$digest()
    compiledElementScope = element.isolateScope()
    expect(compiledElementScope.score).toBeLessThan(20)

  it 'should label this password with the given option', ->
    scope = rootScope.$new()
    scope.pwd = '''helloworld'''
    scope.opt = 
      '0': ['progress-bar-success', 'Strong password']  
    directive = '''<password-entropy password="pwd" options="opt">
                   </password-entropy>'''
    element = compile(directive)(scope)
    scope.$digest()
    compiledElementScope = element.isolateScope()
    expect(compiledElementScope.colorBar).toEqual("progress-bar-success")
    expect(compiledElementScope.veredict(compiledElementScope.score)).toEqual("Strong password")
