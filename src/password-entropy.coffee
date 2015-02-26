'use strict'
################################################################################
# Define Maybe monad
_bind = (f) -> switch this
  when Nothing then Nothing
  else f this.val

_unit = (input) ->
  Object.freeze
    val: input ? null
    bind: _bind

Nothing = _unit null

Just = (input)-> if input? then _unit input else Nothing
################################################################################

angular.module('passwordEntropy', [])
  .directive('passwordEntropy', [
      'EntropyService'
      (EntropyService) ->
        {

        restrict: 'E'
        template: '<div ng-show="password" class="progress"> \
                     <div class="progress-bar" \
                          ng-class=colorBar \
                          role="progressbar" \
                          aria-valuenow="{{H}}"" \
                          aria-valuemin="0" \
                          aria-valuemax="100" \
                          ng-style="{width: H + \'%\'}" > \
                       {{veredict(H)}}\
                     </div>\
                    </div>\
                    <span>{{H}}</span>'
        controller: [
          '$scope'
          ($scope) ->
            $scope.H = 0
            $scope.colorBar = 'progress-bar-danger'
            defaultOpt = {
              '0':  ['progress-bar-danger', 'weak'],
              '25': ['progress-bar-warning', 'regular'],
              '50': ['progress-bar-info', 'normal'],
              '75': ['progress-bar-success', 'strong']
            }
            $scope.optionsUsed = $scope.options or defaultOpt

            $scope.veredict = (H) ->
              message = ''
              for key of $scope.optionsUsed
                if $scope.optionsUsed.hasOwnProperty(key)
                  if H > key
                    $scope.colorBar = $scope.optionsUsed[key][0]
                    message = $scope.optionsUsed[key][1]
              message

            $scope.entropy = EntropyService.entropeus
            $scope.$watch('password', (newValue, oldValue) -> $scope.H = $scope.entropy newValue)
          ]
        scope:
            password: '='
            options: '='
        
    }])
  ##############################################################################
  # validation rule

  .directive('minEntropy', [
    'EntropyService'
    (EntropyService) ->
      {
        require: 'ngModel'
        link: (scope, elem, attrs, ctrl) ->
  
          checkEntropy = (viewValue) ->
            minimumEntropy = parseFloat(attrs.minEntropy)
            H = EntropyService.entropeus(viewValue)
            if H > minimumEntropy
              ctrl.$setValidity 'minEntropy', true
            else
              ctrl.$setValidity 'minEntropy', false
            viewValue
  
          ctrl.$parsers.unshift checkEntropy
          return
  
      }
  ])
  ##############################################################################
  # Entropy service

  .factory 'EntropyService', ->
    # service state
    H = 0
    password = ''

    # helpers
    Math.log2 = (x) -> Math.log(x) / Math.LN2
    hasDigits      = (str) -> /[0-9]/.test str
    hasLowerCase   = (str) -> /[a-z]/.test str
    hasUpperCase   = (str) -> /[A-Z]/.test str
    hasPunctuation = (str) -> /[-!$%^&*()_+|~=`{}\[\]:";'<>?@,.\/]/.test str
    base = (str) -> 
        tuples = [[10, hasDigits(str)]
                 ,[26, hasLowerCase(str)]
                 ,[26, hasUpperCase(str)]
                 ,[31, hasPunctuation(str)]]
        bases = (t[0] for t in tuples when t[1])
        b = bases.reduce(((t, s) -> t + s),0)
        if b is 0 then 1 else b

    maybePassword = (str) -> 
        if str is "" or !str? or (typeof str) isnt 'string' 
        then Nothing 
        else Just str

    entropy2 = (str) -> 
        maybePassword(str).bind (pw)-> 
          Just Math.log2 Math.pow(base(pw),pw.length)

    # pattern => [quality factor in {0..1}, regex]
    patternsList = 
       [ [ 0.25 ,/^\d+$/]                  # all digits
       , [ 0.25 ,/^[a-z]+\d$/]             # all lower 1 digit
       , [ 0.25 ,/^[A-Z]+\d$/]             # all upper 1 digit
       , [ 0.5  ,/^[a-zA-Z]+\d$/]          # all letters 1 digit
       , [ 0.5  ,/^[a-z]+\d+$/]            # all lower then digits
       , [ 0.25 ,/^[a-z]+$/]               # all lower
       , [ 0.25 ,/^[A-Z]+$/]               # all upper
       , [ 0.25 ,/^[A-Z][a-z]+$/]          # 1 upper all lower
       , [ 0.25 ,/^[A-Z][a-z]+\d$/]        # 1 upper, lower, 1 digit
       , [ 0.5  ,/^[A-Z][a-z]+\d+$/]       # 1 upper, lower, digits
       , [ 0.25 ,/^[a-z]+[._!\- @*#]$/]    # all lower 1 special
       , [ 0.25 ,/^[A-Z]+[._!\- @*#]$/]    # all upper 1 special
       , [ 0.5  ,/^[a-zA-Z]+[._!\- @*#]$/] # all letters 1 special
       , [ 0.25 ,/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$/]  # email
    # not clear, [ 0.5 ,/^[a-z\-ZA-Z0-9.-]+$/]    # web address
       , [ 1   ,/^.*$/]    # anything
       ]

    quality = (str, patterns) ->  
        Math.min.apply @, (p[0] for p in patterns when p[1].test str)

    entropyWeighted = (str, patterns) -> 
        (entropy2 str).bind (e) -> 
          Just (e*quality(str, patterns)) 

    scorePassword = (str) ->
        s = entropyWeighted str, patternsList
        switch s
            when Nothing then 0
            else (if s.val > 100 then 100 else s.val) 

    { entropeus: (pass) -> 
                 if pass isnt password 
                    password = pass
                    H = scorePassword(pass)
                 else 
                    H
    }
  ##############################################################################

