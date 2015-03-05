// File: chapter12/stockDirectiveRenderSpec.js
describe('Password-Entropy Directive B Rendering', function() {

  beforeEach(module('passwordEntropy'));

  var compile, mockBackend, rootScope;

  // Step 1
  beforeEach(inject(function($compile, $httpBackend, $rootScope) {
    compile = $compile;
    mockBackend = $httpBackend;
    rootScope = $rootScope;
  }));

  it('should render HTML based on scope correctly', function() {
    // Step 2
    var scope = rootScope.$new();
   
      scope.pwd = "badpassword badpassword 33 badpassword B badpassword";
      // scope.testSubmit = function() {alert("Hola!!");};
      scope.myOpt = {
                   '0': ['progress-bar-danger',  'very weak'],
                  '15': ['progress-bar-danger',  'weak'],
                  '35': ['progress-bar-warning',  'normal'],
                  '50': ['progress-bar-success', 'strong'],
                  '70': ['progress-bar-success', 'very strong']
      };

    // Step 3
    // mockBackend.expectGET('stock.html').respond(
    //   '<div ng-bind="stockTitle"></div>' +
    //   '<div ng-bind="stockData.price"></div>');

    // Step 4
    var element = compile('<password-entropy' +
      ' password="pwd"' +
      ' options="myOpt"></password-entropy>')(scope);

    // Step 5
    scope.$digest();
    // mockBackend.flush();

    // Step 6
    expect(element.html()).toContain(
      'progress-bar-success');
  });
});