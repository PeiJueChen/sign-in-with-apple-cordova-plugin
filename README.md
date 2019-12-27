### Required

``` js
* mac 10.15 .0 or above
* iOS13 or above 
* enables `Sign in with Apple` features on Apple developer website
* Signing & Capabilities in Xcode enables `Sign in with Apple` 
```

### Installation

``` 
cordova plugin add sign-in-with-apple-cordova-plugin
Or
cordova plugin add https://github.com/PeiJueChen/sign-in-with-apple-cordova-plugin.git
```

### Usage

``` js
var signInWithApple = window['SignInWithApple'];

// only ios13 or above

1. can show apple login button
let can = signInWithApple.canShowButton;

2. login
signInWithApple.login((result) => {

    /* 
    success: {"state" : 1, info: {state:xx,userIdentifier:xx,familyName:xx,givenName:xx,nickname:xx,middleName:xx,namePrefix:xx,email:xx,identityToken:xx,authCode:xx....}} 

    error: {"state" : -1
    "errCode" : errCode,
    "errDesc" : errDesc
    }
    errCode = 0 ,  errCode: other
    errCode = -1 ,  errCode: User cancelled authorization request
    errCode = -2 ,  errCode: Authorization request failed
    errCode = -3 ,  errCode: Authorization request is not responding
    errCode = -4 ,  errCode: Failed to process authorization request
    errCode = -5 ,  errCode: Authorization request failed : unknown reason
    */
    console.log(result)
}, (err) => {
    console.log(err)
});

3. check state
signInWithApple.checkStateWithUserID((result) => {

    /* result:
    {"state":1,"errDesc": "Apple ID Credential is valid"}
    {"state":-1, "errDesc": "Apple ID Credential revoked, handle unlink"}
    {"state":-2, "errDesc": "Credential not found, show login UI"}
    {"state":-3, "errDesc": "Other"}
    */
    console.log(result)
}, (err) => {
    console.log(err)
}, "userIdentifier");
```

