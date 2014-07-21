var exec = require('cordova/exec');


var iOSContacts = function(callback) {
  var iOSContactsReturn = function (json) {
    var data = JSON.parse(json);

    if (data.error)
      return callback(err, null);

    return callback(null, data.contacts);
  }

  exec(iOSContactsReturn, iOSContactsReturn, 'iOSContacts', 'iOSContacts', []);
};

module.exports = iOSContacts;
