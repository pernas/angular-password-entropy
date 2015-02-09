'use strict';

angular.module('passwordEntropy', [])
////////////////////////////////////////////////////////////////////////////////
// entropy bar meter directive
    .directive('passwordEntropy', ['EntropyService', function (EntropyService) {
        return {
            restrict: 'E',
            template: '<div ng-show="password" class="progress"> \
                         <div class="progress-bar {{colorBar}}" \
                              role="progressbar" \
                              aria-valuemin="0" \
                              aria-valuemax="100" \
                              style="width: {{entropy(password)}}%;"> \
                           {{veredict(password)}} \
                         </div>\
                        </div>',
            controller: ['$scope',
              function($scope){

                $scope.colorBar = "progress-bar-danger";
                var defaultOpt = {
                    '0':  ['progress-bar-danger', 'weak'],
                    '25': ['progress-bar-warning', 'regular'],
                    '50': ['progress-bar-info', 'normal'],
                    '75': ['progress-bar-success', 'strong']
                  };
                $scope.optionsUsed = $scope.options || defaultOpt;
                $scope.veredict = function(pass){
                    var H = EntropyService.entropy(pass);
                    var message = "";
                    for(var key in $scope.optionsUsed) {
                      if($scope.optionsUsed.hasOwnProperty(key)) {
                        if (H > key) {
                          $scope.colorBar = $scope.optionsUsed[key][0];
                          message = $scope.optionsUsed[key][1];
                        }
                      }
                    }
                    return message;
                };
                $scope.entropy = EntropyService.entropy;
              }
            ],
            scope: {
                 password: '=',
                 options: '='
            }
        };

}])
////////////////////////////////////////////////////////////////////////////////
// validation rule
  .directive('minEntropy', ['EntropyService', function (EntropyService){
      return{
        require:'ngModel',
        link: function(scope, elem, attrs, ctrl){
          ctrl.$parsers.unshift(checkEntropy);

          function checkEntropy(viewValue){
            var minimumEntropy = parseFloat(attrs.minEntropy);
            var H = EntropyService.entropy(viewValue);
            if (H > minimumEntropy) {
              ctrl.$setValidity('minEntropy',true);
            }
            else{
              ctrl.$setValidity('minEntropy', false);
            }
            return viewValue;
          }
        }
      };
}])
  .factory('EntropyService', function () {
    var hasLowerCase = function (str){
        return (/[a-z]/.test(str));
    };
    var hasUpperCase = function (str){
        return (/[A-Z]/.test(str));
    };
    var hasNumbers = function (str){
        return (/[0-9]/.test(str));
    };
    var hasPunctuation = function (str){
        return (/[-!$%^&*()_+|~=`{}\[\]:";'<>?,.\/]/.test(str));
    };
    var badPatterns = function (pass, H) {
      
      var patterns = [ /^\d+$/                  // all digits
                     , /^[a-z]+\d$/             // all lower 1 digit
                     , /^[A-Z]+\d$/             // all upper 1 digit
                     , /^[a-zA-Z]+\d$/          // all letters 1 digit
                     , /^[a-z]+\d+$/            // all lower then digits
                     , /^[a-z]+$/               // all lower
                     , /^[A-Z]+$/               // all upper
                     , /^[A-Z][a-z]+$/          // 1 upper all lower
                     , /^[A-Z][a-z]+\d$/        // 1 upper, lower, 1 digit
                     , /^[A-Z][a-z]+\d+$/       // 1 upper, lower, digits
                     , /^[a-z]+[._!\- @*#]$/    // all lower 1 special
                     , /^[A-Z]+[._!\- @*#]$/    // all upper 1 special
                     , /^[a-zA-Z]+[._!\- @*#]$/ // all letters 1 special
                     , /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$/  //email
                     , /^[a-z\-ZA-Z0-9.-]+$/    // web address
                     ];
      var entropy = H;
      angular.forEach(patterns, function(pattern) {
        if (pattern.test(pass)) {
          entropy = entropy / 2;
        }
      });
      return entropy;
    };

    return {
        entropy: function(pass) {

                var H = 0;
                if(pass) {
                  var base = 0;
                  if (hasLowerCase(pass)) {
                    base += 26;
                  }
                  if (hasUpperCase(pass)) {
                    base += 26;
                  }
                  if (hasNumbers(pass)) {
                    base += 10;
                  }
                  if (hasPunctuation(pass)) {
                    base += 30;
                  }

                  var H = Math.log2(Math.pow(base, pass.length));
                  //fit to max entropy
                  if (H > 100) {H = 100};
                  //lower ratio for bad patterns
                  H = badPatterns(pass,H);
                }
                return H;         
        }
    };
});  
