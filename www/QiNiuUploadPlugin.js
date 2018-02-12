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

QiNiuUploadPlugin.prototype.cancell = function(cancell, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    'QiNiuUploadPlugin',
    'cancell',
    [cancell]
  );
};

if (!window.plugins) {
  window.plugins = {};
}
if (!window.plugins.QiNiuUploadPlugin) {
  window.plugins.QiNiuUploadPlugin = new QiNiuUploadPlugin();
}

module.exports = QiNiuUploadPlugin;
