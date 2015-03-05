describe 'Password-Entropy Directive', ->
  
  beforeEach module('passwordEntropy')
  compile = undefined
  rootScope = undefined

  beforeEach module (($provide) ->
    mockEntropyService = {scorePassword: (pass) -> 
      switch pass
        when "bad password" then 0
        when "password 1" then 15
        when "password 2" then 20
        when "good password" then 100
        else 0  
    }
    $provide.value 'EntropyService', mockEntropyService
    return 
  ) 

  beforeEach inject(($compile, $rootScope) ->
    compile = $compile
    rootScope = $rootScope
    return
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
    scope.pwd = "good password"
    directive = '''<password-entropy password="pwd"></password-entropy>'''   
    element = compile(directive)(scope)
    scope.$digest()
    compiledElementScope = element.isolateScope()
    expect(compiledElementScope.score).toEqual(100)

  it 'should score this password under 20', ->
    scope = rootScope.$new()
    scope.pwd = "bad password"
    directive = '''<password-entropy password="pwd"></password-entropy>'''   
    element = compile(directive)(scope)
    scope.$digest()
    compiledElementScope = element.isolateScope()
    expect(compiledElementScope.score).toBeLessThan(20)

  it 'should label this password with the given option', ->
    scope = rootScope.$new()
    scope.pwd = "good password"
    scope.opt = 
      '0': ['progress-bar-danger',  'Weak password']  
      '75': ['progress-bar-success', 'Strong password']  
    directive = '''<password-entropy password="pwd" options="opt">
                   </password-entropy>'''
    element = compile(directive)(scope)
    scope.$digest()
    compiledElementScope = element.isolateScope()
    expect(compiledElementScope.colorBar).toEqual("progress-bar-success")
    expect(compiledElementScope.veredict(compiledElementScope.score))
      .toEqual("Strong password")
    
  it 'should recalculate the score when password is changed', ->
    {firstScore, secondScore} = {0, 0}
    scope = rootScope.$new()
    scope.pwd = "password 1"
    directive = '<password-entropy password="pwd"></password-entropy>'
    element = compile(directive)(scope)
    scope.$digest()
    compiledElementScope = element.isolateScope()
    firstScore = compiledElementScope.score
    scope.pwd = "password 2"
    scope.$digest()
    secondScore = compiledElementScope.score
    expect(firstScore).not.toEqual(secondScore)
