var exec = require('cordova/exec');

var QiNiuUploadPlugin = function() {};
QiNiuUploadPlugin.prototype.simpleUploadFile = function(
  args,
  successCallback,
  onProgressCallback,
  errorCallback
) {
  var win = function(result) {
    if (typeof result.percent != 'undefined') {
        onProgressCallback(result);
    } else {
      if (successCallback) {
        successCallback(result);
      }
    }
  };
  cordova.exec(win, errorCallback, 'QiNiuUploadPlugin', 'simpleUploadFile', [
    args,
  ]);
};

QiNiuUploadPlugin.prototype.init = function(
  uploadToken,
  successCallback,
  errorCallback
) {
  cordova.exec(successCallback, errorCallback, 'QiNiuUploadPlugin', 'init', [
    uploadToken,
  ]);
};

QiNiuUploadPlugin.prototype.cancel = function(cancel, errorCallback) {
  cordova.exec(successCallback, errorCallback, 'QiNiuUploadPlugin', 'cancel', [
    cancel,
  ]);
};

if (!window.plugins) {
  window.plugins = {};
}
if (!window.plugins.QiNiuUploadPlugin) {
  window.plugins.QiNiuUploadPlugin = new QiNiuUploadPlugin();
}

module.exports = QiNiuUploadPlugin;
