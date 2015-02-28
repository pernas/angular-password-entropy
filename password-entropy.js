(function() {
  'use strict';
  var hasProp = {}.hasOwnProperty;

  angular.module('passwordEntropy', []).directive('passwordEntropy', [
    'EntropyService', function(EntropyService) {
      return {
        restrict: 'E',
        template: '<div ng-show="password" class="progress"> <div class="progress-bar" ng-class=colorBar role="progressbar" aria-valuenow="{{score}}"" aria-valuemin="0" aria-valuemax="100" ng-style="{width: score + \'%\'}" > {{veredict(score)}}</div></div>',
        controller: [
          '$scope', function($scope) {
            var defaultOpt;
            $scope.score = 0;
            $scope.colorBar = 'progress-bar-danger';
            defaultOpt = {
              '0': ['progress-bar-danger', 'weak'],
              '25': ['progress-bar-warning', 'regular'],
              '50': ['progress-bar-info', 'normal'],
              '75': ['progress-bar-success', 'strong']
            };
            $scope.optionsUsed = $scope.options || defaultOpt;
            $scope.veredict = function(score) {
              var message, opt, opts, ref, thold;
              ref = $scope.optionsUsed;
              for (thold in ref) {
                if (!hasProp.call(ref, thold)) continue;
                opts = ref[thold];
                if (thold <= score) {
                  opt = opts;
                }
              }
              $scope.colorBar = opt[0];
              return message = opt[1];
            };
            $scope.entropy = EntropyService.scorePassword;
            return $scope.$watch('password', function(nV, oV) {
              return $scope.score = $scope.entropy(nV);
            });
          }
        ],
        scope: {
          password: '=',
          options: '='
        }
      };
    }
  ]).directive('minEntropy', [
    'EntropyService', function(EntropyService) {
      return {
        require: 'ngModel',
        link: function(scope, elem, attrs, ctrl) {
          var checkEntropy;
          checkEntropy = function(viewValue) {
            var minimumEntropy, score;
            minimumEntropy = parseFloat(attrs.minEntropy);
            score = EntropyService.scorePassword(viewValue);
            if (score > minimumEntropy) {
              ctrl.$setValidity('minEntropy', true);
            } else {
              ctrl.$setValidity('minEntropy', false);
            }
            return viewValue;
          };
          ctrl.$parsers.unshift(checkEntropy);
        }
      };
    }
  ]).factory('Maybe', function() {
    var Just, Nothing, _bind, _unit;
    _bind = function(f) {
      switch (this) {
        case Nothing:
          return Nothing;
        default:
          return f(this.val);
      }
    };
    _unit = function(input) {
      return Object.freeze({
        val: input != null ? input : null,
        bind: _bind
      });
    };
    Nothing = _unit(null);
    Just = function(input) {
      if (input != null) {
        return _unit(input);
      } else {
        return Nothing;
      }
    };
    return {
      Nothing: Nothing,
      Just: Just
    };
  }).factory('EntropyService', [
    'Maybe', function(Maybe) {
      var Just, Nothing, base, entropy, entropyWeighted, hasDigits, hasLowerCase, hasPunctuation, hasUpperCase, maybePassword, password, patternsList, quality, score, scorePasswordM;
      score = 0;
      password = '';
      Nothing = Maybe.Nothing;
      Just = Maybe.Just;
      patternsList = [[0.25, /^\d+$/], [0.25, /^[a-z]+\d$/], [0.25, /^[A-Z]+\d$/], [0.5, /^[a-zA-Z]+\d$/], [0.5, /^[a-z]+\d+$/], [0.25, /^[a-z]+$/], [0.25, /^[A-Z]+$/], [0.25, /^[A-Z][a-z]+$/], [0.25, /^[A-Z][a-z]+\d$/], [0.5, /^[A-Z][a-z]+\d+$/], [0.25, /^[a-z]+[._!\- @*#]$/], [0.25, /^[A-Z]+[._!\- @*#]$/], [0.5, /^[a-zA-Z]+[._!\- @*#]$/], [0.25, /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$/], [1, /^.*$/]];
      Math.log2 = function(x) {
        return Math.log(x) / Math.LN2;
      };
      hasDigits = function(str) {
        return /[0-9]/.test(str);
      };
      hasLowerCase = function(str) {
        return /[a-z]/.test(str);
      };
      hasUpperCase = function(str) {
        return /[A-Z]/.test(str);
      };
      hasPunctuation = function(str) {
        return /[-!$%^&*()_+|~=`{}\[\]:";'<>?@,.\/]/.test(str);
      };
      base = function(str) {
        var b, bases, t, tuples;
        tuples = [[10, hasDigits(str)], [26, hasLowerCase(str)], [26, hasUpperCase(str)], [31, hasPunctuation(str)]];
        bases = (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = tuples.length; i < len; i++) {
            t = tuples[i];
            if (t[1]) {
              results.push(t[0]);
            }
          }
          return results;
        })();
        b = bases.reduce((function(t, s) {
          return t + s;
        }), 0);
        if (b === 0) {
          return 1;
        } else {
          return b;
        }
      };
      maybePassword = function(str) {
        if (str === "" || (str == null) || (typeof str) !== 'string') {
          return Nothing;
        } else {
          return Just(str);
        }
      };
      entropy = function(str) {
        return maybePassword(str).bind(function(pw) {
          return Just(Math.log2(Math.pow(base(pw), pw.length)));
        });
      };
      quality = function(str, patterns) {
        var p;
        return Math.min.apply(this, (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = patterns.length; i < len; i++) {
            p = patterns[i];
            if (p[1].test(str)) {
              results.push(p[0]);
            }
          }
          return results;
        })());
      };
      entropyWeighted = function(str, patterns) {
        return (entropy(str)).bind(function(e) {
          return Just(e * quality(str, patterns));
        });
      };
      scorePasswordM = function(str) {
        var s;
        s = entropyWeighted(str, patternsList);
        switch (s) {
          case Nothing:
            return 0;
          default:
            if (s.val > 100) {
              return 100;
            } else {
              return s.val;
            }
        }
      };
      return {
        scorePassword: function(pass) {
          if (pass !== password) {
            password = pass;
            return score = scorePasswordM(pass);
          } else {
            return score;
          }
        }
      };
    }
  ]);

}).call(this);
