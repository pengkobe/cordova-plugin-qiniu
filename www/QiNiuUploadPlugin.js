var exec = require('cordova/exec');

var QiNiuUploadPlugin = function() {};
QiNiuUploadPlugin.prototype.simpleUploadFile = function(
  args,
  successCallback,
  errorCallback
) {
  cordova.exec(
    successCallback,
    errorCallback,
    'QiNiuUploadPlugin',
    'simpleUploadFile',
    [args]
  );
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
  cordova.exec(
    successCallback,
    errorCallback,
    'QiNiuUploadPlugin',
    'cancel',
    [cancel]
  );
};

if (!window.plugins) {
  window.plugins = {};
}
if (!window.plugins.QiNiuUploadPlugin) {
  window.plugins.QiNiuUploadPlugin = new QiNiuUploadPlugin();
}

module.exports = QiNiuUploadPlugin;
