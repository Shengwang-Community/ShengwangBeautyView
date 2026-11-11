import { common } from '@kit.AbilityKit'
import fs from '@ohos.file.fs'
import zlib from '@ohos.zlib'

export class BeautyMaterial {
  // Versioned filesDir keeps SDK SAVE files across launches and avoids stale material on updates.
  private static readonly VERSION = '3d75a6e4f7023d24'
  private static pending: Promise<string> | undefined = undefined

  public static prepare(context: common.UIAbilityContext): Promise<string> {
    if (BeautyMaterial.pending === undefined) {
      BeautyMaterial.pending = BeautyMaterial.extract(context).catch((error: Error) => {
        BeautyMaterial.pending = undefined
        throw error
      })
    }
    return BeautyMaterial.pending
  }

  private static async extract(context: common.UIAbilityContext): Promise<string> {
    const root = `${context.filesDir}/AgoraBeautyMaterial-${BeautyMaterial.VERSION}`
    const material = `${root}/beauty_material_functional`
    const marker = `${root}/.ready`
    const required: string[] = [
      '/beauty_material_functional/config.json', '/resource/lip/lip001.png',
      '/resource/blush/blush001.png', '/resource/facial/facial001.png',
      '/resource/eyeshadow/eyeshadowleft001.png', '/resource/eyebrow/eyebrowleft001.png',
      '/resource/eyelash/eyelashleft002.png', '/resource/pupil/pupil001.png'
    ]
    if (fs.accessSync(marker) && required.every((path: string) => fs.accessSync(root + path))) {
      return material
    }
    if (!fs.accessSync(root)) {
      fs.mkdirSync(root, true)
    }
    const archive = `${context.cacheDir}/AgoraBeautyMaterial.zip`
    const content = await context.resourceManager.getRawFileContent('AgoraBeautyMaterial.zip')
    const file = fs.openSync(archive, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC)
    try {
      fs.writeSync(file.fd, content.buffer.slice(content.byteOffset, content.byteOffset + content.byteLength))
    } finally {
      fs.closeSync(file)
    }
    await zlib.decompressFile(archive, root)
    if (!required.every((path: string) => fs.accessSync(root + path))) {
      throw new Error('美颜素材不完整，请重新安装素材包')
    }
    const ready = fs.openSync(marker, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC)
    fs.closeSync(ready)
    fs.unlinkSync(archive)
    console.info('[BeautyDemo] material ready')
    return material
  }
}
