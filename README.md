# password-checker
AngularJS directive to check the entropy of a password

## Usage

- Include the module dependency:

```javascript
    angular.module('myApp', [passwordStr'])
```

- As an element

```html
     <input class="form-control" 
            type="text" 
            ng-model="mycontroller.password"></input>
     <div password-str password="{{mycontroller.password}}"></div>
```

- [See it in action](http://demo.pernas.cat:18555/static/index.html#/) 