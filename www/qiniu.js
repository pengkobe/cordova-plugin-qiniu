cordova.define('cordova/plugins/qiniu', function(require, exports, module) {
  var exec = require('cordova/exec');

  var Qiniu = function() {};
  var Qiniu = new Qiniu();
  Qiniu.prototype.simpleUploadFile = function(
    args,
    successCallback,
    errorCallback
  ) {
    cordova.exec(
      successCallback,
      errorCallback,
      'QiNiuUploadPlugin',
      'simpleUploadFile',
      args
    );
  };

  Qiniu.prototype.init = function(uploadToken, successCallback, errorCallback) {
    cordova.exec(
      successCallback,
      errorCallback,
      'QiNiuUploadPlugin',
      'init',
      uploadToken
    );
  };

  Qiniu.prototype.cancell = function(cancell, errorCallback) {
    cordova.exec(
      successCallback,
      errorCallback,
      'QiNiuUploadPlugin',
      'cancell',
      cancell
    );
  };

  module.exports = Qiniu;
});

if (!window.plugins) {
  window.plugins = {};
}
if (!window.plugins.Qiniu) {
  window.plugins.Qiniu = cordova.require('cordova/plugins/Qiniu');
}
