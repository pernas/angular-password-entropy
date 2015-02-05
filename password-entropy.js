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
                $scope.veredict = function(pass){
                    var H = EntropyService.entropy(pass);
                    var message = "";
                    for(var key in $scope.options) {
                      if($scope.options.hasOwnProperty(key)) {
                        if (H > key) {
                          $scope.colorBar = $scope.options[key][0];
                          message = $scope.options[key][1];
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
          ctrl.$parsers.unshift(checkForEven);

          function checkForEven(viewValue){
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
////////////////////////////////////////////////////////////////////////////////
// Entropy Service 
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
                }
                return H;         
        }
    };
});  
