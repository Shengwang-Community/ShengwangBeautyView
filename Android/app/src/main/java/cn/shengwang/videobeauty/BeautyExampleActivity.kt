package cn.shengwang.videobeauty

import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.TextureView
import android.view.View
import android.widget.Toast
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
import io.agora.rtc2.video.VideoEncoderConfiguration

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

        // 点击视频区域隐藏美颜面板
        binding.flVideoContainer.setOnClickListener {
            if (binding.beautyControlView.visibility == View.VISIBLE) {
                binding.beautyControlView.visibility = View.GONE
            }
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
                binding.beautyControlView.saveBeauty(BeautyModule.STYLE_MAKEUP)
                binding.beautyControlView.saveBeauty(BeautyModule.FILTER)
                showToast(getString(R.string.beauty_setting_saved_info))
            }
        }

        binding.tvResetBeauty.setOnClickListener {
            if (isInitialized) {
                binding.beautyControlView.resetBeauty(BeautyModule.BEAUTY)
                binding.beautyControlView.resetBeauty(BeautyModule.STYLE_MAKEUP)
                binding.beautyControlView.resetBeauty(BeautyModule.FILTER)
                showToast(getString(R.string.beauty_setting_reseted_info))
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
            val downloadedTemplateRelativePaths = mapOf(
                "Filter-Peach" to "filter_baitao/",
                "Filter-Bright" to "filter_baici/",
                "Filter-Ink" to "filter_cangmo/",
                "Filter-Soda" to "filter_suda/",
                "Filter-Film" to "filter_jiaopian/",
                "Filter-Dreamy" to "filter_menghuan/",
                "Filter-Cotton" to "filter_mianrong/",
                "Filter-Sunny" to "filter_jiqin/",
                "Filter-Moonlight" to "filter_yuebai/",
                "Filter-Comic" to "filter_manhua/",
                "Filter-Cream" to "filter_naiyou/",
                "Filter-Gilt" to "filter_liujin/",
                "Filter-Summer" to "filter_ningxia/",
                "Filter-Gentleman" to "filter_shenshi/",
                "Filter-Daily" to "filter_richang/",
                "Filter-Urban" to "filter_dushi/",
                "Filter-Serene" to "filter_chenwen/",
                "Filter-Vanilla" to "filter_xiangcao/",
                "Filter-Glow" to "filter_liuguang/",
                "Filter-Latte" to "filter_natie/",
                "Filter-Snow" to "filter_chuxue/",
                "Filter-Blush" to "filter_fenxia/",
                "Filter-Tipsy" to "filter_weixun/",
                "Filter-Rouge" to "filter_yanzhi/",
                "Filter-Nostalgia" to "filter_huaijiu/",
                "Filter-Caramel" to "filter_jiaotang/",
                "Filter-Lavender" to "filter_xunyicao/",
                "Filter-Misty" to "filter_yinyun/",
                "Filter-Colorful" to "filter_qise/",
                "Filter-Salty" to "filter_yanqishui/",
                "Filter-Tranquil" to "filter_chenmi/",
                "Filter-Ins" to "filter_ins/",
                "Filter-Puff" to "filter_paofu/",
                "Filter-Texture" to "filter_zhigan/",
                "Filter-Collection" to "filter_sicang/",
                "Filter-Whitetea" to "filter_baicha/",
                "Filter-Street" to "filter_laojie/",
                "Sticker-Christmas" to "sticker_christmas/",
                "Sticker-Squid" to "sticker_squid/",
                "Sticker-Piggy" to "sticker_piggy/",
                "Sticker-Longcat" to "sticker_longcat/",
                "Sticker-Hairhoop" to "sticker_hairhoop/",
                "Sticker-Relax" to "sticker_relaxtime/",
                "Sticker-Cartooncat" to "sticker_cartooncat/",
                "Sticker-Butterfly" to "sticker_butterfly/",
                "Sticker-Brush" to "sticker_brush/",
                "Sticker-Glass" to "sticker_cyberglass/",
                "Sticker-Tiara" to "sticker_neontiara/",
                "Sticker-Love" to "sticker_loveglass/"
            )
            ShengwangBeautyManager.dynamicLoadDownloadRes(downloadedTemplateRelativePaths)
            Log.d(TAG, "Beauty manager initialized successfully")
        } else {
            Log.e(TAG, "Failed to initialize beauty manager")
        }
    }

    private fun createRtcEngine(): RtcEngineEx {
        val config = RtcEngineConfig()
        config.mContext = App.instance()
        config.mAppId = BuildConfig.App_ID
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

        val encoderConfig = VideoEncoderConfiguration().apply {
            dimensions = VideoEncoderConfiguration.VD_1280x720
            frameRate = 24
        }
        rtcEngine?.setVideoEncoderConfiguration(encoderConfig)
    }


    private fun showToast(message: String) {
        val toast = Toast.makeText(this, message, Toast.LENGTH_SHORT)
        toast.show()
        Handler(Looper.getMainLooper()).postDelayed({ toast.cancel() }, 500)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isInitialized && rtcEngine != null) {
            isInitialized = false
            // 销毁美颜 SDK
            ShengwangBeautyManager.unInitBeautySDK()
            rtcEngine?.stopPreview()
            rtcEngine?.leaveChannel()
            
            rtcEngine = null
            RtcEngine.destroy()
        }
    }
}
