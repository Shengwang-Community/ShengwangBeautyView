package cn.shengwang.videobeauty

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.view.View
import android.widget.Toast
import cn.shengwang.beauty.demo.utils.PermissionHelp
import cn.shengwang.videobeauty.databinding.ActivityBeautyMainBinding
import cn.shengwang.videobeauty.utils.FileUtil
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.util.Random

/**
 * 主界面 Activity
 * 提供频道名称输入和加入频道功能
 */
class BeautyMainActivity : BaseActivity<ActivityBeautyMainBinding>() {

    companion object {
        private const val TAG = "BeautyMainActivity"
        private const val PREFS_NAME = "agora_beauty_sdk_prefs"
        private const val KEY_MATERIAL_COPIED = "material_copied"
        private const val KEY_MATERIAL_PATH = "material_path"
        private const val ZIP_FILE_NAME = "AgoraBeautyMaterial.zip"
        private const val MATERIAL_DIR_NAME = "AgoraBeautyMaterial"
        private const val MATERIAL_FUNCTIONAL_DIR = "beauty_material_functional"
        private const val CLICK_THROTTLE_MS = 2000L

        const val EXTRA_CHANNEL_NAME = "channel_name"
        const val EXTRA_MATERIAL_PATH = "material_path"
    }

    private lateinit var permissionHelp: PermissionHelp

    private var scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    private var materialPath: String = ""
    private var isResourceLoaded = false
    private var lastJoinClickTime = 0L
    private var navigatingToExample = false

    override fun getViewBinding(): ActivityBeautyMainBinding = ActivityBeautyMainBinding.inflate(layoutInflater)

    override fun initView() {
        permissionHelp = PermissionHelp(this)
        val binding = mBinding?:return

        // 初始状态：禁用按钮，显示 loading
        setJoinButtonEnabled(false)
        showLoading(true)

        // 直接加载美颜资源
        loadBeautyResource()

        // 生成默认随机频道名称
        val defaultChannelName = generateRandomChannelName()
        binding.etChannelName.setText(defaultChannelName)
        binding.etChannelName.setSelection(defaultChannelName.length)

        // 设置加入频道按钮点击事件（防暴力点击）
        binding.btnJoinChannel.setOnClickListener {
            val now = System.currentTimeMillis()
            if (now - lastJoinClickTime < CLICK_THROTTLE_MS) return@setOnClickListener
            lastJoinClickTime = now

            if (!isResourceLoaded || materialPath.isEmpty()) {
                showToast("美颜资源未加载完成，请稍候", Toast.LENGTH_SHORT)
                return@setOnClickListener
            }

            val channelName = binding.etChannelName.text.toString().trim()
            if (channelName.isEmpty()) {
                showToast("请输入频道名称")
                return@setOnClickListener
            }

            // 申请权限
            permissionHelp.checkCameraAndMicPerms(
                granted = {
                    navigatingToExample = true
                    mBinding?.tvLoading?.text = "加载中..."
                    setJoinButtonEnabled(false)
                    showLoading(true)
                    navigateToBeautyExample(channelName)
                },
                unGranted = {
                    // 权限被拒绝
                    showToast("需要摄像头和麦克风权限才能使用美颜功能", Toast.LENGTH_LONG)
                },
                force = false
            )
        }
    }

    /**
     * 生成随机频道名称
     * 格式：shengwang_beauty_xxxxx（10000～99999）
     */
    private fun generateRandomChannelName(): String {
        val randomNumber = Random().nextInt(90000) + 10000 // 10000 到 99999
        return "shengwang_beauty_$randomNumber"
    }

    /**
     * 跳转到 BeautyExampleActivity
     */
    private fun navigateToBeautyExample(channelName: String) {
        val intent = Intent(this, BeautyExampleActivity::class.java).apply {
            putExtra(EXTRA_CHANNEL_NAME, channelName)
            putExtra(EXTRA_MATERIAL_PATH, materialPath)
        }
        startActivity(intent)
    }

    private fun showLoading(show: Boolean) {
        val binding = mBinding ?: return
        binding.progressBar.visibility = if (show) View.VISIBLE else View.GONE
        binding.tvLoading.visibility = if (show) View.VISIBLE else View.GONE
    }

    private fun setJoinButtonEnabled(enabled: Boolean) {
        val btn = mBinding?.btnJoinChannel ?: return
        btn.isEnabled = enabled
        btn.isClickable = enabled
        btn.alpha = if (enabled) 1.0f else 0.5f
    }

    override fun onResume() {
        super.onResume()
        if (navigatingToExample) {
            navigatingToExample = false
            showLoading(false)
            if (isResourceLoaded) setJoinButtonEnabled(true)
        }
    }

    private fun loadBeautyResource() {
        scope.launch {
            try {
                // Execute initialization on IO dispatcher
                withContext(Dispatchers.IO) {
                    val materialDir = getOrCopyMaterialDirectory(this@BeautyMainActivity)
                        ?: run {
                            Log.e(TAG, "Failed to get material directory, cannot initialize beauty SDK")
                            withContext(Dispatchers.Main) {
                                showLoading(false)
                                showToast("美颜资源加载失败", Toast.LENGTH_LONG)
                                setJoinButtonEnabled(false)
                            }
                            return@withContext
                        }

                    materialPath = "$materialDir/${MATERIAL_FUNCTIONAL_DIR}"
                    Log.d(TAG, "Beauty material loaded successfully, path: $materialPath")
                    
                    // 切换到主线程更新 UI
                    withContext(Dispatchers.Main) {
                        isResourceLoaded = true
                        showLoading(false)
                        setJoinButtonEnabled(true)
                        showToast("美颜资源加载完成", Toast.LENGTH_SHORT)
                    }
                }

            } catch (e: CancellationException) {
                // 协程被取消，正常情况，不需要处理
                Log.d(TAG, "Beauty initialization cancelled")
                withContext(Dispatchers.Main) {
                    showLoading(false)
                    setJoinButtonEnabled(false)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error during beauty initialization", e)
                withContext(Dispatchers.Main) {
                    showLoading(false)
                    setJoinButtonEnabled(false)
                    showToast("美颜资源加载失败: ${e.message}", Toast.LENGTH_LONG)
                }
            }
        }
    }

    /**
     * 获取或复制美颜素材目录
     * 统一使用固定路径，保存路径和默认路径保持一致
     *
     * @param context Android context
     * @return 素材目录路径，失败返回 null
     */
    private fun getOrCopyMaterialDirectory(context: Context): String? {
        val cacheDir = context.externalCacheDir?.absolutePath ?: run {
            Log.e(TAG, "External cache directory is null")
            return null
        }

        // 统一使用固定路径
        val materialDir = "$cacheDir/$MATERIAL_DIR_NAME"

        // 如果路径已存在，直接返回
        if (File(materialDir).exists()) {
            Log.d(TAG, "Material directory already exists: $materialDir")
            // 确保标记和路径一致
            if (!isMaterialCopied(context)) {
                setMaterialCopied(context, true)
            }
            // 统一保存为固定路径
            saveMaterialPath(context, materialDir)
            return materialDir
        }

        // 如果标记为已复制但路径不存在，清除标记（可能被删除了）
        if (isMaterialCopied(context)) {
            Log.w(TAG, "Material directory does not exist but marked as copied, will re-copy")
            setMaterialCopied(context, false)
        }

        // 需要复制资源
        Log.d(TAG, "Copying beauty materials from assets...")
        val copiedPath = FileUtil.copyFileAndUnzipFromAssets(
            context,
            ZIP_FILE_NAME,
            cacheDir
        )

        return if (!copiedPath.isNullOrEmpty() && File(copiedPath).exists()) {
            setMaterialCopied(context, true)
            // 统一保存为固定路径（保存路径和默认路径保持一致）
            saveMaterialPath(context, materialDir)
            Log.d(TAG, "Beauty materials copied successfully to: $copiedPath")
            // 返回实际复制路径（FileUtil 返回的路径）
            copiedPath
        } else {
            Log.e(TAG, "Failed to copy beauty materials")
            null
        }
    }

    private fun getSharedPreferences(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    /**
     * 检查素材是否已复制
     * 注意：如果使用美颜 SDK 的保存功能，不能每次都复制资源，否则美颜配置会被覆盖
     */
    private fun isMaterialCopied(context: Context): Boolean {
        return getSharedPreferences(context).getBoolean(KEY_MATERIAL_COPIED, false)
    }

    private fun setMaterialCopied(context: Context, copied: Boolean) {
        getSharedPreferences(context).edit()
            .putBoolean(KEY_MATERIAL_COPIED, copied)
            .apply()
    }

    private fun saveMaterialPath(context: Context, path: String) {
        getSharedPreferences(context).edit()
            .putString(KEY_MATERIAL_PATH, path)
            .apply()
    }

    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }
}
