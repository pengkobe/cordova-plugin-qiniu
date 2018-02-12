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
    // 初始化、执行上传
    private volatile boolean isCancelled = false;


    /**
     * 初始化
     */
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        // 指定zone的具体区域
        // FixedZone.zone0   华东机房
        // FixedZone.zone1   华北机房
        // FixedZone.zone2   华南机房
        // FixedZone.zoneNa0 北美机房
        // 自动识别上传区域
        // AutoZone.autoZone
        // Configuration config = new Configuration.Builder()
        // .zone(AutoZone.autoZone)
        // .build();

        Configuration config = new Configuration.Builder().chunkSize(512 * 1024) // 分片上传时，每片的大小。 默认256K
                .putThreshhold(1024 * 1024) // 启用分片上传阀值。默认512K
                .connectTimeout(10) // 链接超时。默认10秒
                .useHttps(true) // 是否使用https上传域名
                .responseTimeout(60) // 服务器响应超时。默认60秒
                // .recorder(recorder) // recorder分片上传时，已上传片记录器。默认null
                // .recorder(recorder, keyGen) // keyGen 分片上传时，生成标识符，用于片记录器区分是那个文件的上传记录
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


    /**
     * 初始化 token
     */
    public void init(String uploadToken) throws JSONException, UnsupportedEncodingException {
        this.UPLOAD_TOKEN = uploadToken;
    }


    /**
     * 简单文件上传
     */
    public void simpleUploadFile(JSONArray args) throws JSONException, UnsupportedEncodingException {
        String prefix = args.optJSONObject(0).getString("prefix");
        String data = args.optJSONObject(0).getString("filePath");
        String key = appendPrefix(prefix, getFileName(data)); //获取文件名称 添加前缀
        data = URLDecoder.decode(data, "UTF-8"); //文件路径解码
        data = data.replace("file://", ""); //去掉 file:// 路径。
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
        uploadManager.put(data, key, UPLOAD_TOKEN,
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
                                // 发布消息表示成功
                                callbackContext.success(jsonObject);
                                Log.i("qiniu", "Upload Success");
                            } else {
                                callbackContext.error(jsonObject);
                                Log.i("qiniu", "Upload Fail");
                                //如果失败，这里可以把info信息上报自己的服务器，便于后面分析上传错误原因
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
    public void cancell(JSONArray args) throws JSONException, UnsupportedEncodingException {
        isCancelled = true;
    }


    // 记录断点 ( TODO )


    /**
     * @param filePath 文件路径
     * @return 获取文件名
     */
    public static String getFileName(String filePath) {
        return filePath.substring(filePath.lastIndexOf("/") + 1);
    }

    /**
     * @param prefix 前缀
     * @param target 目标
     * @return 处理好的字符串
     */
    public static String appendPrefix(String prefix, String target) {
        return prefix.concat("/").concat(target);
    }

}
