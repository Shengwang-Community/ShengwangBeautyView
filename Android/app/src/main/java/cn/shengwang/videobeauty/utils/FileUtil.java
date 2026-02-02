package cn.shengwang.videobeauty.utils;

import android.content.Context;
import android.content.res.AssetManager;
import android.text.TextUtils;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class FileUtil {
    public static final String SEPARATOR = File.separator;

    private static final int BUFFER = 4096;

    public static String copyFileAndUnzipFromAssets(Context ctx, String assetsFilePath, String storagePath) {
        if (TextUtils.isEmpty(storagePath)) {
            return null;
        } else if (storagePath.endsWith(SEPARATOR)) {
            storagePath = storagePath.substring(0, storagePath.length() - 1);
        }

        if (TextUtils.isEmpty(assetsFilePath) || assetsFilePath.endsWith(SEPARATOR)) {
            return null;
        }

        int lastDotIndex = assetsFilePath.lastIndexOf('.');
        String assetDir = assetsFilePath.substring(0, lastDotIndex);
        String storageDirPath = storagePath + SEPARATOR;
        String storageFilePath = storageDirPath + assetsFilePath;

        AssetManager assetManager = ctx.getAssets();
        try {
            File file = new File(storageFilePath);
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                InputStream inputStream = assetManager.open(assetsFilePath);
                readInputStream(storageFilePath, inputStream);
            }
            if (assetsFilePath.endsWith(".zip")) {
                unzipFile(storageFilePath, storageDirPath + assetDir);
                storageFilePath = storageDirPath + assetDir;
            }
        } catch (IOException e) {
            Log.e("FileUtils", "copyFileAndUnzipFromAssets: " + e.toString());
            return null;
        }
        return storageFilePath;
    }

    private static void readInputStream(String storagePath, InputStream inputStream) {
        File file = new File(storagePath);
        try {
            if (!file.exists()) {
                // 1.建立通道对象
                FileOutputStream fos = new FileOutputStream(file);
                // 2.定义存储空间
                byte[] buffer = new byte[inputStream.available()];
                // 3.开始读文件
                int lenght = 0;
                while ((lenght = inputStream.read(buffer)) != -1) {// 循环从输入流读取buffer字节
                    // 将Buffer中的数据写到outputStream对象中
                    fos.write(buffer, 0, lenght);
                }
                fos.flush();// 刷新缓冲区
                // 4.关闭流
                fos.close();
                inputStream.close();
            }
        } catch (IOException e) {
            Log.e("FileUtils", "readInputStream: " + e.toString());
        }
    }

    public static void unzipFile(String zipFile, String destPath) {
        if (!destPath.endsWith(File.separator)) {
            destPath += File.separator;
        }
        File destFile = new File(destPath);
        File[] items = destFile.listFiles();
        if (items != null && items.length > 0) {
            for (File item : items) {
                item.delete();
            }
        }
        FileOutputStream fos;
        ZipInputStream zipIn = null;
        ZipEntry zipEntry;
        File file;
        int buffer;
        byte buf[] = new byte[BUFFER];
        try {
            zipIn = new ZipInputStream(new BufferedInputStream(new FileInputStream(zipFile)));
            while ((zipEntry = zipIn.getNextEntry()) != null) {
                file = new File(destPath + zipEntry.getName());
                if (zipEntry.isDirectory()) {
                    file.mkdirs();
                } else {
                    File parent = file.getParentFile();
                    if (!parent.exists()) {
                        parent.mkdirs();
                    }
                    fos = new FileOutputStream(file);
                    while ((buffer = zipIn.read(buf)) > 0) {
                        fos.write(buf, 0, buffer);
                    }
                    fos.close();
                }
                zipIn.closeEntry();
                //delete zip
                File zipItem = new File(zipFile);
                zipItem.delete();
            }
        } catch (IOException ioe) {
            ioe.printStackTrace();
        } finally {
            try {
                if (zipIn != null) {
                    zipIn.close();
                }
            } catch (IOException ioe) {
                ioe.printStackTrace();
            }
        }
    }
}
