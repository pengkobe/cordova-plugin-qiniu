cordova.define('cordova/plugins/qiniu', function(require, exports, module) {
  var exec = require('cordova/exec');

  var Qiniu = function() {};
  var Qiniu = new Qiniu();
  Qiniu.prototype.simpleUploadFile = function(args, successCallback) {
    cordova.exec(successCallback, this.errorCallback, 'QiNiuPlugin', args);
  };

  Qiniu.prototype.init = function(uploadToken) {
    cordova.exec(
      successCallback,
      this.errorCallback,
      'QiNiuPlugin',
      uploadToken
    );
  };

  Qiniu.prototype.cancell = function(cancell) {
    cordova.exec(successCallback, this.errorCallback, 'QiNiuPlugin', cancell);
  };

  module.exports = Qiniu;
});

if (!window.plugins) {
  window.plugins = {};
}
if (!window.plugins.Qiniu) {
  window.plugins.Qiniu = cordova.require('cordova/plugins/Qiniu');
}
