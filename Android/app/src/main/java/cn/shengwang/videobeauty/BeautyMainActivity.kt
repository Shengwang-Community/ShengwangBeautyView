package cn.shengwang.videobeauty

import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.View
import android.widget.Toast
import cn.shengwang.beauty.demo.utils.PermissionHelp
import cn.shengwang.videobeauty.databinding.ActivityBeautyMainBinding
import cn.shengwang.videobeauty.utils.FileUtil
import kotlinx.coroutines.*
import java.io.File
import androidx.core.content.edit

class BeautyMainActivity : BaseActivity<ActivityBeautyMainBinding>() {

    companion object {
        private const val TAG = "BeautyMainActivity"
        private const val MATERIAL = "AgoraBeautyMaterial"
        private const val FUNCTIONAL = "beauty_material_functional"
        const val EXTRA_CHANNEL_NAME = "channel_name"
        const val EXTRA_MATERIAL_PATH = "material_path"
    }

    private lateinit var permissionHelp: PermissionHelp
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var materialPath = ""
    private var isLoaded = false
    private var lastClickTime = 0L

    override fun getViewBinding() = ActivityBeautyMainBinding.inflate(layoutInflater)

    override fun initView() {
        permissionHelp = PermissionHelp(this)
        val binding = mBinding ?: return

        setButtonEnabled(false)
        showLoading(true, "正在检查资源...", 0)
        loadResource()

        // 随机频道名
        val channel = "shengwang_beauty_${(10000..99999).random()}"
        binding.etChannelName.setText(channel)
        binding.etChannelName.setSelection(channel.length)

        binding.btnJoinChannel.setOnClickListener {
            if (System.currentTimeMillis() - lastClickTime < 2000) return@setOnClickListener
            lastClickTime = System.currentTimeMillis()

            if (!isLoaded) {
                showToast("美颜资源未加载完成", Toast.LENGTH_SHORT)
                return@setOnClickListener
            }

            val name = binding.etChannelName.text.toString().trim()
            if (name.isEmpty()) {
                showToast("请输入频道名称")
                return@setOnClickListener
            }

            permissionHelp.checkCameraAndMicPerms(
                granted = {
                    startActivity(Intent(this, BeautyExampleActivity::class.java).apply {
                        putExtra(EXTRA_CHANNEL_NAME, name)
                        putExtra(EXTRA_MATERIAL_PATH, materialPath)
                    })
                },
                unGranted = { showToast("需要摄像头和麦克风权限", Toast.LENGTH_LONG) },
                force = false
            )
        }
    }

    private fun loadResource() {
        scope.launch {
            val result = withContext(Dispatchers.IO) { prepareMaterial() }
            if (result != null) {
                materialPath = "$result/$FUNCTIONAL"
                isLoaded = true
                showLoading(false)
                setButtonEnabled(true)
                showToast("美颜资源加载完成", Toast.LENGTH_SHORT)
            } else {
                showLoading(false)
                showToast("美颜资源加载失败", Toast.LENGTH_LONG)
            }
        }
    }

    private fun prepareMaterial(): String? {
        val cacheDir = cacheDir.absolutePath
        val materialDir = "$cacheDir/$MATERIAL"
        val functionalDir = "$materialDir/$FUNCTIONAL"

        val expectedMd5 = FileUtil.readMd5FromAssets(this, "${MATERIAL}Md5.txt") ?: return copyAll(cacheDir, materialDir, null)
        val savedMd5 = prefs.getString("md5", null)
        val dirExists = File(functionalDir).isDirectory

        Log.d(TAG, "MD5 - expected: $expectedMd5, saved: $savedMd5, dirExists: $dirExists")

        return when {
            dirExists && savedMd5 == expectedMd5 -> {
                updateUI(100, "资源已就绪")
                materialDir
            }
            dirExists && savedMd5 != null -> updateFilterAndSticker(cacheDir, materialDir, expectedMd5)
            else -> copyAll(cacheDir, materialDir, expectedMd5)
        }
    }

    private fun copyAll(cacheDir: String, materialDir: String, md5: String?): String? {
        updateUI(0, "正在准备美颜资源...")
        File(materialDir).takeIf { it.exists() }?.let { FileUtil.deleteRecursively(it) }

        val result = FileUtil.copyAndUnzip(this, "$MATERIAL.zip", cacheDir) { p, m -> updateUI(p, m) }
        if (result != null && md5 != null) prefs.edit { putString("md5", md5) }
        return result
    }

    private fun updateFilterAndSticker(cacheDir: String, materialDir: String, md5: String): String? {
        updateUI(5, "检测到资源更新...")
        
        // 删除旧的 filter 和 sticker
        FileUtil.deleteByPrefix(File("$materialDir/$FUNCTIONAL"), "filter_", "sticker_")
        updateUI(10, "正在拷贝资源...")

        // 拷贝 zip
        val zipPath = "$cacheDir/$MATERIAL.zip"
        if (!FileUtil.copyFileFromAssets(this, "$MATERIAL.zip", zipPath) { p, _ -> updateUI(10 + p * 40 / 100, "正在拷贝...") }) {
            return null
        }

        // 只解压 filter 和 sticker
        updateUI(50, "正在解压更新...")
        if (!FileUtil.unzipWithProgress(zipPath, materialDir, { p, _ -> updateUI(50 + p / 2, "正在解压...") }, true)) {
            return null
        }

        prefs.edit { putString("md5", md5) }
        return materialDir
    }

    private fun updateUI(progress: Int, message: String) {
        runOnUiThread {
            mBinding?.tvProgress?.text = "$progress%"
            mBinding?.tvLoading?.text = message
        }
    }

    private fun showLoading(show: Boolean, message: String = "", progress: Int = 0) {
        mBinding?.apply {
            cardLoading.visibility = if (show) View.VISIBLE else View.GONE
            tvLoading.text = message
            tvProgress.text = "$progress%"
        }
    }

    private fun setButtonEnabled(enabled: Boolean) {
        mBinding?.btnJoinChannel?.apply {
            isEnabled = enabled
            alpha = if (enabled) 1f else 0.5f
        }
    }

    private val prefs by lazy { getSharedPreferences("beauty_prefs", Context.MODE_PRIVATE) }

    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }
}
