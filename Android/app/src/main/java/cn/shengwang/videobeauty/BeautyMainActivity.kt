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
        // filesDir 不属于 cache，系统不会因为存储紧张主动回收其中的素材。
        // 清除应用数据或卸载应用后仍会删除，因此每次使用前都要做完整性校验。
        val materialDir = File(filesDir, MATERIAL)
        migrateLegacyMaterial(materialDir)

        val expectedMd5 = runCatching {
            assets.open("zip.md5").bufferedReader().use { it.readText().trim() }
        }.getOrNull()?.takeIf { it.isNotEmpty() } ?: run {
            Log.e(TAG, "无法读取美颜资源包 MD5")
            return null
        }
        val savedMd5 = prefs.getString("md5", null)
        val ready = isMaterialReady(materialDir)

        Log.d(TAG, "素材检查 - path: ${materialDir.absolutePath}, expectedMd5: $expectedMd5, savedMd5: $savedMd5, ready: $ready")

        return when {
            ready && savedMd5 == expectedMd5 -> {
                updateUI(100, "资源已就绪")
                materialDir.absolutePath
            }
            ready && savedMd5 != null -> updateFilterAndSticker(materialDir, expectedMd5)
            else -> copyAll(materialDir, expectedMd5)
        }
    }

    private fun isMaterialReady(materialDir: File): Boolean {
        val functionalDir = File(materialDir, FUNCTIONAL)
        val config = File(functionalDir, "config.json")
        return materialDir.isDirectory && functionalDir.isDirectory && config.isFile
    }

    private fun copyAll(materialDir: File, md5: String): String? {
        updateUI(0, "正在准备美颜资源...")
        val result = FileUtil.copyAndUnzip(this, "$MATERIAL.zip", filesDir.absolutePath) { p, m -> updateUI(p, m) }
            ?: return null

        if (!isMaterialReady(materialDir)) {
            Log.e(TAG, "美颜资源解压后仍不完整: $result")
            return null
        }
        prefs.edit { putString("md5", md5) }
        return result
    }

    private fun updateFilterAndSticker(materialDir: File, md5: String): String? {
        updateUI(5, "检测到资源更新...")

        val zipPath = File(filesDir, "$MATERIAL.zip").absolutePath
        if (!FileUtil.copyFileFromAssets(this, "$MATERIAL.zip", zipPath) { p, _ ->
                updateUI(10 + p * 40 / 100, "正在拷贝...")
            }) {
            return null
        }

        // filter/sticker 不保存用户调节参数，版本更新时整体替换。
        val functionalDir = File(materialDir, FUNCTIONAL)
        FileUtil.deleteByPrefix(functionalDir, "filter_", "sticker_")

        val unzipped = FileUtil.unzipWithProgress(zipPath, materialDir.absolutePath, { p, _ ->
                updateUI(50 + p / 2, "正在解压更新...")
            }, templatesOnly = true)
        if (!unzipped || !isMaterialReady(materialDir)) {
            return null
        }

        prefs.edit { putString("md5", md5) }
        return materialDir.absolutePath
    }

    private fun migrateLegacyMaterial(materialDir: File) {
        val legacyDir = File(cacheDir, MATERIAL)
        if (materialDir.exists() || !legacyDir.exists()) return

        runCatching {
            materialDir.parentFile?.mkdirs()
            if (!legacyDir.renameTo(materialDir)) {
                legacyDir.copyRecursively(materialDir)
            }
        }.onFailure {
            Log.e(TAG, "迁移旧美颜资源失败", it)
        }
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
