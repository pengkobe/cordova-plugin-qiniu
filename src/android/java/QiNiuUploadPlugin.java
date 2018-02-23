package com.cordova.qiniu;

import java.lang.reflect.InvocationTargetException;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Method;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.qiniu.android.http.ResponseInfo;
import com.qiniu.android.storage.UpCompletionHandler;
import com.qiniu.android.storage.UploadManager;
import com.qiniu.android.storage.UploadOptions;

import com.qiniu.android.storage.Configuration;
import com.qiniu.android.common.AutoZone;
import com.qiniu.android.storage.UpProgressHandler;
import com.qiniu.android.storage.UpCancellationSignal;

import java.net.URLDecoder;

import android.util.Log;

public class QiNiuUploadPlugin extends CordovaPlugin {

    private UploadManager uploadManager;
    private CallbackContext callbackContext;
    protected String UPLOAD_TOKEN = "";
    private volatile boolean isCancelled = false;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        Configuration config = new Configuration.Builder().chunkSize(512 * 1024) // 分片上传时，每片的大小。 默认256K
                .putThreshhold(1024 * 1024) // 启用分片上传阀值。默认512K
                .connectTimeout(10) // 链接超时。默认10秒
                .useHttps(true) // 是否使用https上传域名
                .responseTimeout(60) // 服务器响应超时。默认60秒
                .zone(AutoZone.autoZone) // 自动识别区域
                .build();
        uploadManager = new UploadManager(config);
    }

    @Override
    public boolean execute(final String action, final JSONArray args, final CallbackContext callbackContext)
            throws JSONException {
        this.callbackContext = callbackContext;
        try {
            Method method = this.getClass().getDeclaredMethod(action, JSONArray.class);
            if (method != null) {
                method.invoke(this, args);
                return true;
            } else {
                callbackContext.error("QiNiuPlugin Action error!");
            }
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }
        return true;
    }

    public void init(JSONArray args) throws JSONException, UnsupportedEncodingException {
        String uploadToken = args.getString(0);
        this.UPLOAD_TOKEN = uploadToken;
    }

    public void simpleUploadFile(JSONArray args) throws JSONException, UnsupportedEncodingException {
        String data = args.optJSONObject(0).getString("filePath");
        String name = args.optJSONObject(0).getString("name");
        data = URLDecoder.decode(data, "UTF-8"); //文件路径解码
        data = data.replace("file://", ""); //去掉 file:// 路径。
        Log.i("UploadFile filePath", data);
        UploadOptions uploadOptions = new UploadOptions(null, null, false,
                new UpProgressHandler() {
                    @Override
                    public void progress(String key, double percent) {
                        try {
                            JSONObject jsonObject = new JSONObject();
                            jsonObject.put("key", key);
                            jsonObject.put("percent", percent);
                            // 更新上传进度
                            callbackContext.success(jsonObject);
                        } catch (JSONException err) {
                        }
                    }
                }, new UpCancellationSignal() {
            public boolean isCancelled() {
                return isCancelled;
            }
        });
        Log.i("UPLOAD_TOKEN", this.UPLOAD_TOKEN);
        uploadManager.put(data, name, this.UPLOAD_TOKEN,
                new UpCompletionHandler() {
                    @Override
                    public void complete(String key, ResponseInfo info, JSONObject res) {
                        try {
                            JSONObject jsonObject = new JSONObject();
                            jsonObject.put("key", key);
                            jsonObject.put("info", info);
                            jsonObject.put("res", res);
                            //res包含 hash、key 等信息，具体字段取决于上传策略的设置
                            if (info.isOK()) {
                                Log.i("qiniu", "Upload Success");
                                callbackContext.success(jsonObject);
                            } else {
                                Log.i("qiniu", "Upload Fail");
                                callbackContext.error(jsonObject);
                            }
                            Log.i("qiniu", key + ",\r\n " + info + ",\r\n " + res);
                        } catch (JSONException err) {
                        }
                    }
                },
                uploadOptions
        );
    }


    /**
     * 点击取消按钮，让UpCancellationSignal##isCancelled()方法返回true，以停止上传
     */
    public void cancel(JSONArray args) throws JSONException, UnsupportedEncodingException {
        isCancelled = true;
    }

    // 记录断点 ( TODO )
}
