describe 'EntropyService test', ->
  
  EntropyService = undefined
  
  beforeEach ->
    module 'passwordEntropy'
    inject (_EntropyService_) ->
      EntropyService = _EntropyService_
       
  it 'should be 0 for null', ->
    expect(EntropyService.scorePassword(null)).toEqual(0)

  it 'should be 0 for undefined', ->
    expect(EntropyService.scorePassword(undefined)).toEqual(0)

  it 'should be 0 for an empty string', ->
    expect(EntropyService.scorePassword("")).toEqual(0)

  it 'should be 0 for non string objects', ->
    expect(EntropyService.scorePassword([1,2,3])).toEqual(0)
   
  # bad passwords #############################################  
  it 'should score bad passwords really low (1)', ->
    pass = "123456789"
    expect(EntropyService.scorePassword(pass)).toBeLessThan(25)
  
  it 'should score bad passwords really low (2)', ->
    pass = "helloworld"
    expect(EntropyService.scorePassword(pass)).toBeLessThan(25)
  
  it 'should score bad passwords really low (3)', ->
    pass = "hello world"
    expect(EntropyService.scorePassword(pass)).toBeLessThan(25)

  it 'should score bad passwords really low (4)', ->
    pass = "Pass1234"
    expect(EntropyService.scorePassword(pass)).toBeLessThan(25)

  it 'should score bad passwords really low (5)', ->
    pass = "name@surname.com"
    expect(EntropyService.scorePassword(pass)).toBeLessThan(25)

  # strong passwords ##########################################
  it 'should score strong passwords really high (1)', ->
    pass = "correct horse battery staple"
    expect(EntropyService.scorePassword(pass)).toBeGreaterThan(30)
  
  it 'should score strong passwords really high (2)', ->
    pass = '''repair distance can client vicious slice 
              drastic embrace amateur picnic proof volume'''
    expect(EntropyService.scorePassword(pass)).toBeGreaterThan(90)
  
  it 'should score strong passwords really high (3)', ->
    pass = "!$0p4 63 M1$0!"
    expect(EntropyService.scorePassword(pass)).toBeGreaterThan(50)

  it 'should score strong passwords really high (4)', ->
    pass = "mAe3CistpmcdtP"
    expect(EntropyService.scorePassword(pass)).toBeGreaterThan(50)

  it 'should score strong passwords really high (5)', ->
    pass = "¡Qué bonita es la teoría de Galois!"
    expect(EntropyService.scorePassword(pass)).toEqual(100)