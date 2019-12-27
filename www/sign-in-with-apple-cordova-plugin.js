var exec = require('cordova/exec'),
    cordova = require('cordova'),
    channel = require('cordova/channel');


function SignInWithApple() {
    this.canShowButton = false;
    var self = this;
    channel.onCordovaReady.subscribe(function () {
        self.getShowButtonStatus(function (status) {
            self.canShowButton = status;
            channel.onCordovaInfoReady.fire();
        }, function (err) {
            console.log("JJ: SignInWithApple -> err", err)
        })
        
    })
}

SignInWithApple.prototype.getShowButtonStatus = function (success, error, params) {
    cordova.exec(success, error, 'sign-in-with-apple-cordova-plugin', 'getShowButtonStatus', [params]);
};

SignInWithApple.prototype.login = function (success, error, params) {
    cordova.exec(success, error, 'sign-in-with-apple-cordova-plugin', 'login', [params]);
};

SignInWithApple.prototype.checkStateWithUserID = function (success, error, params) {
    cordova.exec(success, error, 'sign-in-with-apple-cordova-plugin', 'checkStateWithUserID', [params]);
};


module.exports = new SignInWithApple();

// exports.login = function (success, error, params) {
//     cordova.exec(success, error, 'sign-in-with-apple-cordova-plugin', 'login', [params]);
// };

// exports.checkStateWithUserID = function (success, error, params) {
//     cordova.exec(success, error, 'sign-in-with-apple-cordova-plugin', 'checkStateWithUserID', [params]);
// };
