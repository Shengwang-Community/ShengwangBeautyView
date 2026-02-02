package cn.shengwang.videobeauty

import android.util.Log
import android.view.TextureView
import android.view.View
import cn.shengwang.beauty.core.ShengwangBeautyManager
import cn.shengwang.beauty.ui.model.BeautyModule
import io.agora.rtc2.Constants
import io.agora.rtc2.IRtcEngineEventHandler
import io.agora.rtc2.RtcEngine
import io.agora.rtc2.RtcEngineConfig
import io.agora.rtc2.RtcEngineEx
import cn.shengwang.videobeauty.databinding.ActivityBeautyExampleBinding
import io.agora.rtc2.ChannelMediaOptions
import io.agora.rtc2.video.VideoCanvas

/**
 * 美颜功能使用示例 Activity
 * 使用本地美颜资源，资源已在 BeautyMainActivity 中加载
 */
class BeautyExampleActivity : BaseActivity<ActivityBeautyExampleBinding>() {

    private val TAG = "BeautyExampleActivity"

    private var isInitialized = false
    private var rtcEngine: RtcEngineEx? = null
    var isFrontCamera = true

    private var channelName: String? = null
    private var materialPath: String? = null
    private var uid: Int = 0 // RTC 用户 ID

    companion object {
        const val EXTRA_CHANNEL_NAME = "channel_name"
        const val EXTRA_MATERIAL_PATH = "material_path"
    }

    override fun getViewBinding(): ActivityBeautyExampleBinding = ActivityBeautyExampleBinding.inflate(layoutInflater)

    override fun initView() {

        val binding = mBinding ?: return

        // 获取频道号和美颜资源路径
        channelName = intent.getStringExtra(EXTRA_CHANNEL_NAME)
        materialPath = intent.getStringExtra(EXTRA_MATERIAL_PATH)
        
        if (channelName.isNullOrEmpty()) {
            Log.w(TAG, "Channel name is empty, finishing activity")
            finish()
            return
        }
        
        if (materialPath.isNullOrEmpty()) {
            Log.e(TAG, "Material path is empty, finishing activity")
            finish()
            return
        }
        
        Log.d(TAG, "Channel name: $channelName")
        Log.d(TAG, "Material path: $materialPath")

        // 设置返回按钮点击事件
        binding.ivBack.setOnClickListener {
            finish()
        }

        // 设置美颜按钮点击事件 - 直接显示/隐藏 View
        binding.tvBeauty.setOnClickListener {
            val beautyView = binding.beautyControlView
            beautyView.visibility = if (beautyView.visibility == View.VISIBLE) {
                View.GONE
            } else {
                View.VISIBLE
            }
        }

        // 设置切换摄像头按钮点击事件
        binding.tvSwitchCamera.setOnClickListener {
            if (isInitialized) {
                isFrontCamera = !isFrontCamera
                rtcEngine?.switchCamera()
            }
        }

        binding.tvSaveBeauty.setOnClickListener {
            if (isInitialized) {
                binding.beautyControlView.saveBeauty(BeautyModule.BEAUTY)
            }
        }

        binding.tvResetBeauty.setOnClickListener {
            if (isInitialized) {
                binding.beautyControlView.resetBeauty(BeautyModule.BEAUTY)
            }
        }

        initializeBeauty()
        joinChannel()
    }

    private fun initializeBeauty() {
        if (isInitialized) return
        isInitialized = true

        rtcEngine = createRtcEngine()

        val path = materialPath ?: run {
            Log.e(TAG, "Material path is null, cannot initialize beauty SDK")
            return
        }

        Log.d(TAG, "Initializing beauty manager with material path: $path")

        // 初始化美颜 SDK
        val success = ShengwangBeautyManager.initBeautySDK(path, rtcEngine!!)
        if (success) {
            // 初始化成功后，默认开启美颜
            ShengwangBeautyManager.enable(true)
            Log.d(TAG, "Beauty manager initialized successfully")
        } else {
            Log.e(TAG, "Failed to initialize beauty manager")
        }
    }

    private fun createRtcEngine(): RtcEngineEx {
        val config = RtcEngineConfig()
        config.mContext = App.instance()
        config.mAppId = BuildConfig.App_ID
        config.addExtension("agora_ai_echo_cancellation_extension")
        config.addExtension("agora_ai_noise_suppression_extension")
        config.mEventHandler = object : IRtcEngineEventHandler() {
            override fun onError(err: Int) {
                super.onError(err)
                Log.d(TAG, "Rtc Error code err: $err, msg:" + RtcEngine.getErrorDescription(err))
            }

            override fun onJoinChannelSuccess(channel: String?, uid: Int, elapsed: Int) {
                super.onJoinChannelSuccess(channel, uid, elapsed)
                Log.d(TAG, "onJoinChannelSuccess channel: $channel, uid: $uid")
            }

            override fun onLeaveChannel(stats: RtcStats?) {
                super.onLeaveChannel(stats)
                Log.d(TAG, "onLeaveChannel")
            }
        }
        return (RtcEngine.create(config) as RtcEngineEx).apply {
            enableVideo()
        }
    }

    override fun onResume() {
        super.onResume()
        // 如果已初始化，则开始预览并加入频道
        if (isInitialized && rtcEngine != null) {
            rtcEngine?.startPreview()
        }
    }

    /**
     * 加入 RTC 频道
     */
    private fun joinChannel() {
        val name = channelName ?: return
        val options = ChannelMediaOptions().apply {
            clientRoleType = Constants.CLIENT_ROLE_BROADCASTER
            autoSubscribeAudio = true
            publishMicrophoneTrack = true
            publishCameraTrack = true
        }
        val result = rtcEngine?.joinChannel(null, name, uid, options) ?: -1
        if (result == Constants.ERR_OK) {
            Log.d("BeautyExampleActivity", "Join channel success: $name, uid: $uid")
        } else {
            Log.e("BeautyExampleActivity", "Join channel failed: ${RtcEngine.getErrorDescription(result)}")
        }

        val videoView = TextureView(this).apply {
            mBinding?.flVideoContainer?.addView(this)
        }
        rtcEngine?.setupLocalVideo(VideoCanvas(videoView, Constants.RENDER_MODE_HIDDEN, 0))
    }


    override fun onDestroy() {
        super.onDestroy()
        if (isInitialized && rtcEngine != null) {
            isInitialized = false
            rtcEngine?.stopPreview()
            rtcEngine?.leaveChannel()

            // 销毁美颜 SDK
            ShengwangBeautyManager.unInitBeautySDK()
            rtcEngine = null
            RtcEngine.destroy()
        }
    }
}