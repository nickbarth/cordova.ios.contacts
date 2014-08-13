## Cordova iOS Contacts

## About this Plugin

Retrieve the address book contacts for an iOS device. Supports iOS Versions 6.0 and up only.

## Using the Plugin

Example:

```
window.iOSContacts(function (err, contacts) {
  if (err) return alert(err);
  console.log('contacts are ', contacts);
});
```

## Adding the Plugin ##

```
  cordova plugin add https://github.com/nickbarth/cordova.ios.contacts.git
```

## LICENSE ##

The CC0 License

[![CC0](http://i.creativecommons.org/l/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)
