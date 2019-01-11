# cordova-plugin-qiniu
> this project is under development for the time being. please come back again later.  

cordova plugin for qiniu sdk. android and ios both supported

## Install

github url installation
```shell
cordova plugin add https://github.com/pengkobe/cordova-plugin-qiniu 
```
or you can download cordova-plugin-qiniu to local directory 
```shell
cordova plugin add path/to/cordova-plugin-qiniu
```

## Env
* Qiniu Android SDK 7.3.10
* Qiniu Objective-C SDK 7.2.3

## Usage
#### Init
```javascript
window.plugins.QiNiuUploadPlugin.init(uploadtoken,function(data){
// success
}, function(err){
// error
});
```

#### Simple Upload
```javascript 
window.plugins.QiNiuUploadPlugin.simpleUploadFile({
  filePath:'your_local_file_path',
  name: 'your_file_name'
},function(data){
// success
}, function(err){
// error
});
```
#### Cancel
```javascript
window.plugins.QiNiuUploadPlugin.cancel(uploadtoken,function(data){
// success
}, function(err){
// error
});
```

## FAQ and Support
Feel free to ask question and put advices at https://github.com/pengkobe/cordova-plugin-qiniu/issues

## License
MIT@yipeng.info
