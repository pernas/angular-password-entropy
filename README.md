# angular-password-entropy
AngularJS directive to create an entropy bar meter for a password field

## Usage

- Include the module dependency:

```javascript
    angular.module('myApp', ['passwordEntropy'])
```

- The element `<password-entropy>` is showing the entropy bar.
- The minimum entropy validation is set on the input as `min-entropy="50"`.
- You have to define your set of options for the entropy bar.

```html
<form role="form" name="testform" ng-submit="controller.mysubmit()">
    <div class="form-group">
      <label for="pwd">Password: </label>
      <input id="pwd"
             name="passwordInput"
             class="form-control"
             type="text"
             ng-model="controller.pwd"
             min-entropy="50"
             required ></input>
      <password-entropy
        password="controller.pwd"
        options="controller.myOpt">
      </password-entropy>
    </div>
    <div class="form-group">
      <button type="submit"
              class="btn btn-default"
              ng-disabled="testform.$invalid">
              Say hello
      </button>
    </div>
</form>
```
- The options set must contain scores between 1-100 and can have as much steps as you need

```javascript
    .controller('controller', [
      function(){
        var self = this;
        self.pwd = "";
        self.mysubmit = function() {alert("Hola!!");};
        self.myOpt = {
                     '0': ['progress-bar-danger',  'very weak'],
                    '15': ['progress-bar-danger',  'weak'],
                    '35': ['progress-bar-warning',    'normal'],
                    '50': ['progress-bar-success', 'strong'],
                    '70': ['progress-bar-success', 'very strong']
        }; 
    }])
```

- [See it in action](http://demo.pernas.cat:18555/static/index.html#/) 