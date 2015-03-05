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
    
  # it 'should be 0 for null', ->
  #   expect(EntropyService.scorePassword(null)).toBeLessThan(1)