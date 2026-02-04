package cn.shengwang.videobeauty.utils

import android.content.Context
import android.util.Log
import java.io.BufferedInputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.zip.ZipFile
import java.util.zip.ZipInputStream

/**
 * 文件工具类
 * 提供从 assets 拷贝文件、解压 ZIP 文件、删除文件等功能
 */
object FileUtil {
    private const val TAG = "FileUtil"
    private const val BUFFER_SIZE = 8192

    /**
     * 进度回调接口
     * @param progress 进度百分比 (0-100)
     * @param message 进度消息
     */
    fun interface ProgressCallback {
        fun onProgress(progress: Int, message: String)
    }

    /**
     * 从 assets 目录读取 MD5 值
     * @param context 上下文
     * @param path assets 文件路径
     * @return MD5 字符串，读取失败返回 null
     */
    fun readMd5FromAssets(context: Context, path: String): String? = runCatching {
        context.assets.open(path).bufferedReader().use { it.readLine()?.trim() }
    }.getOrNull()

    /**
     * 从 assets 目录拷贝文件到目标路径
     * @param context 上下文
     * @param assetsPath assets 中的文件路径
     * @param destPath 目标文件路径
     * @param callback 进度回调（可选）
     * @return 拷贝成功返回 true，失败返回 false
     */
    fun copyFileFromAssets(
        context: Context,
        assetsPath: String,
        destPath: String,
        callback: ProgressCallback? = null
    ): Boolean = runCatching {
        File(destPath).parentFile?.mkdirs()
        val totalSize = context.assets.open(assetsPath).use { it.available().toLong() }
        
        context.assets.open(assetsPath).use { input ->
            FileOutputStream(destPath).use { output ->
                val buffer = ByteArray(BUFFER_SIZE)
                var copied = 0L
                var lastProgress = -1
                
                generateSequence { input.read(buffer).takeIf { it != -1 } }.forEach { len ->
                    output.write(buffer, 0, len)
                    copied += len
                    val progress = (copied * 100 / totalSize).toInt()
                    if (progress != lastProgress) {
                        lastProgress = progress
                        callback?.onProgress(progress, "正在拷贝资源文件...")
                    }
                }
            }
        }
        true
    }.onFailure { Log.e(TAG, "copyFileFromAssets: ${it.message}") }.getOrDefault(false)

    /**
     * 解压 ZIP 文件并显示进度
     * @param zipPath ZIP 文件路径
     * @param destPath 解压目标目录
     * @param callback 进度回调（可选）
     * @param filterOnly 是否只解压 filter_xxx 和 sticker_xxx 文件夹（用于增量更新）
     * @return 解压成功返回 true，失败返回 false
     */
    fun unzipWithProgress(
        zipPath: String,
        destPath: String,
        callback: ProgressCallback? = null,
        filterOnly: Boolean = false
    ): Boolean {
        val total = runCatching { ZipFile(zipPath).use { it.size() } }.getOrDefault(0)
        if (total == 0) return false

        return runCatching {
            File(destPath).mkdirs()
            ZipInputStream(BufferedInputStream(FileInputStream(zipPath))).use { zis ->
                var count = 0
                var lastProgress = -1
                val buffer = ByteArray(BUFFER_SIZE)

                generateSequence { zis.nextEntry }.forEach { entry ->
                    val name = entry.name
                    
                    // 更新模式：只处理 filter_xxx 和 sticker_xxx
                    if (filterOnly && !isFilterOrSticker(name)) {
                        zis.closeEntry()
                        count++
                        return@forEach
                    }

                    File(destPath, name).apply {
                        if (entry.isDirectory) mkdirs()
                        else {
                            parentFile?.mkdirs()
                            FileOutputStream(this).use { out ->
                                generateSequence { zis.read(buffer).takeIf { it > 0 } }
                                    .forEach { out.write(buffer, 0, it) }
                            }
                        }
                    }
                    zis.closeEntry()
                    count++
                    
                    val progress = count * 100 / total
                    if (progress != lastProgress) {
                        lastProgress = progress
                        callback?.onProgress(progress, "正在解压资源文件...")
                    }
                }
            }
            File(zipPath).delete()
            true
        }.onFailure { Log.e(TAG, "unzipWithProgress: ${it.message}") }.getOrDefault(false)
    }

    /**
     * 判断文件名是否为 filter 或 sticker 资源
     * @param name 文件路径名称
     * @return 如果是 filter_xxx 或 sticker_xxx 返回 true
     */
    private fun isFilterOrSticker(name: String): Boolean {
        val parts = name.split("/")
        return parts.size >= 2 && (parts[1].startsWith("filter_") || parts[1].startsWith("sticker_"))
    }

    /**
     * 递归删除文件或目录
     * @param file 要删除的文件或目录
     */
    fun deleteRecursively(file: File) {
        file.listFiles()?.forEach { deleteRecursively(it) }
        file.delete()
    }

    /**
     * 根据前缀删除目录下的文件或文件夹
     * @param dir 目标目录
     * @param prefixes 文件名前缀列表
     */
    fun deleteByPrefix(dir: File, vararg prefixes: String) {
        dir.listFiles()?.filter { f -> prefixes.any { f.name.startsWith(it) } }
            ?.forEach { deleteRecursively(it) }
    }

    /**
     * 从 assets 拷贝 ZIP 文件并解压
     * @param context 上下文
     * @param assetsZip assets 中的 ZIP 文件名
     * @param destDir 目标目录
     * @param callback 进度回调（可选）
     * @return 解压后的目录路径，失败返回 null
     */
    fun copyAndUnzip(
        context: Context,
        assetsZip: String,
        destDir: String,
        callback: ProgressCallback? = null
    ): String? {
        val zipPath = "$destDir/$assetsZip"
        val unzipDir = "$destDir/${assetsZip.substringBeforeLast('.')}"
        
        return runCatching {
            if (!copyFileFromAssets(context, assetsZip, zipPath, callback)) return null
            if (!unzipWithProgress(zipPath, unzipDir, callback)) return null
            unzipDir
        }.onFailure { Log.e(TAG, "copyAndUnzip: ${it.message}") }.getOrNull()
    }
}
