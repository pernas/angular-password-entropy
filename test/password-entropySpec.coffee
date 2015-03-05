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
  
  it 'should render HTML based on scope correctly', ->

    scope = rootScope.$new()
    scope.pwd = ''    
    element = compile('<password-entropy' + ' password="pwd">' + '</password-entropy>')(scope)
    scope.$digest()
    expect(element.html()).toContain 'progress-bar-'
