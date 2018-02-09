cordova.define('cordova/plugins/qiniu', function(
  require,
  exports,
  module
) {
  var exec = require('cordova/exec');

  var Qiniu = function() {};
  var Qiniu = new Qiniu();
  module.exports = Qiniu;
});

if (!window.plugins) {
  window.plugins = {};
}
if (!window.plugins.Qiniu) {
  window.plugins.Qiniu = cordova.require('cordova/plugins/Qiniu');
}
